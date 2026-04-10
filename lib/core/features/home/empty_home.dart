import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';

// MARK: EmptyHome
//
// Shown when the user has no books yet.
// Friendly prompt to add their first book — tapping the message
// triggers the same add-book overlay as the nav bar + button.
class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: InktomeSpacing.lg),

            // Greeting
            Text(
              'Hello,',
              style: InktomeTextStyles.headingLarge.copyWith(color: textColor),
            ),
            Text(
              'Reader!',
              style: InktomeTextStyles.display.copyWith(color: textColor),
            ),

            const Spacer(),

            // Empty state prompt — centred in the remaining space
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dashed squircle placeholder — tappable, opens add overlay
                  GestureDetector(
                    onTap: () => showAddBookOverlay(context),
                    child: DashedBorder(
                      color: mutedColor,
                      radius: 24,
                      child: SquircleClip(
                        radius: 20,
                        child: SizedBox(
                          width: 180,
                          height: 270,
                          child: ColoredBox(
                            color: isDark
                                ? InktomeColors.cardOnBlack
                                : InktomeColors.cardOnWhite,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: mutedColor,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: InktomeSpacing.lg),

                  Text(
                    'add your first book',
                    style: InktomeTextStyles.headingSmall.copyWith(
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            // Bottom padding so content clears the nav bar
            const SizedBox(
              height: InktomeSpacing.navBarPillHeight + InktomeSpacing.lg,
            ),
          ],
        ),
      ),
    );
  }
}