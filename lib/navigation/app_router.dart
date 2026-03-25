import 'package:go_router/go_router.dart';
import 'package:inktome/core/features/home/home_page.dart';
import 'package:inktome/core/features/library/library_page.dart';
import 'package:inktome/core/features/settings/settings_page.dart';
import 'package:inktome/navigation/app_shell.dart';

/// All routes for Inktome.
///
/// ## Structure
///
/// The app uses a [ShellRoute] so the nav bar persists across the three
/// main tabs without rebuilding. Think of the shell as a picture frame —
/// the frame stays put while the picture inside changes.
///
/// Routes inside the shell (tabs):
///   /home      → HomePage
///   /library   → LibraryPage
///   /settings  → SettingsPage
///
/// Routes outside the shell (full-screen modals — nav bar hidden):
///   /add-book  → AddBookModal  (not yet built — stub for now)
///
/// ## Adding a new modal route
///
/// Add it as a top-level GoRoute alongside the ShellRoute, NOT inside it.
/// That keeps it outside the shell so the nav bar doesn't show.
///
/// ## Adding a new tab
///
/// Add a GoRoute inside the ShellRoute's routes list, then add a
/// corresponding [_InktomeTab] entry in [AppShell].

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // MARK: SHELL ROUTE
    //
    // ShellRoute wraps the three tab screens. The [builder] receives
    // a [child] which is whichever tab screen is currently active.
    // AppShell places that child inside its IndexedStack and draws
    // the nav bar on top.
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LibraryPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);
