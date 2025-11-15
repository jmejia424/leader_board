import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leader_board/src/features/authentication/data/ui_auth_providers.dart';
import 'package:leader_board/src/routing/app_routes.dart';

class CustomProfileScreen extends ConsumerWidget {
  const CustomProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProviders = ref.watch(authProvidersProvider);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: email == 'jrich3@gmail.com'
            ? [
                IconButton(
                  icon: const Icon(Icons.person),
                  tooltip: 'Player',
                  onPressed: () {
                    context.goNamed(AppRoute.player.name);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.leaderboard),
                  tooltip: 'Leaderboard',
                  onPressed: () {
                    context.goNamed(AppRoute.leaderboard.name);
                  },
                ),
              ]
            : null,
      ),
      body: ProfileScreen(
        appBar: AppBar(toolbarHeight: 0),
        providers: authProviders,
      ),
    );
  }
}
