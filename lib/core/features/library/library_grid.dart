import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/book_card.dart';

// MARK: LibraryGrid
//
// 2-column cover grid driven by a list of Book rows from the DB stream.
// Extracted from LibraryPage so neither file goes long.
//
// Tapping a card navigates to /book/:id, passing a BookDetails via extra
// so the detail page can render on the first frame without waiting for
// its own stream to emit.
//
// The "All ◇" heading at the top matches the Figma design — it's a label
// for the current filter state. Filter switching is post-MVP, so for now
// it's a static label.
class LibraryGrid extends StatelessWidget {
  const LibraryGrid({super.key, required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;

    return CustomScrollView(
      slivers: [
        // SECTION: Header — "All ◇" filter label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              InktomeSpacing.pagePadding,
              InktomeSpacing.lg,
              InktomeSpacing.pagePadding,
              InktomeSpacing.md,
            ),
            child: Row(
              children: [
                Text(
                  'All',
                  style: InktomeTextStyles.headingLarge.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(width: InktomeSpacing.xs),
                // ◇ icon signals the dropdown is coming — static for now
                Icon(Icons.unfold_more, color: textColor, size: 24),
              ],
            ),
          ),
        ),

        // SECTION: 2-column cover grid
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            InktomeSpacing.pagePadding,
            0,
            InktomeSpacing.pagePadding,
            // Extra bottom padding so the last row doesn't sit under the nav bar
            InktomeSpacing.navBarPillHeight + InktomeSpacing.xxl,
          ),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final book = books[index];
              return _LibraryCard(book: book, isDark: isDark);
            }, childCount: books.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: InktomeSpacing.md,
              mainAxisSpacing: InktomeSpacing.lg,
              // Slightly taller than 2:3 so the tilt has room to breathe
              // without clipping neighbouring cards.
              childAspectRatio: 0.62,
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: _LibraryCard
//
// One tappable item in the grid. Wraps BookCard in a GestureDetector and
// handles the navigation. Kept as a private widget so the grid builder
// stays readable.
class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.book, required this.isDark});

  final Book book;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Cover priority: local cached file first, remote URL as fallback.
    // This is the same resolvedCoverPath logic from BookDetails, applied
    // directly here so we don't need to inflate a full BookDetails just
    // to read a string.
    final coverUrl = book.coverLocalPath ?? book.coverSourceUrl;

    return GestureDetector(
      onTap: () {
        // Pass BookDetails via extra so the detail page renders immediately.
        // The page's own DB stream takes over once it emits — no blank flash.
        context.push('/book/${book.id}', extra: BookDetails.fromBook(book));
      },
      child: BookCard(
        heroTag: 'book-${book.id}',
        title: book.title,
        // author is nullable in the DB — show empty string rather than 'null'
        author: book.author ?? '',
        coverUrl: coverUrl,
        // book.id is a stable int — same book always gets the same tilt
        rotationSeed: book.id,
      ),
    );
  }
}
