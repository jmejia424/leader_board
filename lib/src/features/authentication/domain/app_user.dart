typedef UserID = String;

/// Simple class representing the user UID and email.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.emailVerified = false,
    this.displayName,
  });
  final UserID uid;
  final String? email;
  final bool emailVerified;
  final String? displayName;

  Future<void> sendEmailVerification() async {
    // no-op - implemented by subclasses
  }

  Future<bool> isAdmin() {
    return Future.value(false);
  }

  Future<void> forceRefreshIdToken() async {
    // no-op - implemented by subclasses
  }

  // * Here we override methods from [Object] directly rather than using
  // * [Equatable], since this class will be subclassed or implemented
  // * by other classes.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ displayName.hashCode;

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, displayName: $displayName)';
}
