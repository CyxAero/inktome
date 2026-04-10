import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/data/database/inktome_database.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/data/models/book_status.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/features/add_book/add_book_overlay.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

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

            return isEmpty ? const _EmptyHome() : _FilledHome(books: books);
          },
        ),
      ),
    );
  }
}

// MARK: EMPTY HOME
//
// Shown when the user has no books yet.
// Friendly prompt to add their first book — tapping the message
// triggers the same add-book overlay as the nav bar + button.
class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: InktomeSpacing.lg),

            // Greeting
            Text(
              'Hello,',
              style: InktomeTextStyles.headingLarge.copyWith(color: textColor),
            ),
            Text(
              'Reader!',
              style: InktomeTextStyles.display.copyWith(color: textColor),
            ),

            const Spacer(),

            // Empty state prompt — centred in the remaining space
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dashed squircle placeholder — tappable, opens add overlay
                  GestureDetector(
                    onTap: () => showAddBookOverlay(context),
                    child: DashedBorder(
                      color: mutedColor,
                      radius: 24,
                      child: SquircleClip(
                        radius: 20,
                        child: SizedBox(
                          width: 180,
                          height: 270,
                          child: ColoredBox(
                            color: isDark
                                ? InktomeColors.cardOnBlack
                                : InktomeColors.cardOnWhite,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: mutedColor,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: InktomeSpacing.lg),

                  Text(
                    'add your first book',
                    style: InktomeTextStyles.headingSmall.copyWith(
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            // Bottom padding so content clears the nav bar
            const SizedBox(
              height: InktomeSpacing.navBarPillHeight + InktomeSpacing.lg,
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: FILLED HOME
//
// Shown when the user has at least one book.
// Highlights the currently-reading book (or the most recently added if
// none are actively being read). Shows a progress indicator if page
// count is known.
class _FilledHome extends StatelessWidget {
  const _FilledHome({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;

    // Prefer a book with status 'reading'; fall back to most recently added.
    final currentBook = books.firstWhere(
      (b) => b.cachedStatus == BookStatus.reading,
      orElse: () => books.first,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: InktomeSpacing.lg),

            // Greeting
            Text(
              'Hello,',
              style: InktomeTextStyles.headingLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
                height: 0.6,
              ),
            ),
            Text(
              'Reader!',
              style: InktomeTextStyles.body.copyWith(
                color: textColor,
                height: 1.0,
                fontSize: 52,
              ),
            ),

            const SizedBox(height: InktomeSpacing.xxl),

            // Section label
            Center(
              child: Text(
                'Currently Reading',
                style: InktomeTextStyles.body.copyWith(
                  fontSize: 32,
                  height: 0.2,
                  color: textColor,
                ),
              ),
            ),

            // Currently reading card — taps through to the book detail page
            _CurrentlyReadingCard(book: currentBook, isDark: isDark),

            const SizedBox(
              height: InktomeSpacing.navBarPillHeight + InktomeSpacing.xxl,
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: CURRENTLY READING CARD
//
// Large cover card with a reading progress indicator below it.
// Progress is only shown if the book has a known pageCount and a
// current page stored — for now we show a static 0% until page
// tracking is wired in reading sessions.
//
// The stacked-card shadow effect (second card peeking behind) is
// achieved with two overlapping containers, not actual elevation.
class _CurrentlyReadingCard extends StatelessWidget {
  const _CurrentlyReadingCard({required this.book, required this.isDark});

  final Book book;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? InktomeColors.cardOnBlack
        : InktomeColors.cardOnWhite;
    final coverPath = book.coverLocalPath ?? book.coverSourceUrl;

    return GestureDetector(
      onTap: () =>
          context.push('/book/${book.id}', extra: BookDetails.fromBook(book)),
      child: Center(
        child: Column(
          children: [
            // Stack: shadow card behind, real cover in front
            SizedBox(
              width: 200,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow card — slightly offset and rotated, peeking behind
                  Positioned(
                    right: 0,
                    child: Transform.rotate(
                      angle: 0.05,
                      child: SquircleClip(
                        radius: 16,
                        child: Container(
                          width: 180,
                          height: 270,
                          color: cardBg,
                        ),
                      ),
                    ),
                  ),

                  // Main cover card
                  SquircleClip(
                    radius: 16,
                    child: SizedBox(
                      width: 180,
                      height: 270,
                      child: coverPath != null
                          ? CachedNetworkImage(
                              imageUrl: coverPath,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 300),
                            )
                          : ColoredBox(
                              color: cardBg,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    InktomeSpacing.md,
                                  ),
                                  child: Text(
                                    book.title,
                                    style: InktomeTextStyles.headingSmall
                                        .copyWith(
                                          color: isDark
                                              ? InktomeColors.white
                                              : InktomeColors.black,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: InktomeSpacing.md),

            // Progress indicator
            // TODO: replace static 0 with actual current page from reading sessions
            _ProgressBar(progress: 0.0, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// MARK: PROGRESS BAR
//
// Thin horizontal bar showing reading progress as a fraction 0.0–1.0.
// Sits below the cover card on the home page.
// The percentage label floats above the scrubber handle.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.isDark});

  // 0.0 = not started, 1.0 = finished
  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final trackColor = isDark ? InktomeColors.greyDark : InktomeColors.greyMid;
    final fillColor = isDark ? InktomeColors.white : InktomeColors.black;
    final labelColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    final percent = (progress * 100).round();

    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Percentage label above the bar
          Center(
            child: Text(
              '$percent%',
              style: InktomeTextStyles.label.copyWith(color: labelColor),
            ),
          ),
          const SizedBox(height: InktomeSpacing.xs),

          // Track + fill
          ClipRRect(
            borderRadius: BorderRadius.circular(InktomeSpacing.radiusPill),
            child: Stack(
              children: [
                // Track
                Container(height: 4, width: double.infinity, color: trackColor),
                // Fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(height: 4, color: fillColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
