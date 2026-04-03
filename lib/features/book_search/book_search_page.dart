import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';
import 'package:inktome/core/widgets/search_field.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      // Query arrived pre-filled — fire immediately after first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSubmit());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _searchFocusNode.unfocus();
    setState(() => _searchState = _SearchState.loading);
    // TODO: call BookSearchService(query), then setState to results or empty.
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            // LAYER 1: Body — idle / loading / results / empty.
            // Leaves room at the bottom for the search bar.
            Positioned.fill(
              bottom: InktomeSpacing.navBarPillHeight + InktomeSpacing.lg,
              child: _SearchBody(
                state: _searchState,
                textColor: textColor,
                labelColor: labelColor,
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
enum _SearchState { idle, loading, results, empty }

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.state,
    required this.textColor,
    required this.labelColor,
  });

  final _SearchState state;
  final Color textColor;
  final Color labelColor;

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
        _SearchState.results => const _ResultsGrid(
          key: ValueKey('results'),
          results: [],
        ),
        _SearchState.empty => _EmptyState(
          key: const ValueKey('empty'),
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

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({super.key, required this.results});
  final List<Object> results; // TODO: type as List<BookSearchResult>

  @override
  Widget build(BuildContext context) {
    // TODO: build results grid.
    return const SizedBox.shrink();
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
