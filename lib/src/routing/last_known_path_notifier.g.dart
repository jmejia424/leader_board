// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_known_path_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LastKnownPathNotifier)
const lastKnownPathProvider = LastKnownPathNotifierProvider._();

final class LastKnownPathNotifierProvider
    extends $NotifierProvider<LastKnownPathNotifier, String> {
  const LastKnownPathNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastKnownPathProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastKnownPathNotifierHash();

  @$internal
  @override
  LastKnownPathNotifier create() => LastKnownPathNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$lastKnownPathNotifierHash() =>
    r'e00aecf12ced9e8305808aafb27d694a6066dfff';

abstract class _$LastKnownPathNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
