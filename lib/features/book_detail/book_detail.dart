import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/data/repositories/book_repository.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:provider/provider.dart';

// MARK: ENTRY POINT
//
// NewBookDetail routes to one of two pages depending on whether the book
// is already in the library. Both pages share the same cover Hero widget
// so the transition works regardless of which page you're coming from.
class NewBookDetail extends StatelessWidget {
  const NewBookDetail({super.key, required this.details});

  final BookDetails details;

  @override
  Widget build(BuildContext context) {
    return details.isInLibrary
        ? _LibraryBookDetailPage(details: details)
        : _SearchBookDetailPage(details: details);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: SEARCH BOOK DETAIL PAGE
//
// Shown when tapping a card in search results.
// The book is not in the library yet — shows metadata and an "Add" button.
// No tabs, no reading state, no edit controls.
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBookDetailPage extends StatelessWidget {
  const _SearchBookDetailPage({required this.details});

  final BookDetails details;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                // Back button — no title, transparent
                _BackBar(),

                // Cover centred with Hero animation
                SliverToBoxAdapter(
                  child: _CoverHero(details: details, isDark: isDark),
                ),

                // Title + author block below cover
                SliverToBoxAdapter(
                  child: _TitleBlock(details: details, isDark: isDark),
                ),

                // Metadata: description, page count, publisher, date, ISBN
                SliverToBoxAdapter(
                  child: _MetadataSection(details: details, isDark: isDark),
                ),

                // Space so the sticky button doesn't overlap content
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // "Add to library" pinned at the bottom
            Positioned(
              left: InktomeSpacing.pagePadding,
              right: InktomeSpacing.pagePadding,
              bottom: InktomeSpacing.lg,
              child: _AddToLibraryButton(details: details),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: LIBRARY BOOK DETAIL PAGE
//
// Shown when tapping a card in the library.
// Subscribes to the DB stream so edits reflect immediately.
// Has tabs for Overview / Details / Sessions.
// ─────────────────────────────────────────────────────────────────────────────
class _LibraryBookDetailPage extends StatefulWidget {
  const _LibraryBookDetailPage({required this.details});

  final BookDetails details;

  @override
  State<_LibraryBookDetailPage> createState() => _LibraryBookDetailPageState();
}

class _LibraryBookDetailPageState extends State<_LibraryBookDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    // 3 tabs: overview, details, sessions
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<BookRepository>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<BookDetails?>(
      // watchBookDetails resolves genres too; falls back to initial data
      // on first frame so there's no blank flash.
      stream: repo.watchBookDetails(widget.details.libraryId!),
      initialData: widget.details,
      builder: (context, snapshot) {
        final details = snapshot.data ?? widget.details;

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: AppBackground(
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                // Back button
                _BackBar(),

                // Cover — same Hero tag so transition from library grid works
                SliverToBoxAdapter(
                  child: _CoverHero(details: details, isDark: isDark),
                ),

                // Title + stat pills (rating, owned, page count)
                SliverToBoxAdapter(
                  child: _TitleBlock(details: details, isDark: isDark),
                ),

                // Tab bar: overview | details | sessions
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    tabBar: _BookTabBar(controller: _tabs, isDark: isDark),
                  ),
                ),
              ],
              // Tab body scrolls within the NestedScrollView
              body: TabBarView(
                controller: _tabs,
                children: [
                  _OverviewTab(details: details, isDark: isDark),
                  _DetailsTab(details: details, isDark: isDark),
                  _SessionsTab(isDark: isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: SHARED WIDGETS
// Used by both search and library detail pages.
// ─────────────────────────────────────────────────────────────────────────────

// MARK: Back Bar
class _BackBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? InktomeColors.white : InktomeColors.black,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }
}

// MARK: Cover Hero
//
// The centred cover widget. Wrapped in a Hero so it animates smoothly
// from the grid card into this page.
//
// The heroTag must match whatever tag was set on the BookCard in the grid.
// Convention: search results use googleBooksId, library books use 'book-${id}'.
//
// The cover is displayed at a fixed size — large enough to be the focal
// point but not so large it dominates on small screens.
class _CoverHero extends StatelessWidget {
  const _CoverHero({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  // Fixed display size for the detail page cover.
  static const double _width = 200.0;
  static const double _height = 300.0;
  static const double _radius = 20.0;

  @override
  Widget build(BuildContext context) {
    final coverPath = details.resolvedCoverPath;
    final heroTag = details.isInLibrary
        ? 'book-${details.libraryId}'
        : details.googleBooksId ?? details.coverSourceUrl ?? details.title;

    return Padding(
      padding: const EdgeInsets.only(
        top: InktomeSpacing.md,
        bottom: InktomeSpacing.lg,
      ),
      child: Center(
        child: Hero(
          tag: heroTag,
          child: SquircleClip(
            radius: _radius,
            child: SizedBox(
              width: _width,
              height: _height,
              child: coverPath != null
                  ? CachedNetworkImage(
                      imageUrl: coverPath,
                      // fill the fixed box without distortion
                      fit: BoxFit.cover,
                      width: _width,
                      height: _height,
                      fadeInDuration: const Duration(milliseconds: 200),
                      errorWidget: (_, _, _) => _DetailCoverPlaceholder(
                        title: details.title,
                        author: details.authorDisplay,
                        isDark: isDark,
                      ),
                    )
                  : _DetailCoverPlaceholder(
                      title: details.title,
                      author: details.authorDisplay,
                      isDark: isDark,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: Detail Cover Placeholder
//
// Shown in the detail page when there's no cover or it fails to load.
// Larger than the grid card placeholder — uses bigger type since there's more room.
class _DetailCoverPlaceholder extends StatelessWidget {
  const _DetailCoverPlaceholder({
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
        padding: const EdgeInsets.all(InktomeSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: InktomeTextStyles.headingMedium.copyWith(
                color: titleColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: InktomeSpacing.sm),
            Text(
              author,
              style: InktomeTextStyles.bodySmall.copyWith(color: authorColor),
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

// MARK: Title Block
//
// Title, subtitle, author shown below the cover on both page types.
// Library variant also shows rating + owned pill + page count.
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            details.title,
            style: InktomeTextStyles.headingMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: InktomeSpacing.xs),
          Text(
            details.authorDisplay,
            style: InktomeTextStyles.bodySmall.copyWith(color: mutedColor),
            textAlign: TextAlign.center,
          ),

          // Stat pills — only for library books
          if (details.isInLibrary) ...[
            const SizedBox(height: InktomeSpacing.md),
            _StatPills(details: details, isDark: isDark),
          ],

          const SizedBox(height: InktomeSpacing.lg),
        ],
      ),
    );
  }
}

// MARK: Stat Pills
//
// Horizontal row showing rating | owned | page count.
// Matches the design mockup's three-column stat strip.
class _StatPills extends StatelessWidget {
  const _StatPills({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;
    final dividerColor = isDark
        ? InktomeColors.greyDark
        : InktomeColors.greyMid;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (details.rating != null)
            _StatItem(
              label: 'Rating',
              value: details.rating!.toStringAsFixed(1),
              isDark: isDark,
            ),
          if (details.rating != null) _Divider(color: dividerColor),
          _StatItem(
            label: 'Owned',
            value: details.isOwned ? '✓' : '—',
            isDark: isDark,
          ),
          if (details.pageCount != null) _Divider(color: dividerColor),
          if (details.pageCount != null)
            _StatItem(
              label: 'Page Count',
              value: '${details.pageCount}',
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: InktomeSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: InktomeTextStyles.label.copyWith(
              color: mutedColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: InktomeSpacing.xs),
          Text(
            value,
            style: InktomeTextStyles.body.copyWith(
              color: textColor,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: color);
  }
}

// MARK: Metadata Section
//
// Description + bibliographic details.
// Used on both search preview and library detail pages.
class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: InktomeSpacing.pagePadding,
        vertical: InktomeSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.description != null) ...[
            Text(
              'Book Description',
              style: InktomeTextStyles.headingSmall.copyWith(color: textColor),
            ),
            const SizedBox(height: InktomeSpacing.sm),
            Text(
              details.description!,
              style: InktomeTextStyles.body.copyWith(color: mutedColor),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: InktomeSpacing.lg),
          ],
          _MetaGrid(details: details, isDark: isDark),
        ],
      ),
    );
  }
}

// MARK: Meta Grid
//
// 2-column grid of label/value pairs.
// Matches the "Language / ISBN / Published / Owned Format" layout in the mockup.
class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    // Only include fields that have values
    final items = <_MetaEntry>[
      if (details.language != null) _MetaEntry('Language', details.language!),
      if (details.pageCount != null)
        _MetaEntry('Page Count', '${details.pageCount}'),
      if (details.isbn != null) _MetaEntry('ISBN', details.isbn!),
      if (details.publisher != null)
        _MetaEntry('Publisher', details.publisher!),
      if (details.publishedDate != null)
        _MetaEntry('Published', details.publishedDate!),
      if (details.ownedFormat != null)
        _MetaEntry('Owned Format', details.ownedFormat!.label),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    // Arrange in pairs for the 2-column grid
    return Wrap(
      spacing: InktomeSpacing.lg,
      runSpacing: InktomeSpacing.md,
      children: items.map((entry) {
        return SizedBox(
          width:
              (MediaQuery.sizeOf(context).width -
                  InktomeSpacing.pagePadding * 2 -
                  InktomeSpacing.lg) /
              2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.label,
                style: InktomeTextStyles.label.copyWith(color: mutedColor),
              ),
              const SizedBox(height: InktomeSpacing.xs),
              Text(
                entry.value,
                style: InktomeTextStyles.bodySmall.copyWith(color: textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MetaEntry {
  const _MetaEntry(this.label, this.value);
  final String label;
  final String value;
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: LIBRARY-ONLY WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// MARK: Book Tab Bar
//
// Three tabs styled to match the Figma mockup.
// Active tab gets the pill treatment; inactive tabs are plain text.
class _BookTabBar extends StatelessWidget {
  const _BookTabBar({required this.controller, required this.isDark});

  final TabController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? InktomeColors.white : InktomeColors.black;
    final inactiveColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;
    final indicatorColor = isDark ? InktomeColors.white : InktomeColors.black;

    return TabBar(
      controller: controller,
      indicatorColor: indicatorColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: activeColor,
      unselectedLabelColor: inactiveColor,
      labelStyle: InktomeTextStyles.button,
      unselectedLabelStyle: InktomeTextStyles.bodySmall,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'overview'),
        Tab(text: 'details'),
        Tab(text: 'sessions'),
      ],
    );
  }
}

// MARK: Tab Bar Delegate
//
// Needed to use TabBar inside a SliverPersistentHeader so it sticks
// below the cover and title when you scroll.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.tabBar});

  final Widget tabBar;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      // Match the app background so it doesn't look like a floating bar
      color: isDark ? InktomeColors.black : InktomeColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}

// MARK: Overview Tab
//
// Status, reading dates, rating — the quick summary view.
// Matches the "overview" tab in the Figma mockup.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(InktomeSpacing.pagePadding),
      child: _MetaGrid(details: details, isDark: isDark),
    );
  }
}

// MARK: Details Tab
//
// Full description + complete bibliographic metadata.
class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.details, required this.isDark});

  final BookDetails details;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(InktomeSpacing.pagePadding),
      child: _MetadataSection(details: details, isDark: isDark),
    );
  }
}

// MARK: Sessions Tab
//
// Reading sessions list — empty state for now.
// Timer and session tracking is post-MVP.
class _SessionsTab extends StatelessWidget {
  const _SessionsTab({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;

    return Center(
      child: Text(
        'no sessions yet',
        style: InktomeTextStyles.headingSmall.copyWith(color: mutedColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: SEARCH-ONLY WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// MARK: Add to Library Button
//
// Pinned at the bottom of the search detail page.
// Calls addBookWithDetails() so genres are written on first insert.
class _AddToLibraryButton extends StatefulWidget {
  const _AddToLibraryButton({required this.details});

  final BookDetails details;

  @override
  State<_AddToLibraryButton> createState() => _AddToLibraryButtonState();
}

class _AddToLibraryButtonState extends State<_AddToLibraryButton> {
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
    final bgColor = isDark ? InktomeColors.white : InktomeColors.black;
    final textColor = isDark ? InktomeColors.black : InktomeColors.white;

    return GestureDetector(
      onTap: _add,
      child: DashedBorder(
        color: bgColor,
        radius: InktomeSpacing.radiusPill,
        child: SquircleClip(
          radius: InktomeSpacing.radiusPill,
          child: ColoredBox(
            color: bgColor,
            child: SizedBox(
              height: InktomeSpacing.navBarPillHeight,
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
                        'Add to library',
                        style: InktomeTextStyles.button.copyWith(
                          color: textColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
