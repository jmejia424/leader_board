import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Show sign-in icon when not logged in
      return IconButton(
        icon: const Icon(Icons.login),
        onPressed: () {
          context.push('/signIn');
        },
        tooltip: 'Sign In',
      );
    }

    // Show profile picture when logged in
    return IconButton(
      icon: user.photoURL != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL!),
              radius: 16,
            )
          : CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.email?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
      onPressed: () {
        context.push('/profile');
      },
      tooltip: 'Profile',
    );
  }
}
