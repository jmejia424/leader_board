// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsService)
const settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends $NotifierProvider<SettingsService, void> {
  const SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  SettingsService create() => SettingsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsServiceHash() => r'b02c0c137a7432e8e7084532ce1058f09f848278';

abstract class _$SettingsService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

@ProviderFor(pinballCollection)
const pinballCollectionProvider = PinballCollectionProvider._();

final class PinballCollectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PinballMachine>>,
          List<PinballMachine>,
          FutureOr<List<PinballMachine>>
        >
    with
        $FutureModifier<List<PinballMachine>>,
        $FutureProvider<List<PinballMachine>> {
  const PinballCollectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinballCollectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinballCollectionHash();

  @$internal
  @override
  $FutureProviderElement<List<PinballMachine>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PinballMachine>> create(Ref ref) {
    return pinballCollection(ref);
  }
}

String _$pinballCollectionHash() => r'e6bf8ddbc75cc35223baa11d164363b35cf2b368';
