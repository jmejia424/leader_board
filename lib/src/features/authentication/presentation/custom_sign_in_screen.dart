import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/features/authentication/data/ui_auth_providers.dart';

class CustomSignInScreen extends ConsumerWidget {
  const CustomSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProviders = ref.watch(authProvidersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: SignInScreen(
        headerBuilder: (context, constraints, _) {
          return const Center(
            child: Image(
              image: AssetImage('assets/images/game_on_logo.png'),
              width: 400,
              height: 400,
              fit: BoxFit.contain,
            ),
          );
        },
        providers: authProviders,
        actions: [
          AuthStateChangeAction<AuthFailed>((context, state) {
            ErrorText.localizeError =
                (BuildContext context, FirebaseAuthException e) {
                  return "Invalid login attempt. Please try again.";
                };
          }),
        ],
      ),
    );
  }
}
