import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

/// A single action circle in the contextual nav area.
///
/// The primary action (e.g. '+') is always registered via [NavBarNotifier.setPrimaryAction].
/// Secondary actions (e.g. search) are registered via [NavBarNotifier.setSecondaryActions]
/// and stack above the primary circle, each as their own independent circle.
///
/// Usage in a screen:
/// ```dart
/// @override
/// void didChangeDependencies() {
///   super.didChangeDependencies();
///   WidgetsBinding.instance.addPostFrameCallback((_) {
///     if (!mounted) return;
///     context.read<NavBarNotifier>().setPrimaryAction(
///       NavAction(icon: LucideAnimatedIcon(icon: plus), onTap: _openAddBook),
///     );
///     // Optional — only when this screen needs extra actions:
///     context.read<NavBarNotifier>().setSecondaryActions([
///       NavAction(icon: LucideAnimatedIcon(icon: search), onTap: _openSearch),
///     ]);
///   });
/// }
/// ```
class NavAction {
  const NavAction({required this.icon, required this.onTap});

  /// The animated Lucide icon displayed inside the circle.
  final LucideAnimatedIcon icon;

  /// Called when the user taps this circle.
  final VoidCallback onTap;
}

/// Controls the contextual action circles on the right side of the nav bar.
///
/// ## Structure
///
/// There are two separate slots:
///
/// [primaryAction] — always visible, sits at the bottom of the action column.
///   Every tab registers one. Home/Library use '+'. Settings uses a theme toggle.
///
/// [secondaryActions] — optional, stack above the primary circle (bottom-up).
///   Most screens leave this empty. Library's 'All' mode adds a search circle.
///   Clear them when switching away via [clearSecondaryActions].
///
/// ## Why split primary and secondary?
///
/// The primary circle never disappears — it just changes icon per tab.
/// Secondary circles slide in and out independently above it.
/// Keeping them separate means the primary circle never animates position
/// when a secondary appears or disappears.
class NavBarNotifier extends ChangeNotifier {}
