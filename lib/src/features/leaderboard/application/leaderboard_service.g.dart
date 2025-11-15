// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to watch the current leaderboard reactively.
///
/// This provider maintains a persistent stream subscription and switches
/// the underlying Firestore query when the selected pinball or period changes.

@ProviderFor(currentLeaderboard)
const currentLeaderboardProvider = CurrentLeaderboardProvider._();

/// Provider to watch the current leaderboard reactively.
///
/// This provider maintains a persistent stream subscription and switches
/// the underlying Firestore query when the selected pinball or period changes.

final class CurrentLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<Leaderboard>,
          Leaderboard,
          Stream<Leaderboard>
        >
    with $FutureModifier<Leaderboard>, $StreamProvider<Leaderboard> {
  /// Provider to watch the current leaderboard reactively.
  ///
  /// This provider maintains a persistent stream subscription and switches
  /// the underlying Firestore query when the selected pinball or period changes.
  const CurrentLeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLeaderboardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLeaderboardHash();

  @$internal
  @override
  $StreamProviderElement<Leaderboard> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Leaderboard> create(Ref ref) {
    return currentLeaderboard(ref);
  }
}

String _$currentLeaderboardHash() =>
    r'b9df15773481dcb061570c6943988475ed716f98';
