/// **Numeric design tokens for Inktome.**
///
/// **Categories:**
/// - SPACING: Layout gaps, padding, insets (4pt grid)
/// - RADIUS: Border radius values
/// - FONT SIZES: Typography scale (see notes below)
///
/// **Font Scale Approach:**
/// The display cluster ([displayLarge], [display]) is anchored at 89.7sp and 67.3sp
/// - sized for maximum visual impact on mobile.
/// The heading, body, and label clusters step down from there at intervals
/// chosen for readability and clear hierarchy, rather than strict mathematical ratio.
///
/// See also:
/// * [InktomeColors] for color definitions
/// * [InktomeTextStyles] for typography that uses these sizes
class InktomeSpacing {
  InktomeSpacing._();

  // ? LAYOUT SPACING (4pt grid)
  /// 4sp
  static const double xs = 4;
  /// 8sp
  static const double sm = 8;
  /// 16sp
  static const double md = 16;
  /// 24sp
  static const double lg = 24;
  /// 32sp
  static const double xl = 32;
  /// 48sp
  static const double xxl = 48;
  /// 64sp
  static const double xxxl = 64;
  /// 20sp — for page padding
  static const double pagePadding = 20;

  // ? BORDER RADIUS
  /// 8sp
  static const double radiusSm = 8;
  /// 12sp
  static const double radiusMd = 12;
  /// 16sp
  static const double radiusLg = 16;
  /// 24sp
  static const double radiusXl = 24;
  /// 999sp — for pills and fully rounded shapes
  static const double radiusPill = 999;

  // ? FONT SIZES
  // Display
  /// 89.7sp
  static const double displayLarge = 89.7;
  /// 67.3sp
  static const double display = 67.3;

  // Headings
  /// 48sp
  static const double headingLarge = 48.0;
  /// 36sp
  static const double headingMedium = 36.0;
  /// 28sp
  static const double headingSmall = 28.0;

  // Body
  /// 22sp
  static const double bodyLarge = 22.0;
  /// 18sp
  static const double body = 18.0;
  /// 15sp
  static const double bodySmall = 15.0;

  // Label
  /// 13sp
  static const double labelLarge = 13.0;
  /// 11sp
  static const double label = 11.0;
  /// 9sp
  static const double labelSmall = 9.0;

  // Button — not on the scale, sized for tap target legibility
  /// 15sp
  static const double buttonText = 15.0;
}