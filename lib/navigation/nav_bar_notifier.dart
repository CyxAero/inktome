import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

// MARK: NavAction
/// Describes a single contextual action shown in the nav bar's action pill.
///
/// Each screen that needs an action creates one of these and registers it
/// via [NavBarNotifier.setAction]. Screens with no action (e.g. Settings)
/// call [NavBarNotifier.clearAction] instead.
///
/// ## Example
/// ```dart
/// NavAction(
///   icon: Icons.add,
///   onTap: () => AddBookOverlay.show(context),
/// )
/// ```
class NavAction {
  const NavAction({required this.icon, required this.onTap});

  /// Icon rendered inside the action pill.
  final LucideAnimatedIconData icon;

  /// Called when the user taps the action pill.
  final VoidCallback onTap;
}

// MARK: NavBarNotifier
/// Manages the single contextual action shown on the right side of the nav bar.
///
/// Scoped to [AppShell] via [ChangeNotifierProvider], so it lives for the
/// entire app session and is accessible from any screen with
/// `context.read<NavBarNotifier>()`.
///
/// ## How screens use this
///
/// Register an action in [didChangeDependencies] — not [initState], because
/// Provider ancestors aren't guaranteed to be in the tree yet at that point.
///
/// ```dart
/// @override
/// void didChangeDependencies() {
///   super.didChangeDependencies();
///   context.read<NavBarNotifier>().setAction(NavAction(
///     icon: Icons.add,
///     onTap: () => AddBookOverlay.show(context),
///   ));
/// }
/// ```
///
/// Screens with no action (e.g. Settings) should clear the pill so it
/// doesn't linger from whichever screen the user navigated from:
///
/// ```dart
/// @override
/// void didChangeDependencies() {
///   super.didChangeDependencies();
///   context.read<NavBarNotifier>().clearAction();
/// }
/// ```
class NavBarNotifier extends ChangeNotifier {
  NavAction? _action;

  /// The current action, or null if no action is registered.
  NavAction? get action => _action;

  /// Whether an action is currently registered.
  bool get hasAction => _action != null;

  /// Registers [action] as the current contextual action.
  ///
  /// Replaces any previously registered action. The nav bar will
  /// rebuild and show the action pill automatically.
  void setAction(NavAction action) {
    _action = action;
    notifyListeners();
  }

  /// Removes the current action.
  ///
  /// The nav bar will hide the action pill. Call this from screens
  /// that have no contextual action.
  void clearAction() {
    _action = null;
    notifyListeners();
  }
}
