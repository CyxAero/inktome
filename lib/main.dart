import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_theme.dart';
import 'package:inktome/navigation/app_router.dart';

void main() {
  runApp(const MainApp());
}

/// Root of the Inktome app.
///
/// MaterialApp.router hands control to [appRouter] (go_router).
/// Theme, dark theme, and themeMode are set here — nowhere else.
///
/// Provider setup for feature-level state (e.g. LibraryNotifier,
/// BookDetailNotifier) will be added here as features are built.
/// NavBarNotifier is scoped to the shell — see AppShell.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Inktome',
      theme: inktomeLightTheme(),
      darkTheme: inktomeDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
