// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_state_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LeaderboardStateController)
const leaderboardStateControllerProvider =
    LeaderboardStateControllerProvider._();

final class LeaderboardStateControllerProvider
    extends $NotifierProvider<LeaderboardStateController, LeaderboardState> {
  const LeaderboardStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardStateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardStateControllerHash();

  @$internal
  @override
  LeaderboardStateController create() => LeaderboardStateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaderboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaderboardState>(value),
    );
  }
}

String _$leaderboardStateControllerHash() =>
    r'b62ab178d43272ee4b8db0807dc6f1af5ea6cb09';

abstract class _$LeaderboardStateController
    extends $Notifier<LeaderboardState> {
  LeaderboardState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LeaderboardState, LeaderboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LeaderboardState, LeaderboardState>,
              LeaderboardState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
