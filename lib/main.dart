import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_theme.dart';
import 'package:inktome/core/theme/theme_notifier.dart';
import 'package:inktome/navigation/app_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(prefs),
      child: const MainApp(),
    ),
  );
}

/// Root widget. Consumes ThemeNotifier so the MaterialApp rebuilds
/// when the user switches theme — and nowhere else needs to care.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeNotifier>().mode;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Inktome',
      theme: inktomeLightTheme(),
      darkTheme: inktomeDarkTheme(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
