import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_theme.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
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
      home: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Inktome", style: InktomeTextStyles.headingLarge),
          ),
          body: Center(
            child: Text("Hello.", style: InktomeTextStyles.displayLarge),
          ),
        ),
      ),
    );
  }
}
