import 'package:flutter/material.dart';

class InktomeCard extends StatelessWidget {
  const InktomeCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.cardColor,
    required this.cardBorderRadius,
  });

  final Widget child;
  final Color borderColor;
  final Color cardColor;
  final double cardBorderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        // ? Color.fromRGBO(255, 255, 255, 0.08)  // White shadow for dark mode
        // ? InktomeColors.black.withValues(alpha: 0.45)
        ? Colors.black.withValues(alpha: 0.45)
        : Color.fromRGBO(0, 0, 0, 0.15); // Black shadow for light mode

    return Container(
      decoration: ShapeDecoration(
        color: cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        shadows: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
