import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';
import 'package:inktome/core/theme/inktome_typography.dart';
import 'package:inktome/core/widgets/custom_dashed_border.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.animation,
    required this.focusNode,
    required this.controller,
    required this.inputBg,
    required this.textColor,
    required this.labelColor,
    required this.inputSubmitBg,
    required this.inputSubmitTextColor,
    required this.onSubmit,
  });

  final Animation<double> animation;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color inputBg;
  final Color textColor;
  final Color labelColor;
  final Color inputSubmitBg;
  final Color inputSubmitTextColor;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: InktomeSpacing.xs),
            child: GestureDetector(
              onTap: focusNode.requestFocus,
              child: Text(
                'SEARCH ONLINE FOR MY BOOK',
                style: InktomeTextStyles.buttonWithColor(
                  textColor,
                ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          DashedBorder(
            color: labelColor,
            radius: InktomeSpacing.radiusLg,
            child: SquircleClip(
              radius: InktomeSpacing.radiusLg,
              child: ColoredBox(
                color: inputBg,
                child: Padding(
                  padding: const EdgeInsets.all(InktomeSpacing.sm),
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSubmit,
                    style: InktomeTextStyles.buttonWithColor(
                      textColor,
                    ).copyWith(fontSize: 18),
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: InktomeSpacing.xs,
                        vertical: InktomeSpacing.md,
                      ),
                      hintText: 'enter title, author or isbn',
                      hintStyle: InktomeTextStyles.buttonWithColor(
                        labelColor,
                      ).copyWith(fontSize: 18),
                      suffixIcon: SizedBox(
                        width: 48,
                        height: 48,
                        child: SquircleClip(
                          radius: InktomeSpacing.radiusMd,
                          child: ColoredBox(
                            color: inputSubmitBg,
                            child: Center(
                              child: IgnorePointer(
                                child: LucideAnimatedIcon(
                                  icon: arrow_right,
                                  color: inputSubmitTextColor,
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
          ),
        ],
      ),
    );
  }
}
