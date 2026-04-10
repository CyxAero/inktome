import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/features/library/library_grid.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

// MARK: LibraryPage
//
// Shell for the library tab. Owns the stream subscription and decides
// between the empty and filled states. The grid itself lives in
// LibraryGrid so this file stays short.
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    // Register the + action for this tab.
    // postFrameCallback so the NavBarNotifier is available in context.
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

            if (books.isEmpty) {
              return const _EmptyLibrary();
            }

            return LibraryGrid(books: books);
          },
        ),
      ),
    );
  }
}

// MARK: _EmptyLibrary
//
// Shown when the user has no books yet.
// Tapping the dashed placeholder opens the add-book overlay — same
// action as the nav bar + button, so there are two obvious paths to adding.
class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tappable dashed squircle — same visual language as DashedBorder
            // elsewhere in the app, just repurposed as a CTA.
            GestureDetector(
              onTap: () => showAddBookOverlay(context),
              child: DashedBorder(
                color: mutedColor,
                radius: 24,
                child: SquircleClip(
                  radius: 20,
                  child: SizedBox(
                    width: 160,
                    height: 240,
                    child: ColoredBox(
                      color: isDark
                          ? InktomeColors.cardOnBlack
                          : InktomeColors.cardOnWhite,
                      child: Center(
                        child: Icon(Icons.add, size: 36, color: mutedColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: InktomeSpacing.lg),

            Text(
              'your library is empty',
              style: InktomeTextStyles.headingSmall,
            ),
            const SizedBox(height: InktomeSpacing.xs),
            Text(
              'tap + to add your first book',
              style: InktomeTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
