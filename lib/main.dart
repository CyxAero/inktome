import 'package:flutter/material.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/data/services/book_search_service.dart';
import 'package:inktome/core/theme/inktome_theme.dart';
import 'package:inktome/core/theme/theme_notifier.dart';
import 'package:inktome/navigation/app_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Database is created once here and passed into the repository.
  // Nothing else in the app imports InktomeDatabase directly.
  final db = InktomeDatabase();

  runApp(
    MultiProvider(
      providers: [
        // Theme notifier
        ChangeNotifierProvider(create: (_) => ThemeNotifier(prefs)),
        // BookSearchService is stateless — plain Provider, not ChangeNotifier.
        // Disposed automatically when the app closes.
        Provider(
          create: (_) => BookSearchService(),
          dispose: (_, service) => service.dispose(),
        ),
        // Database provided so it can be disposed cleanly on app close.
        Provider<InktomeDatabase>(
          create: (_) => db,
          dispose: (_, db) => db.close(),
        ),
        // Repository depends on the database — ProxyProvider rebuilds it
        // if the database ever changes (it won't, but this is correct form).
        ProxyProvider<InktomeDatabase, BookRepository>(
          update: (_, db, _) => BookRepository(db),
        ),
      ],
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
