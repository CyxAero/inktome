import 'package:flutter/material.dart';
import 'package:inktome/core/features/settings/sections/appearance_section.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/theme/theme_notifier.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/core/widgets/inktome_card.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavBarNotifier>().clearAction();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final currentMode = context.watch<ThemeNotifier>().mode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'settings',
          style: InktomeTextStyles.headingLarge.copyWith(color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: IntrinsicHeight(
          child: InktomeCard(
            borderColor: textColor,
            cardColor: isDark ? InktomeColors.black : InktomeColors.white,
            cardBorderRadius: InktomeSpacing.radiusXl,
            child: Padding(
              padding: const EdgeInsets.all(InktomeSpacing.xs),
              child: DashedBorder(
                color: textColor,
                radius: 20.0,
                // radius: InktomeSpacing.radiusMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: InktomeSpacing.sm,
                    vertical: InktomeSpacing.md,
                  ),
                  child: AppearanceSection(
                    textColor: textColor,
                    currentMode: currentMode,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
