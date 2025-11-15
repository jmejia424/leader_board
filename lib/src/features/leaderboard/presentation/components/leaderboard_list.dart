import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/features/leaderboard/domain/leaderboard.dart';
import 'package:leader_board/src/features/leaderboard/presentation/components/score_row.dart';

class LeaderboardList extends ConsumerWidget {
  final Leaderboard leaderboard;

  const LeaderboardList({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (leaderboard.scores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'No scores yet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to submit a score!',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leaderboard.scores.length,
      itemBuilder: (context, index) {
        final score = leaderboard.scores[index];
        final rank = index + 1;

        return ScoreRow(
          rank: rank,
          score: score,
          pinballId: leaderboard.pinballId,
          isCurrentUser: false, // TODO: Check if current user
        );
      },
    );
  }
}
