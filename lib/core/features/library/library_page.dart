import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavBarNotifier>().setAction(
        NavAction(icon: plus, onTap: () => showAddBookOverlay(context)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Prevents the keyboard from resizing this scaffold — the overlay
      // handles its own keyboard avoidance independently.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('library')),
      body: Center(child: Text('Library Page', style: textTheme.displayMedium)),
    );
  }
}
