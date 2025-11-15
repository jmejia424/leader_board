// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_submission_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scoreSubmissionRepository)
const scoreSubmissionRepositoryProvider = ScoreSubmissionRepositoryProvider._();

final class ScoreSubmissionRepositoryProvider
    extends
        $FunctionalProvider<
          ScoreSubmissionRepository,
          ScoreSubmissionRepository,
          ScoreSubmissionRepository
        >
    with $Provider<ScoreSubmissionRepository> {
  const ScoreSubmissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scoreSubmissionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scoreSubmissionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScoreSubmissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScoreSubmissionRepository create(Ref ref) {
    return scoreSubmissionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScoreSubmissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScoreSubmissionRepository>(value),
    );
  }
}

String _$scoreSubmissionRepositoryHash() =>
    r'69d23490249c9d3755a671cc8dd242078153575b';

/// Stream provider for user's submissions

@ProviderFor(userSubmissions)
const userSubmissionsProvider = UserSubmissionsFamily._();

/// Stream provider for user's submissions

final class UserSubmissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScoreSubmission>>,
          List<ScoreSubmission>,
          Stream<List<ScoreSubmission>>
        >
    with
        $FutureModifier<List<ScoreSubmission>>,
        $StreamProvider<List<ScoreSubmission>> {
  /// Stream provider for user's submissions
  const UserSubmissionsProvider._({
    required UserSubmissionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userSubmissionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userSubmissionsHash();

  @override
  String toString() {
    return r'userSubmissionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ScoreSubmission>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScoreSubmission>> create(Ref ref) {
    final argument = this.argument as String;
    return userSubmissions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSubmissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSubmissionsHash() => r'fc66f05553ae9c7623fb6db178e381546d62aca0';

/// Stream provider for user's submissions

final class UserSubmissionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ScoreSubmission>>, String> {
  const UserSubmissionsFamily._()
    : super(
        retry: null,
        name: r'userSubmissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for user's submissions

  UserSubmissionsProvider call(String userId) =>
      UserSubmissionsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userSubmissionsProvider';
}

/// Stream provider for a specific submission

@ProviderFor(submissionById)
const submissionByIdProvider = SubmissionByIdFamily._();

/// Stream provider for a specific submission

final class SubmissionByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScoreSubmission?>,
          ScoreSubmission?,
          Stream<ScoreSubmission?>
        >
    with $FutureModifier<ScoreSubmission?>, $StreamProvider<ScoreSubmission?> {
  /// Stream provider for a specific submission
  const SubmissionByIdProvider._({
    required SubmissionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'submissionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$submissionByIdHash();

  @override
  String toString() {
    return r'submissionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ScoreSubmission?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ScoreSubmission?> create(Ref ref) {
    final argument = this.argument as String;
    return submissionById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SubmissionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$submissionByIdHash() => r'48df35f0c54060c6f898fa1a889aca00c703230d';

/// Stream provider for a specific submission

final class SubmissionByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ScoreSubmission?>, String> {
  const SubmissionByIdFamily._()
    : super(
        retry: null,
        name: r'submissionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for a specific submission

  SubmissionByIdProvider call(String submissionId) =>
      SubmissionByIdProvider._(argument: submissionId, from: this);

  @override
  String toString() => r'submissionByIdProvider';
}
