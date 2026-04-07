import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/data/models/book_details.dart';
import 'package:inktome/core/data/models/book_search_result.dart';
import 'package:inktome/core/data/services/book_search_service.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/book_card.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/core/widgets/search_field.dart';
import 'package:provider/provider.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key, this.initialQuery});

  // Pre-filled from the overlay's search field, or from a barcode scan.
  final String? initialQuery;

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  late final TextEditingController _searchController;
  final _searchFocusNode = FocusNode();
  _SearchState _searchState = _SearchState.idle;
  List<BookSearchResult> _results = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSubmit());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _searchFocusNode.unfocus();
    setState(() {
      _searchState = _SearchState.loading;
      _errorMessage = '';
    });

    final service = context.read<BookSearchService>();
    final outcome = await service.search(query);

    // Guard: widget may have been disposed while the request was in flight.
    if (!mounted) return;

    setState(() {
      switch (outcome) {
        case SearchSuccess(:final results):
          _results = results;
          _searchState = _SearchState.results;
        case SearchEmpty():
          _results = [];
          _searchState = _SearchState.empty;
        case SearchError(:final message):
          _errorMessage = message;
          _searchState = _SearchState.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final labelColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;
    final inputBg = isDark ? InktomeColors.black : InktomeColors.white;
    final inputSubmitBg = isDark ? InktomeColors.white : InktomeColors.black;
    final inputSubmitTextColor = isDark
        ? InktomeColors.black
        : InktomeColors.white;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = keyboardHeight > 50;

    // Field rests at the bottom with breathing room; rises with keyboard.
    final searchBarBottom = keyboardOpen
        ? keyboardHeight + InktomeSpacing.md
        : InktomeSpacing.lg * 2;

    return AppBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('search results'),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            // LAYER 1: Body — idle / loading / results / empty.
            // Leaves room at the bottom for the search bar.
            Positioned.fill(
              bottom: InktomeSpacing.navBarPillHeight + InktomeSpacing.lg,
              child: _SearchBody(
                state: _searchState,
                textColor: textColor,
                labelColor: labelColor,
                results: _results,
                errorMessage: _errorMessage,
              ),
            ),

            // LAYER 2: Search bar + close button, rise with keyboard together.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: InktomeSpacing.pagePadding,
              right: InktomeSpacing.pagePadding,
              bottom: searchBarBottom,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: _CloseButton(
                      borderColor: textColor,
                      iconColor: textColor,
                      iconBg: inputBg,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(width: InktomeSpacing.xs),

                  // Search bar fills available space.
                  Expanded(
                    child: SearchField(
                      // No animation — the page transition handles the enter.
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      inputBg: inputBg,
                      textColor: textColor,
                      labelColor: labelColor,
                      inputSubmitBg: inputSubmitBg,
                      inputSubmitTextColor: inputSubmitTextColor,
                      onSubmit: (_) => _onSubmit(),
                      // Don't autofocus when a query was pre-filled —
                      // the keyboard would pop up over loading results.
                      autofocus: widget.initialQuery == null,
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

// MARK: SEARCH BODY
enum _SearchState { idle, loading, results, empty, error }

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.state,
    required this.textColor,
    required this.labelColor,
    required this.results,
    required this.errorMessage,
  });

  final _SearchState state;
  final Color textColor;
  final Color labelColor;
  final List<BookSearchResult> results;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    // AnimatedSwitcher gives a clean crossfade between states — no layout
    // jump when transitioning from loading to results or empty.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (state) {
        _SearchState.idle => _IdleState(
          key: const ValueKey('idle'),
          labelColor: labelColor,
        ),
        _SearchState.loading => const _LoadingState(key: ValueKey('loading')),
        _SearchState.results => _ResultsGrid(
          key: const ValueKey('results'),
          results: results,
        ),
        _SearchState.empty => _EmptyState(
          key: const ValueKey('empty'),
          labelColor: labelColor,
        ),
        _SearchState.error => _ErrorState(
          key: const ValueKey('error'),
          message: errorMessage,
          labelColor: labelColor,
        ),
      },
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState({super.key, required this.labelColor});
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: Text(
          'what book are you looking for?',
          textAlign: TextAlign.center,
          style: InktomeTextStyles.headingMediumWithColor(labelColor),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: replace with a branded Inktome loading animation.
    return const Center(child: CircularProgressIndicator());
  }
}

// MARK: RESULTS GRID
//
// 2-column cover grid matching the library mockup.
// Each card is wrapped in a GestureDetector that pushes to the book
// detail preview route, passing the BookDetails via GoRouter's extra param.
//
// Rotation seed is the googleBooksId hashCode — stable across rebuilds
// so the same book always tilts the same way.
class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({super.key, required this.results});

  final List<BookSearchResult> results;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        InktomeSpacing.pagePadding,
        InktomeSpacing.md,
        InktomeSpacing.pagePadding,
        // Extra bottom padding so the last row isn't hidden under the search bar.
        InktomeSpacing.navBarPillHeight + InktomeSpacing.xxxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: InktomeSpacing.md,
        mainAxisSpacing: InktomeSpacing.lg,
        // 2:3 cover ratio with a little extra vertical room for the rotation
        // to breathe without clipping the corners of neighbouring cards.
        childAspectRatio: 0.62,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return GestureDetector(
          onTap: () => context.push(
            '/book/preview',
            extra: BookDetails.fromSearchResult(result),
          ),
          child: BookCard(
            title: result.title,
            author: result.authorDisplay,
            coverUrl: result.coverUrl,
            rotationSeed: result.googleBooksId.hashCode,
            // Tag matches _CoverHero in NewBookDetail for the Hero flight.
            heroTag: result.googleBooksId,
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.labelColor});
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'nothing found.',
        style: InktomeTextStyles.headingMediumWithColor(labelColor),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    super.key,
    required this.message,
    required this.labelColor,
  });
  final String message;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: InktomeTextStyles.headingSmallWithColor(labelColor),
        ),
      ),
    );
  }
}

// MARK: CLOSE BUTTON
class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.borderColor,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });
  final Color borderColor;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorder(
        color: borderColor,
        radius: InktomeSpacing.radiusPill,
        child: SquircleClip(
          radius: InktomeSpacing.radiusPill,
          child: ColoredBox(
            color: iconBg,
            child: Padding(
              padding: const EdgeInsets.all(InktomeSpacing.md),
              child: LucideAnimatedIcon(
                icon: arrow_left,
                color: iconColor,
                size: 28,
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
