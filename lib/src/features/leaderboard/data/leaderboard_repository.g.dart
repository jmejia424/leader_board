// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leaderboardRepository)
const leaderboardRepositoryProvider = LeaderboardRepositoryProvider._();

final class LeaderboardRepositoryProvider
    extends
        $FunctionalProvider<
          LeaderboardRepository,
          LeaderboardRepository,
          LeaderboardRepository
        >
    with $Provider<LeaderboardRepository> {
  const LeaderboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<LeaderboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LeaderboardRepository create(Ref ref) {
    return leaderboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaderboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaderboardRepository>(value),
    );
  }
}

String _$leaderboardRepositoryHash() =>
    r'dfcd70f8ac3eb5946397d98e5f04f3e7dd2e8da1';

/// Stream provider for all-time leaderboard

@ProviderFor(allTimeLeaderboard)
const allTimeLeaderboardProvider = AllTimeLeaderboardFamily._();

/// Stream provider for all-time leaderboard

final class AllTimeLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Score>>,
          List<Score>,
          Stream<List<Score>>
        >
    with $FutureModifier<List<Score>>, $StreamProvider<List<Score>> {
  /// Stream provider for all-time leaderboard
  const AllTimeLeaderboardProvider._({
    required AllTimeLeaderboardFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'allTimeLeaderboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$allTimeLeaderboardHash();

  @override
  String toString() {
    return r'allTimeLeaderboardProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Score>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Score>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return allTimeLeaderboard(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is AllTimeLeaderboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$allTimeLeaderboardHash() =>
    r'6a25b3e1157a3019495726ce2e8c917a6bacfbfa';

/// Stream provider for all-time leaderboard

final class AllTimeLeaderboardFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Score>>, (String, {int limit})> {
  const AllTimeLeaderboardFamily._()
    : super(
        retry: null,
        name: r'allTimeLeaderboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for all-time leaderboard

  AllTimeLeaderboardProvider call(String pinballId, {int limit = 10}) =>
      AllTimeLeaderboardProvider._(
        argument: (pinballId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'allTimeLeaderboardProvider';
}

/// Stream provider for monthly leaderboard (current month)

@ProviderFor(monthlyLeaderboard)
const monthlyLeaderboardProvider = MonthlyLeaderboardFamily._();

/// Stream provider for monthly leaderboard (current month)

final class MonthlyLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Score>>,
          List<Score>,
          Stream<List<Score>>
        >
    with $FutureModifier<List<Score>>, $StreamProvider<List<Score>> {
  /// Stream provider for monthly leaderboard (current month)
  const MonthlyLeaderboardProvider._({
    required MonthlyLeaderboardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyLeaderboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyLeaderboardHash();

  @override
  String toString() {
    return r'monthlyLeaderboardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Score>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Score>> create(Ref ref) {
    final argument = this.argument as String;
    return monthlyLeaderboard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyLeaderboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyLeaderboardHash() =>
    r'66fbc288c84968f94cc3b722b66ad3b36b492479';

/// Stream provider for monthly leaderboard (current month)

final class MonthlyLeaderboardFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Score>>, String> {
  const MonthlyLeaderboardFamily._()
    : super(
        retry: null,
        name: r'monthlyLeaderboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for monthly leaderboard (current month)

  MonthlyLeaderboardProvider call(String pinballId) =>
      MonthlyLeaderboardProvider._(argument: pinballId, from: this);

  @override
  String toString() => r'monthlyLeaderboardProvider';
}

/// Stream provider for user's score history

@ProviderFor(userScoreHistory)
const userScoreHistoryProvider = UserScoreHistoryFamily._();

/// Stream provider for user's score history

final class UserScoreHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Score>>,
          List<Score>,
          Stream<List<Score>>
        >
    with $FutureModifier<List<Score>>, $StreamProvider<List<Score>> {
  /// Stream provider for user's score history
  const UserScoreHistoryProvider._({
    required UserScoreHistoryFamily super.from,
    required (String, {String? pinballId}) super.argument,
  }) : super(
         retry: null,
         name: r'userScoreHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userScoreHistoryHash();

  @override
  String toString() {
    return r'userScoreHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Score>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Score>> create(Ref ref) {
    final argument = this.argument as (String, {String? pinballId});
    return userScoreHistory(ref, argument.$1, pinballId: argument.pinballId);
  }

  @override
  bool operator ==(Object other) {
    return other is UserScoreHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userScoreHistoryHash() => r'88dbdac260770beebff73040d0ce7d5e570590b5';

/// Stream provider for user's score history

final class UserScoreHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Score>>,
          (String, {String? pinballId})
        > {
  const UserScoreHistoryFamily._()
    : super(
        retry: null,
        name: r'userScoreHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for user's score history

  UserScoreHistoryProvider call(String userId, {String? pinballId}) =>
      UserScoreHistoryProvider._(
        argument: (userId, pinballId: pinballId),
        from: this,
      );

  @override
  String toString() => r'userScoreHistoryProvider';
}
