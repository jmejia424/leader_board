// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_state_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerStateController)
const playerStateControllerProvider = PlayerStateControllerProvider._();

final class PlayerStateControllerProvider
    extends $NotifierProvider<PlayerStateController, PlayerState> {
  const PlayerStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerStateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerStateControllerHash();

  @$internal
  @override
  PlayerStateController create() => PlayerStateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerState>(value),
    );
  }
}

String _$playerStateControllerHash() =>
    r'9f43b89e4aeab1239a6a298c5f19732b6f16cb2f';

abstract class _$PlayerStateController extends $Notifier<PlayerState> {
  PlayerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PlayerState, PlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerState, PlayerState>,
              PlayerState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
