import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/features/home/filled_home.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

import 'empty_home.dart';

// MARK: HomeHeader
//
// Common header component used by both empty and filled home states.
// Contains the "Hello, Reader!" greeting that appears at the top
// of the home page regardless of whether the user has books.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: InktomeSpacing.lg),

        // Greeting
        Text(
          'Hello,',
          style: InktomeTextStyles.headingLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w400,
            height: 0.7,
          ),
        ),
        Text(
          'Reader!',
          style: InktomeTextStyles.body.copyWith(
            color: textColor,
            fontSize: 52,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

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
            // Don't render anything until we have data
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final books = snapshot.data!;
            final isEmpty = books.isEmpty;

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Common header with page padding
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: InktomeSpacing.pagePadding,
                    ),
                    child: const HomeHeader(),
                  ),

                  // Body content that changes based on state
                  Expanded(
                    child: isEmpty
                        ? const EmptyHome()
                        : FilledHome(books: books),
                  ),
                  // Expanded(child: EmptyHome()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
