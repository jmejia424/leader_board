import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leader_board/src/features/authentication/data/auth_repository.dart';
import 'package:leader_board/src/routing/app_routes.dart';
import 'package:leader_board/src/routing/go_router_refresh_stream.dart';
import 'package:leader_board/src/routing/last_known_path_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Read auth repository - we use refreshListenable to watch for auth changes
  final authRepository = ref.read(authRepositoryProvider);

  final router = GoRouter(
    initialLocation: ref.read(lastKnownPathProvider),
    debugLogDiagnostics: true,
    routes: AppRoutes(
      isLoggedIn: authRepository.currentUser != null,
      isAdmin: false, // Don't evaluate admin status here - do it in redirect
    ).routes,
    redirect: (context, state) async {
      debugPrint("🔄 GoRouter Redirect Evaluating: ${state.uri.path}");
      final user = authRepository.currentUser;
      debugPrint("Current user in redirect: $user");

      final isLoggedIn = user != null;
      final path = state.uri.path;

      // Allow sign-in page when not logged in
      if (path == '/signIn' && !isLoggedIn) {
        return null;
      }

      // Redirect to appropriate page after signing in
      if (path == '/signIn' && isLoggedIn) {
        final isAdmin = await user.isAdmin();
        if (isAdmin) {
          // Redirect admin users to the leaderboard page
          return '/leaderboard';
        } else {
          // Redirect non-admin users to the player page
          return '/player';
        }
      }

      // Redirect to sign-in if not logged in and trying to access protected routes
      if (!isLoggedIn && path != '/signIn') {
        return '/signIn';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Path: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/player'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
  );

  ref.onDispose(() {
    router.dispose();
  });

  router.routeInformationProvider.addListener(() {
    final currentPath = router.routeInformationProvider.value.uri.path;
    debugPrint("🔍 GoRouter Route Information: $currentPath");
    ref.read(lastKnownPathProvider.notifier).updatePath(currentPath);
  });

  return router;
});
