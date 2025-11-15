import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leader_board/src/features/authentication/presentation/custom_profile_screen.dart';
import 'package:leader_board/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:leader_board/src/features/home/presentation/home_screen.dart';
import 'package:leader_board/src/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:leader_board/src/features/player/presentation/player_screen.dart';

enum AppRoute { signIn, player, leaderboard, home, profile }

// 🔹 Define separate navigator keys for each ShellRoute
final GlobalKey<NavigatorState> mobileNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> posNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  final bool isLoggedIn;
  final bool isAdmin;

  AppRoutes({required this.isLoggedIn, required this.isAdmin});

  // Define the routes for the app
  List<RouteBase> get routes {
    List<RouteBase> combinedRoutes = [];

    // if (!isLoggedIn) {
    //   combinedRoutes.addAll(authRoutes);
    // } else if (isLoggedIn && isAdmin) {
    //   combinedRoutes.addAll(playerRoutes);
    //   combinedRoutes.addAll(leaderBoardRoutes);
    // } else {
    //   combinedRoutes.addAll(playerRoutes);
    // }

    combinedRoutes.addAll(authRoutes);
    combinedRoutes.addAll(playerRoutes);
    combinedRoutes.addAll(leaderBoardRoutes);

    return combinedRoutes;
  }

  final List<RouteBase> authRoutes = [
    GoRoute(
      path: '/signIn',
      name: AppRoute.signIn.name,
      builder: (context, state) => const CustomSignInScreen(),
    ),
  ];

  final List<RouteBase> playerRoutes = [
    GoRoute(
      path: '/home',
      name: AppRoute.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/player',
      name: AppRoute.player.name,
      builder: (context, state) => const PlayerScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: AppRoute.profile.name,
      builder: (context, state) => const CustomProfileScreen(),
    ),
  ];
  final List<RouteBase> leaderBoardRoutes = [
    GoRoute(
      path: '/leaderboard',
      name: AppRoute.leaderboard.name,
      builder: (context, state) => const LeaderBoardScreen(),
    ),
  ];
}
