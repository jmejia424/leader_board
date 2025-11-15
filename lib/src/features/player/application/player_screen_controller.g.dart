// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerScreenController)
const playerScreenControllerProvider = PlayerScreenControllerProvider._();

final class PlayerScreenControllerProvider
    extends $AsyncNotifierProvider<PlayerScreenController, void> {
  const PlayerScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerScreenControllerHash();

  @$internal
  @override
  PlayerScreenController create() => PlayerScreenController();
}

String _$playerScreenControllerHash() =>
    r'dcfe8d0ad97e5ecbd1d4e4adde4127b8e529de06';

abstract class _$PlayerScreenController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
