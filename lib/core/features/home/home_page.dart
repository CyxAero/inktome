import 'package:flutter/material.dart';
import 'package:inktome/core/widgets/app_background.dart';

/// INKTOME HOME PAGE
///
/// What the user sees when they just open up the app
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        body: Center(child: Text('Home Page', style: textTheme.displayLarge)),
      ),
    );
  }
}
