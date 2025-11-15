import 'package:leader_board/src/features/leaderboard/application/leaderboard_state.dart';
import 'package:leader_board/src/features/leaderboard/domain/leaderboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leaderboard_state_controller.g.dart';

@Riverpod(keepAlive: true)
class LeaderboardStateController extends _$LeaderboardStateController {
  @override
  LeaderboardState build() {
    return const LeaderboardState();
  }

  void setSelectedPinball(String pinballId) {
    state = state.copyWith(selectedPinballId: pinballId);
  }

  void setSelectedPeriod(LeaderboardPeriod period) {
    state = state.copyWith(
      selectedPeriod: period,
      clearCustomDates: period != LeaderboardPeriod.custom,
    );
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(
      selectedPeriod: LeaderboardPeriod.custom,
      customStartDate: startDate,
      customEndDate: endDate,
    );
  }

  void setMonthlyPeriod(DateTime date) {
    state = state.copyWith(
      selectedPeriod: LeaderboardPeriod.monthly,
      customStartDate: date,
    );
  }

  void reset() {
    state = const LeaderboardState();
  }
}
