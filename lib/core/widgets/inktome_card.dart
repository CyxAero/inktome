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
    return Container(
      decoration: ShapeDecoration(
        color: cardColor,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: child,
    );
  }
}
