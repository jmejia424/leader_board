import 'package:equatable/equatable.dart';
import 'package:leader_board/src/features/leaderboard/domain/leaderboard.dart';

/// State for the leaderboard feature
class LeaderboardState extends Equatable {
  final String? selectedPinballId;
  final LeaderboardPeriod selectedPeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const LeaderboardState({
    this.selectedPinballId,
    this.selectedPeriod = LeaderboardPeriod.allTime,
    this.customStartDate,
    this.customEndDate,
  });

  /// Returns the month string in format "YYYY-MM" for monthly queries
  String get currentMonth {
    final date = customStartDate ?? DateTime.now();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  LeaderboardState copyWith({
    String? selectedPinballId,
    LeaderboardPeriod? selectedPeriod,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool clearCustomDates = false,
  }) {
    return LeaderboardState(
      selectedPinballId: selectedPinballId ?? this.selectedPinballId,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customStartDate: clearCustomDates
          ? null
          : (customStartDate ?? this.customStartDate),
      customEndDate: clearCustomDates
          ? null
          : (customEndDate ?? this.customEndDate),
    );
  }

  @override
  List<Object?> get props => [
    selectedPinballId,
    selectedPeriod,
    customStartDate,
    customEndDate,
  ];

  @override
  bool get stringify => true;
}
