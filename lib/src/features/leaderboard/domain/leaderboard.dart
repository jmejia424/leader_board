import 'package:equatable/equatable.dart';
import 'package:leader_board/src/features/leaderboard/domain/score.dart';

enum LeaderboardPeriod {
  allTime,
  monthly,
  custom;

  String get displayName {
    switch (this) {
      case LeaderboardPeriod.allTime:
        return 'All Time';
      case LeaderboardPeriod.monthly:
        return 'Monthly';
      case LeaderboardPeriod.custom:
        return 'Custom';
    }
  }
}

class Leaderboard extends Equatable {
  final String pinballId;
  final String pinballName;
  final LeaderboardPeriod period;
  final List<Score> scores;
  final DateTime? startDate;
  final DateTime? endDate;

  const Leaderboard({
    required this.pinballId,
    required this.pinballName,
    required this.period,
    required this.scores,
    this.startDate,
    this.endDate,
  });

  /// Gets a formatted title for the leaderboard header
  String get title {
    final periodText = _getPeriodText();
    return '$pinballName - $periodText';
  }

  String _getPeriodText() {
    switch (period) {
      case LeaderboardPeriod.allTime:
        return 'All Time';
      case LeaderboardPeriod.monthly:
        if (startDate != null) {
          final monthNames = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
          return '${monthNames[startDate!.month - 1]} ${startDate!.year}';
        }
        return 'Monthly';
      case LeaderboardPeriod.custom:
        if (startDate != null && endDate != null) {
          return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
        }
        return 'Custom Date Range';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Leaderboard copyWith({
    String? pinballId,
    String? pinballName,
    LeaderboardPeriod? period,
    List<Score>? scores,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Leaderboard(
      pinballId: pinballId ?? this.pinballId,
      pinballName: pinballName ?? this.pinballName,
      period: period ?? this.period,
      scores: scores ?? this.scores,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    pinballId,
    pinballName,
    period,
    scores,
    startDate,
    endDate,
  ];

  @override
  bool get stringify => true;
}
