import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

import 'empty_home.dart';
import 'filled_home.dart';

// MARK: HomePage
//
// Shell for the home tab. Owns the stream subscription and decides
// between the empty and filled states. The actual UI for each state
// lives in separate files to keep this file short and focused.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final repo = context.read<BookRepository>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: StreamBuilder<List<Book>>(
          stream: repo.watchAllBooks(),
          builder: (context, snapshot) {
            final books = snapshot.data ?? [];
            final isEmpty = books.isEmpty;

            return isEmpty ? const EmptyHome() : FilledHome(books: books);
          },
        ),
      ),
    );
  }
}
