import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Cache the list to prevent unnecessary rebuilds
final _cachedAuthProviders = [EmailAuthProvider()];

final authProvidersProvider = Provider<List<AuthProvider>>((ref) {
  return _cachedAuthProviders;
});
