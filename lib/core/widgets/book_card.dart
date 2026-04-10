import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';

// MARK: BOOK CARD
//
// Squircle-clipped cover card for the search-results grid and library grid.
//
// KEY DECISIONS:
//   - Size is driven by a fixed intrinsic ratio on the outer widget, not
//     AspectRatio inside the clip. AspectRatio inside a GridView cell was
//     the source of blown-up / blank covers — the cell size and the ratio
//     fought each other and the image got unconstrained.
//   - The Hero tag is exposed so the detail page can match it for the
//     shared-element transition. Always pass heroTag from the caller.
//   - Error fallback receives title + author so a failed image load shows
//     the book's text, not a blank grey box.
//   - Rotation is seeded from rotationSeed so the same book always tilts
//     the same way across rebuilds.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.heroTag,
    this.coverUrl,
    this.rotationSeed = 0,
  });

  final String title;
  final String author;
  final String? coverUrl;
  final int rotationSeed;

  // heroTag must be unique per card and must match the tag used in
  // the detail page's Hero widget. Use googleBooksId for search results,
  // 'book-${book.id}' for library books.
  final String heroTag;

  static const double _maxTiltRad = 4 * math.pi / 180;
  static const double _coverRadius = 20;
  static const double _borderRadius = 24;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? InktomeColors.white : InktomeColors.black;
    final tilt = _stableTilt(rotationSeed);

    return Transform.rotate(
      angle: tilt,
      child: Hero(
        tag: heroTag,
        // flightShuttleBuilder keeps the squircle clip during the Hero flight.
        // Without this, Flutter uses a plain rectangle during transition.
        flightShuttleBuilder: (_, animation, _, fromCtx, toCtx) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) =>
                SquircleClip(radius: _coverRadius, child: child!),
            child: fromCtx.widget,
          );
        },
        child: DashedBorder(
          color: borderColor,
          radius: _borderRadius,
          strokeWidth: 1.5,
          dashLength: 12,
          dashGap: 5,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SquircleClip(
              radius: _coverRadius,
              child: _CoverContent(
                url: coverUrl,
                title: title,
                author: author,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _stableTilt(int seed) {
    // final normalised = (seed.abs() % 1000) / 1000.0;

    // Use a better hash function to distribute values more evenly
    final hash = seed.hashCode;
    final normalised = (hash.abs() % 1000) / 1000.0;
    return (normalised - 0.5) * 2 * _maxTiltRad;
  }
}

// MARK: COVER CONTENT
//
// Single widget that decides what to show inside the squircle:
//   - Remote image if URL is present and loads successfully
//   - Title + author placeholder if URL is null OR image fails to load
//
// Keeping both cases in one widget means the error fallback always has
// access to title and author — the previous split (_Cover / _Placeholder
// as siblings) meant the error widget couldn't see them.
class _CoverContent extends StatelessWidget {
  const _CoverContent({
    super.key,
    required this.url,
    required this.title,
    required this.author,
    required this.isDark,
  });

  final String? url;
  final String title;
  final String author;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _TextPlaceholder(title: title, author: author, isDark: isDark);
    }

    return CachedNetworkImage(
      imageUrl: url!,
      // BoxFit.cover fills the squircle without distorting.
      // The parent SquircleClip handles the shape — this just fills it.
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, _) => _Shimmer(isDark: isDark),
      // Error: show text cover rather than blank grey
      errorWidget: (_, _, _) =>
          _TextPlaceholder(title: title, author: author, isDark: isDark),
    );
  }
}

// MARK: SHIMMER
//
// Pulsing placeholder shown while the cover is loading.
// Animates opacity between two values — no extra dependencies.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.isDark});
  final bool isDark;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.4,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark
        ? InktomeColors.cardOnBlack
        : InktomeColors.cardOnWhite;
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => Opacity(
        opacity: _opacity.value,
        child: ColoredBox(color: color, child: const SizedBox.expand()),
      ),
    );
  }
}

// MARK: TEXT PLACEHOLDER
//
// Shown when there's no cover URL or when the remote image fails.
// Uses Londrina Solid for the title so it looks intentional, not broken.
class _TextPlaceholder extends StatelessWidget {
  const _TextPlaceholder({
    super.key,
    required this.title,
    required this.author,
    required this.isDark,
  });

  final String title;
  final String author;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? InktomeColors.cardOnBlack : InktomeColors.cardOnWhite;
    final titleColor = isDark ? InktomeColors.white : InktomeColors.black;
    final authorColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(InktomeSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: InktomeTextStyles.headingSmall.copyWith(
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            if (title.isNotEmpty && author.isNotEmpty)
              const SizedBox(height: InktomeSpacing.xs),
            if (author.isNotEmpty)
              Text(
                author,
                style: InktomeTextStyles.label.copyWith(color: authorColor),
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
