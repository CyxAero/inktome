import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

/// INKTOME LIBRARY PAGE
///
/// The user's full book collection, switchable between three modes:
///   Status      — grouped by reading status (Reading, Finished, etc.)
///   Collections — user-defined shelves, series, genres
///   All         — flat alphabetical grid with search
///
/// The mode switcher lives in the screen title (Queue app style dropdown).
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('library')),
      body: Center(child: Text('Library Page', style: textTheme.displayMedium)),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavBarNotifier>().setAction(
        NavAction(icon: plus, onTap: () => {}),
      );
    });
  }
}
