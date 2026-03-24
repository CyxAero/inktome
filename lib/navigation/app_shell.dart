import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inktome/core/widgets/app_background.dart';
import 'package:inktome/core/widgets/inktome_nav_bar.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

/// The persistent shell that wraps all tab screens.
///
/// AppShell owns the nav bar and keeps it alive across tab switches.
/// The [child] argument comes from go_router's ShellRoute — it's
/// whichever tab screen is currently active.
///
/// ## Widget tree
///
/// ```
/// AppShell
///   └── Stack
///         ├── child  (the active tab screen, fills the stack)
///         └── Positioned(bottom) — InktomeNavBar
/// ```
///
/// The nav bar floats over the screen content via the Stack.
/// Screens should add bottom padding equal to the nav bar height
/// so their scrollable content isn't hidden behind it.
/// A good approximation is InktomeSpacing.navBarHeight (defined
/// when you build out individual screens).
///
/// ## Tab order
///
/// Must match the order of routes in [appRouter]'s ShellRoute.
/// If you add a tab, add it to [_tabs] AND to the router.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  /// The active screen from go_router. Do not store this — it updates
  /// automatically as the user navigates between tabs.
  final Widget child;

  /// The three main tab destinations, in display order.
  ///
  /// [label] is shown in Pill 1. [path] must match the GoRoute path
  /// in [appRouter] exactly — go_router uses it to push the route.
  static const _tabs = [
    _InktomeTab(label: 'home', path: '/home'),
    _InktomeTab(label: 'library', path: '/library'),
    _InktomeTab(label: 'settings', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    // Work out which tab is selected by matching the current location
    // against each tab's path. GoRouter.of(context).state isn't
    // available here, but context.go(path) and GoRouterState work fine.
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _tabs.indexWhere(
      (tab) => location.startsWith(tab.path),
    );

    return ChangeNotifierProvider(
      // NavBarNotifier is scoped to the shell — it lives as long as the
      // shell does, which is the entire app session. Screens access it
      // via context.read<NavBarNotifier>() to register their actions.
      create: (_) => NavBarNotifier(),
      child: AppBackground(
        child: Stack(
          children: [
            // MARK: SCREEN CONTENT
            // The child fills the entire stack, including behind the
            // nav bar. Screens that have scrollable content should add
            // bottom padding so the last item isn't hidden by the pill.
            child,

            // MARK: FLOATING NAV BAR
            // Positioned at the bottom, above the screen content.
            // SafeArea is handled inside InktomeNavBar itself so it
            // can account for the system gesture bar correctly.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: InktomeNavBar(
                tabs: _tabs
                    .map((t) => NavTab(label: t.label, path: t.path))
                    .toList(),
                selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                onTabSelected: (index) => context.go(_tabs[index].path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for a single tab destination.
class _InktomeTab {
  const _InktomeTab({required this.label, required this.path});
  final String label;
  final String path;
}
