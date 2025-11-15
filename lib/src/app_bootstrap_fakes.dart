import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/app_bootstrap.dart';
import 'package:leader_board/src/exceptions/async_error_logger.dart';

/// Extension methods specific for the "fakes" project configuration
extension AppBootstrapFakes on AppBootstrap {
  /// Creates the top-level [ProviderContainer] by overriding providers with fake
  /// repositories only. This is useful for testing purposes and for running the
  /// app with a "fake" backend.
  ///
  /// Note: all repositories needed by the app can be accessed via providers.
  /// Some of these providers throw an [UnimplementedError] by default.
  ///
  /// Example:
  /// ```dart
  /// @Riverpod(keepAlive: true)
  /// LocalCartRepository localCartRepository(LocalCartRepositoryRef ref) {
  ///   throw UnimplementedError();
  /// }
  /// ```
  ///
  /// As a result, this method does two things:
  /// - create and configure the repositories as desired
  /// - override the default implementations with a list of "overrides"
  Future<ProviderContainer> createFakesProviderContainer({
    bool addDelay = true,
  }) async {
    return ProviderContainer(
      overrides: [
        // repositories
        // services
      ],
      observers: [AsyncErrorLogger()],
    );
  }
}
