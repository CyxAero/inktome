import 'package:flutter/material.dart';

/// Raw colour palette for Inktome.
///
/// These are the only hex values in the entire codebase.
/// Never use a hex literal outside this class.
///
/// Semantic meaning (what a colour is *for*) lives in [InktomeTheme], not here.
///
/// See also:
/// * [InktomeSpacing] for layout dimensions
/// * [InktomeTextStyles] for typography definitions
class InktomeColors {
  InktomeColors._();

  // ? CORE COLORS
  static const Color white = Color(0xFFEDF1F5);
  static const Color black = Color(0xFF080708);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  // ? CARD SURFACES
  // One step away from the background in each direction.
  /// Use cardOnWhite when scaffold is white.
  static const Color cardOnWhite = Color(0xFFE8ECF0);
  /// Use cardOnBlack when scaffold is black.
  static const Color cardOnBlack = Color(0xFF131413);

  // ? NEUTRALS
  // Mid-tones derived from black and white.
  // Used for muted text, inactive states, borders, and dividers.
  // These are the only values between black and white — if you find yourself reaching for another grey, add it here first.

  /// Subtle borders on white bg
  static const Color greyLight = Color(0xFFE2E6EA);
  /// Default input/chip outlines
  static const Color greyMid = Color(0xFFD0D4D8);
  /// Secondary text on white bg
  static const Color greyMuted = Color(0xFF4A4D4A);
  /// Borders on black bg
  static const Color greyDark = Color(0xFF2A2D2A);
  /// Subtle borders on black bg
  static const Color greyDarker = Color(0xFF1E221E);
  /// Secondary text on black bg
  static const Color greyOnDark = Color(0xFFB0B4B0);

  // ? ACCENT
  /// Not used in the current theme. Reserved for future use.
  static const Color richBlue = Color(0xFF191265);

  // ? ERROR
  /// Not used in the current theme. Reserved for future use.
  static const Color brickEmber = Color(0xFFBA2D0B);
}
