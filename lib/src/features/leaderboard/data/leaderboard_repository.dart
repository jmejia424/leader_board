import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leader_board/src/features/leaderboard/domain/score.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leaderboard_repository.g.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get real-time all-time leaderboard for a pinball machine
  Stream<List<Score>> watchAllTimeLeaderboard(
    String pinballId, {
    int limit = 10,
  }) {
    return _firestore
        .collection('scores')
        .where('pinballId', isEqualTo: pinballId)
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList(),
        );
  }

  /// Get real-time monthly leaderboard
  Stream<List<Score>> watchMonthlyLeaderboard(
    String pinballId, {
    required String month, // Format: "YYYY-MM"
    int limit = 10,
  }) {
    return _firestore
        .collection('scores')
        .where('pinballId', isEqualTo: pinballId)
        .where('month', isEqualTo: month)
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList(),
        );
  }

  /// Get real-time custom date range leaderboard
  /// For single-day competitions or custom periods
  Stream<List<Score>> watchCustomDateRangeLeaderboard(
    String pinballId, {
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) {
    return _firestore
        .collection('scores')
        .where('pinballId', isEqualTo: pinballId)
        .where(
          'submittedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('submittedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('submittedAt')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList(),
        );
  }

  /// Get user's best score for a pinball machine
  Future<Score?> getUserBestScore(String userId, String pinballId) async {
    final snapshot = await _firestore
        .collection('scores')
        .where('userId', isEqualTo: userId)
        .where('pinballId', isEqualTo: pinballId)
        .orderBy('score', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Score.fromFirestore(snapshot.docs.first);
  }

  /// Get user's score history (all scores)
  Stream<List<Score>> watchUserScoreHistory(
    String userId, {
    String? pinballId,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection('scores')
        .where('userId', isEqualTo: userId);

    if (pinballId != null) {
      query = query.where('pinballId', isEqualTo: pinballId);
    }

    return query
        .orderBy('submittedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList(),
        );
  }

  /// Get user's rank on a leaderboard
  Future<int?> getUserRank(String userId, String pinballId) async {
    // Get user's best score
    final userBest = await getUserBestScore(userId, pinballId);
    if (userBest == null) return null;

    // Count how many scores are better
    final higherScores = await _firestore
        .collection('scores')
        .where('pinballId', isEqualTo: pinballId)
        .where('score', isGreaterThan: userBest.score)
        .get();

    return higherScores.docs.length + 1;
  }
}

@Riverpod(keepAlive: true)
LeaderboardRepository leaderboardRepository(Ref ref) {
  return LeaderboardRepository(FirebaseFirestore.instance);
}

/// Stream provider for all-time leaderboard
@riverpod
Stream<List<Score>> allTimeLeaderboard(
  Ref ref,
  String pinballId, {
  int limit = 10,
}) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.watchAllTimeLeaderboard(pinballId, limit: limit);
}

/// Stream provider for monthly leaderboard (current month)
@riverpod
Stream<List<Score>> monthlyLeaderboard(Ref ref, String pinballId) {
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.watchMonthlyLeaderboard(pinballId, month: month);
}

/// Stream provider for user's score history
@riverpod
Stream<List<Score>> userScoreHistory(
  Ref ref,
  String userId, {
  String? pinballId,
}) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.watchUserScoreHistory(userId, pinballId: pinballId);
}
