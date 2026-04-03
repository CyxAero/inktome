import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  _SearchState _searchState = _SearchState.idle;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
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
    // TODO: call BookSearchService, then setState to results or empty.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? InktomeColors.white : InktomeColors.black;
    final labelColor = isDark
        ? InktomeColors.greyOnDark
        : InktomeColors.greyMuted;
    final inputBg = isDark
        ? InktomeColors.cardOnBlack
        : InktomeColors.cardOnWhite;
    final inputSubmitBg = isDark ? InktomeColors.white : InktomeColors.black;
    final inputSubmitTextColor = isDark
        ? InktomeColors.black
        : InktomeColors.white;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = keyboardHeight > 50;

    final searchBarBottom = keyboardOpen
        ? keyboardHeight + InktomeSpacing.md
        : InktomeSpacing.lg * 2;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            // LAYER 1: Body — idle / loading / results.
            Positioned.fill(
              bottom: InktomeSpacing.navBarPillHeight + InktomeSpacing.lg,
              child: _SearchBody(
                state: _searchState,
                textColor: textColor,
                labelColor: labelColor,
              ),
            ),

            // LAYER 2: Close button + search bar — anchored to bottom,
            // rises with keyboard. They share one AnimatedPositioned so
            // they always move together.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: InktomeSpacing.pagePadding,
              right: InktomeSpacing.pagePadding,
              bottom: searchBarBottom,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Close button — taps pop the route.
                  _CloseButton(
                    borderColor: textColor,
                    iconColor: textColor,
                    iconBg: inputBg,
                    onTap: () => Navigator.of(context).pop(),
                  ),

                  const SizedBox(width: InktomeSpacing.xs),

                  // Search bar — takes all remaining horizontal space.
                  Expanded(
                    child: _SearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      inputBg: inputBg,
                      textColor: textColor,
                      labelColor: labelColor,
                      submitBg: inputSubmitBg,
                      submitIconColor: inputSubmitTextColor,
                      onSubmit: (_) => _onSubmit(),
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
    return switch (state) {
      _SearchState.idle => _IdleState(textColor: textColor),
      _SearchState.loading => const _LoadingState(),
      _SearchState.results => const _ResultsGrid(results: []),
      _SearchState.empty => _EmptyState(
        textColor: textColor,
        labelColor: labelColor,
      ),
    };
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState({required this.textColor});
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InktomeSpacing.pagePadding,
        ),
        child: Text(
          'what are we looking for?',
          textAlign: TextAlign.center,
          style: InktomeTextStyles.headingMediumWithColor(textColor),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    // TODO: replace with branded animation.
    return const Center(child: CircularProgressIndicator());
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.results});
  final List<Object> results; // TODO: type as List<BookSearchResult>

  @override
  Widget build(BuildContext context) {
    // TODO: build grid from results.
    return const SizedBox.shrink();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textColor, required this.labelColor});
  final Color textColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'nothing here.',
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
                icon: x,
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

// MARK: SEARCH BAR

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.inputBg,
    required this.textColor,
    required this.labelColor,
    required this.submitBg,
    required this.submitIconColor,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Color inputBg;
  final Color textColor;
  final Color labelColor;
  final Color submitBg;
  final Color submitIconColor;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: labelColor,
      radius: InktomeSpacing.radiusLg,
      child: SquircleClip(
        radius: InktomeSpacing.radiusLg,
        child: ColoredBox(
          color: inputBg,
          child: Padding(
            padding: const EdgeInsets.all(InktomeSpacing.sm),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmit,
              style: InktomeTextStyles.buttonWithColor(
                textColor,
              ).copyWith(fontSize: 18),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: InktomeSpacing.md,
                  vertical: InktomeSpacing.md,
                ),
                hintText: 'title, author or isbn',
                hintStyle: InktomeTextStyles.buttonWithColor(
                  labelColor,
                ).copyWith(fontSize: 18),
                suffixIcon: SizedBox(
                  width: 48,
                  height: 48,
                  child: SquircleClip(
                    radius: InktomeSpacing.radiusMd,
                    child: ColoredBox(
                      color: submitBg,
                      child: Center(
                        child: IgnorePointer(
                          child: LucideAnimatedIcon(
                            icon: arrow_right,
                            color: submitIconColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
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
