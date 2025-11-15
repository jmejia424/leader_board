import 'package:flutter/material.dart';
import 'package:leader_board/src/features/leaderboard/domain/leaderboard.dart';

class LeaderboardHeader extends StatelessWidget {
  final Leaderboard leaderboard;

  const LeaderboardHeader({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Theme.of(context).colorScheme.primary,
            // Theme.of(context).colorScheme.secondary,
            Colors.blueGrey.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Column(
        children: [
          // Row(
          //   children: [
          //     const Icon(Icons.emoji_events, color: Colors.white, size: 32),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: Text(
          //         'HIGH SCORE LEADERBOARDS',
          //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           letterSpacing: 1.2,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //         child: ConstrainedBox(
          //           constraints: BoxConstraints(maxHeight: 100),

          //           child: AspectRatio(
          //             aspectRatio: 1,
          //             child: Image.asset(
          //               'assets/images/leaderboard_qr.png',
          //               fit: BoxFit.contain,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ), // To balance the icon on the left
          //   ],
          // ),
          Row(
            children: [
              // Icon flush left
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 0),
                child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
              ),
              // Centered text
              Expanded(
                child: Text(
                  'HIGH SCORE LEADERBOARDS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              leaderboard.title.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
