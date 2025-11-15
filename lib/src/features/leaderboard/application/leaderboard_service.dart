import 'dart:async';

import 'package:leader_board/src/features/leaderboard/application/leaderboard_state_controller.dart';
import 'package:leader_board/src/features/leaderboard/data/leaderboard_repository.dart';
import 'package:leader_board/src/features/leaderboard/domain/leaderboard.dart';
import 'package:leader_board/src/features/leaderboard/domain/score.dart';
import 'package:leader_board/src/features/settings/application/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leaderboard_service.g.dart';

/// Provider to watch the current leaderboard reactively.
///
/// This provider maintains a persistent stream subscription and switches
/// the underlying Firestore query when the selected pinball or period changes.
@Riverpod(keepAlive: true)
Stream<Leaderboard> currentLeaderboard(Ref ref) {
  final controller = StreamController<Leaderboard>();
  StreamSubscription<List<Score>>? subscription;

  void updateStream() {
    final state = ref.read(leaderboardStateControllerProvider);
    final repository = ref.read(leaderboardRepositoryProvider);
    final pinballsAsync = ref.read(pinballCollectionProvider);

    // Cancel previous subscription
    subscription?.cancel();

    // If no pinball selected, emit empty leaderboard
    if (state.selectedPinballId == null) {
      controller.add(
        const Leaderboard(
          pinballId: '',
          pinballName: 'No Pinball Selected',
          period: LeaderboardPeriod.allTime,
          scores: [],
        ),
      );
      return;
    }

    // Get pinball name
    String pinballName = 'Loading...';
    pinballsAsync.whenData((pinballs) {
      final matches = pinballs.where((p) => p.id == state.selectedPinballId);
      if (matches.isNotEmpty) {
        pinballName = matches.first.name;
      } else {
        pinballName = 'Unknown';
      }
    });

    // Choose the underlying score stream based on period
    Stream<List<Score>> scoresStream;
    DateTime? startDate;
    DateTime? endDate;

    switch (state.selectedPeriod) {
      case LeaderboardPeriod.allTime:
        scoresStream = repository.watchAllTimeLeaderboard(
          state.selectedPinballId!,
          limit: 10,
        );
        break;
      case LeaderboardPeriod.monthly:
        scoresStream = repository.watchMonthlyLeaderboard(
          state.selectedPinballId!,
          month: state.currentMonth,
        );
        startDate = DateTime.parse('${state.currentMonth}-01');
        endDate = DateTime(startDate.year, startDate.month + 1, 0);
        break;
      case LeaderboardPeriod.custom:
        if (state.customStartDate != null && state.customEndDate != null) {
          scoresStream = repository.watchCustomDateRangeLeaderboard(
            state.selectedPinballId!,
            startDate: state.customStartDate!,
            endDate: state.customEndDate!,
          );
          startDate = state.customStartDate;
          endDate = state.customEndDate;
        } else {
          scoresStream = repository.watchAllTimeLeaderboard(
            state.selectedPinballId!,
            limit: 10,
          );
        }
        break;
    }

    // Subscribe to the score stream and map to leaderboard
    subscription = scoresStream.listen(
      (scores) {
        if (!controller.isClosed) {
          controller.add(
            Leaderboard(
              pinballId: state.selectedPinballId!,
              pinballName: pinballName,
              period: state.selectedPeriod,
              scores: scores,
              startDate: startDate,
              endDate: endDate,
            ),
          );
        }
      },
      onError: (error, stackTrace) {
        print('❌ Error loading leaderboard for ${state.selectedPinballId}');
        print('Error: $error');

        if (!controller.isClosed) {
          controller.add(
            Leaderboard(
              pinballId: state.selectedPinballId!,
              pinballName: pinballName,
              period: state.selectedPeriod,
              scores: [],
              startDate: startDate,
              endDate: endDate,
            ),
          );
        }
      },
    );
  }

  // Initial stream setup
  updateStream();

  // Listen for state changes and update the stream
  ref.listen(leaderboardStateControllerProvider, (_, __) {
    updateStream();
  });

  // Cleanup
  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  return controller.stream;
}
