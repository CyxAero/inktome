import 'package:flutter/material.dart';

/// INKTOME HOME PAGE
///
/// The first screen the user sees — warm, personal feel.
/// Currently reading, recent activity, and a welcome state
/// for new users will live here.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('inktome')),
      body: Center(child: Text('Home Page', style: textTheme.displayMedium)),
    );
  }
}
