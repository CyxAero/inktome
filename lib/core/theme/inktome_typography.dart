import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inktome/core/theme/inktome_colors.dart';
import 'package:inktome/core/theme/inktome_spacing.dart';

/// Typography scale for Inktome.
///
/// **Text Style Hierarchy:**
/// - [displayLarge], [display] - Maximum impact headers
/// - [headingLarge], [headingMedium], [headingSmall] - Section headers
/// - [bodyLarge], [body], [bodySmall] - Content text
/// - [labelLarge], [labelMedium], [labelSmall] - UI elements
///
/// **Font Families:**
/// - Londrina Solid: 100, 300, 400, 900 (display and headings)
/// - Fraunces: 100, 200, 300, 400, 500, 600, 700, 800, 900 (body and labels)
///
/// See also:
/// * [InktomeColors] for color definitions
/// * [InktomeSpacing] for font sizes and layout
class InktomeTextStyles {
  InktomeTextStyles._();

  // ? DISPLAY FONTS
  /// 89.7sp — Maximum impact. Single word or very short phrase only.
  static TextStyle get displayLarge => _displayLarge;
  static final TextStyle _displayLarge = GoogleFonts.londrinaSolid(
    fontSize: InktomeSpacing.displayLarge,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.5,
    height: 0.95,
  );

  /// 67.3sp - Large empty-state messages, prominent screen identifiers.
  static TextStyle get display => _display;
  static final TextStyle _display = GoogleFonts.londrinaSolid(
    fontSize: InktomeSpacing.display,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.0,
    height: 1.0,
  );

  /// Large Display style with custom color
  static TextStyle displayLargeWithColor(Color color) =>
      _displayLarge.copyWith(color: color);

  /// Display style with custom color
  static TextStyle displayWithColor(Color color) =>
      _display.copyWith(color: color);

  // ? HEADING FONTS
  /// 48.0sp — Main screen titles
  static TextStyle get headingLarge => _headingLarge;
  static final TextStyle _headingLarge = GoogleFonts.londrinaSolid(
    fontSize: InktomeSpacing.headingLarge,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    height: 1.05,
  );

  /// 36.0sp - Section titles
  static TextStyle get headingMedium => _headingMedium;
  static final TextStyle _headingMedium = GoogleFonts.londrinaSolid(
    fontSize: InktomeSpacing.headingMedium,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    height: 1.15,
  );

  /// 28.0sp — Sub-section headers
  static TextStyle get headingSmall => _headingSmall;
  static final TextStyle _headingSmall = GoogleFonts.londrinaSolid(
    fontSize: InktomeSpacing.headingSmall,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.2,
    height: 1.2,
  );

  /// Heading styles with custom colors
  static TextStyle headingLargeWithColor(Color color) =>
      _headingLarge.copyWith(color: color);
  static TextStyle headingMediumWithColor(Color color) =>
      _headingMedium.copyWith(color: color);
  static TextStyle headingSmallWithColor(Color color) =>
      _headingSmall.copyWith(color: color);

  // ? BODY FONTS
  /// 22.0sp — Prominent text/subheadings
  static TextStyle get bodyLarge => _bodyLarge;
  static final TextStyle _bodyLarge = GoogleFonts.fraunces(
    fontSize: InktomeSpacing.bodyLarge,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.5,
  );

  /// 18.0sp — Standard body text.
  static TextStyle get body => _body;
  static final TextStyle _body = GoogleFonts.fraunces(
    fontSize: InktomeSpacing.body,
    fontWeight: FontWeight.w100,
    letterSpacing: 0.1,
    height: 1.65,
  );

  /// 15.0sp — Secondary copy, supporting text, smaller descriptions.
  static TextStyle get bodySmall => _bodySmall;
  static final TextStyle _bodySmall = GoogleFonts.fraunces(
    fontSize: InktomeSpacing.bodySmall,
    fontWeight: FontWeight.w100,
    letterSpacing: 0.1,
    height: 1.55,
  );

  /// Body styles with custom colors
  static TextStyle bodyLargeWithColor(Color color) =>
      _bodyLarge.copyWith(color: color);
  static TextStyle bodyWithColor(Color color) => _body.copyWith(color: color);
  static TextStyle bodySmallWithColor(Color color) =>
      _bodySmall.copyWith(color: color);

  // ? LABEL FONTS
  /// 13.0sp — Tags, chips, UI labels.
  /// Defaults to muted grey — pass a colour for emphasis.
  static TextStyle get labelLarge => _labelLarge;
  static final TextStyle _labelLarge = GoogleFonts.fraunces(
    fontSize: InktomeSpacing.labelLarge,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
  );

  /// 11.0sp — Captions, timestamps, nav labels, metadata.
  static TextStyle get label => _label;
  static final TextStyle _label = GoogleFonts.fraunces(
    fontSize: InktomeSpacing.label,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
  );

  /// 9.0sp — Fine print, de-emphasised hints.
  /// Close to minimum legible size — use sparingly.
  static TextStyle get labelSmall => _labelSmall;
  static final TextStyle _labelSmall = GoogleFonts.fraunces(
    fontSize: InktomeSpacing.labelSmall,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
  );

  /// Label styles with custom colors
  static TextStyle labelLargeWithColor(Color color) =>
      _labelLarge.copyWith(color: color);
  static TextStyle labelWithColor(Color color) => _label.copyWith(color: color);
  static TextStyle labelSmallWithColor(Color color) =>
      _labelSmall.copyWith(color: color);

  // ? BUTTON STYLE
  /// 15.0sp — All button types (filled, outlined, text).
  /// Sized independently for tap target legibility, not on the type scale.
  ///
  /// Default colour is white (filled button on black background).
  /// Pass a colour override for outlined (black) and text variants.
  static TextStyle get button => _button;
  static final TextStyle _button = GoogleFonts.londrinaSolid(
    fontSize: InktomeSpacing.buttonText,
    fontWeight: FontWeight.w100,
    letterSpacing: 0.8,
    height: 1.0,
    color: InktomeColors.white,
  );

  /// Button style with custom color
  static TextStyle buttonWithColor(Color color) =>
      _button.copyWith(color: color);
}
