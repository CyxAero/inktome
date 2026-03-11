import 'package:flutter/material.dart';
import 'package:inktome/core/widgets/app_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Always read from the theme — never call InktomeTextStyles
    // directly in build methods. The theme carries the correct
    // colour for the current light/dark mode automatically.
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // No style override needed — titleTextStyle in AppBarTheme
          // already carries the correct colour for each mode.
          title: const Text('Inktome'),
        ),
        body: Center(
          child: Text('Settings Page', style: textTheme.displayLarge),
        ),
      ),
    );
  }
}
