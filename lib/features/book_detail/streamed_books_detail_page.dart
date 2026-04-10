import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:provider/provider.dart';

class StreamedBooksDetailPage extends StatefulWidget {
  const StreamedBooksDetailPage({super.key, required this.details});

  final BookDetails details;

  @override
  State<StreamedBooksDetailPage> createState() =>
      _StreamedBooksDetailPageState();
}

class _StreamedBooksDetailPageState extends State<StreamedBooksDetailPage> {
  bool _loading = false;

  Future<void> _add() async {
    if (_loading) return;
    setState(() => _loading = true);

    final repo = context.read<BookRepository>();

    final newId = await repo.addBookWithDetails(
      companion: widget.details.toNewBookCompanion(),
      genreNames: widget.details.genres,
    );

    // Cover download is fire-and-forget — don't block the navigation on it.
    // CoverService picks up in the background; updateCoverPath will update
    // the DB row once it's done.
    if (!mounted) return;
    setState(() => _loading = false);

    // Replace the preview route so back returns to search, not a stale preview
    context.pushReplacement('/book/$newId');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Defining colors for widget
    final borderColor = isDark ? InktomeColors.white : InktomeColors.black;
    final iconColor = isDark ? InktomeColors.white : InktomeColors.black;
    final iconBg = isDark ? InktomeColors.black : InktomeColors.white;
    final buttonBg = isDark ? InktomeColors.white : InktomeColors.black;
    final textColor = isDark ? InktomeColors.black : InktomeColors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            // MARK: Page Body
            Positioned.fill(
              // Creating additional space at the bottom to account for the
              // bottom bar
              bottom: InktomeSpacing.navBarPillHeight + InktomeSpacing.lg,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: InktomeSpacing.pagePadding,
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: InktomeSpacing.xxl),
                    _HeroBookCover(isDark: isDark, bookDetails: widget.details),
                    const SizedBox(height: InktomeSpacing.md),
                    _BookInfo(isDark: isDark, bookDetails: widget.details),
                  ],
                ),
              ),
            ),

            // MARK: Page Bottom Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: InktomeSpacing.pagePadding,
              right: InktomeSpacing.pagePadding,
              bottom: InktomeSpacing.md * 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MARK: Close/Back Button
                  SizedBox(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: DashedBorder(
                        color: borderColor,
                        radius: InktomeSpacing.radiusPill,
                        child: SquircleClip(
                          radius: InktomeSpacing.radiusPill,
                          child: ColoredBox(
                            color: iconBg,
                            child: Padding(
                              padding: const EdgeInsets.all(InktomeSpacing.sm),
                              child: LucideAnimatedIcon(
                                icon: arrow_left,
                                color: iconColor,
                                size: 28,
                                onTap: () => context.pop(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: InktomeSpacing.sm),

                  // MARK: Add to library button
                  GestureDetector(
                    onTap: _add,
                    child: DashedBorder(
                      color: borderColor,
                      radius: InktomeSpacing.radiusLg,
                      child: SquircleClip(
                        radius: InktomeSpacing.radiusLg,
                        child: ColoredBox(
                          color: buttonBg,
                          child: Padding(
                            padding: const EdgeInsets.all(InktomeSpacing.md),
                            child: Center(
                              child: _loading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: textColor,
                                      ),
                                    )
                                  : Text(
                                      'add book',
                                      style: InktomeTextStyles.button.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: _HeroBookCover
class _HeroBookCover extends StatelessWidget {
  const _HeroBookCover({required this.isDark, required this.bookDetails});

  final bool isDark;
  final BookDetails bookDetails;

  @override
  Widget build(BuildContext context) {
    final coverPath = bookDetails.resolvedCoverPath;
    final heroTag = bookDetails.isInLibrary
        ? 'book-${bookDetails.libraryId}'
        : bookDetails.coverSourceUrl ?? bookDetails.title;

    final borderColor = isDark ? InktomeColors.white : InktomeColors.black;

    final bookWidth = MediaQuery.sizeOf(context).width * 0.80;

    return Hero(
      tag: heroTag,
      child: SizedBox(
        width: bookWidth,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: DashedBorder(
            color: borderColor,
            radius: 32,
            child: Padding(
              padding: const EdgeInsets.all(InktomeSpacing.xs),
              child: SquircleClip(
                radius: 28,
                child: coverPath != null
                    ? CachedNetworkImage(
                        imageUrl: coverPath,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 200),
                        errorWidget: (_, _, _) => _EmptyBookCover(
                          title: bookDetails.title,
                          author: bookDetails.author ?? 'Unknown author',
                          textColor: isDark
                              ? InktomeColors.white
                              : InktomeColors.black,
                          bgColor: isDark
                              ? InktomeColors.black
                              : InktomeColors.white,
                        ),
                      )
                    : _EmptyBookCover(
                        title: bookDetails.title,
                        author: bookDetails.author ?? 'Unknown author',
                        textColor: isDark
                            ? InktomeColors.white
                            : InktomeColors.black,
                        bgColor: isDark
                            ? InktomeColors.black
                            : InktomeColors.white,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: EmptyBookCover (Used in [_HeroBookCover])
class _EmptyBookCover extends StatelessWidget {
  const _EmptyBookCover({
    required this.title,
    required this.author,
    required this.textColor,
    required this.bgColor,
  });

  final String title;
  final String author;
  final Color textColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(InktomeSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: InktomeTextStyles.headingSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: InktomeSpacing.sm),
            Text(
              author,
              style: InktomeTextStyles.bodySmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: _BookInfo
class _BookInfo extends StatelessWidget {
  const _BookInfo({required this.isDark, required this.bookDetails});

  final bool isDark;
  final BookDetails bookDetails;

  @override
  Widget build(BuildContext context) {
    Color textColor = isDark ? InktomeColors.white : InktomeColors.black;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // spacing: InktomeSpacing.xs,
      children: [
        Text(
          bookDetails.title,
          textAlign: TextAlign.center,
          style: InktomeTextStyles.headingSmall.copyWith(color: textColor),
        ),
        Text(
          bookDetails.author ?? 'Unknown author',
          textAlign: TextAlign.center,
          style: InktomeTextStyles.bodyLarge.copyWith(
            color: textColor,
            height: 1,
          ),
        ),
      ],
    );
  }
}
