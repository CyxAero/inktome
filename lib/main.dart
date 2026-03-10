import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_theme.dart';
import 'package:inktome/core/widgets/app_background.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inktome',
      theme: inktomeLightTheme(),
      darkTheme: inktomeDarkTheme(),
      themeMode: ThemeMode.system,
      home: const _HomeStub(),
    );
  }
}

class _HomeStub extends StatelessWidget {
  const _HomeStub();

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
        body: Center(child: Text('Hello.', style: textTheme.displayLarge)),
      ),
    );
  }
}
