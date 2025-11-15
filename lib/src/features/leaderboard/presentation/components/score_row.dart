import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leader_board/src/features/leaderboard/domain/score.dart';
import 'package:leader_board/src/utils/firebase_storage_service.dart';

class ScoreRow extends StatelessWidget {
  final int rank;
  final Score score;
  final String pinballId;
  final bool isCurrentUser;

  const ScoreRow({
    super.key,
    required this.rank,
    required this.score,
    required this.pinballId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final rankColor = _getRankColor(rank);
    final formatter = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : const Color.fromARGB(255, 24, 33, 66),

        borderRadius: BorderRadius.circular(8),
        border: isTopThree ? Border.all(color: rankColor, width: 2) : null,
      ),
      // color: const Color.fromARGB(255, 24, 33, 66),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
                boxShadow: isTopThree
                    ? [
                        BoxShadow(
                          color: rankColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isTopThree
                    ? Icon(_getRankIcon(rank), color: Colors.white, size: 20)
                    : Text(
                        rank.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Pinball image
            FutureBuilder<String>(
              future: FirebaseStorageService.getPinballImageUrl(
                pinballId,
                ImageSize.small,
              ),
              builder: (context, snapshot) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[800],
                    child: snapshot.hasData && snapshot.data!.isNotEmpty
                        ? Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 24,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
        title: Text(
          score.displayName,
          style: TextStyle(
            fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
            fontSize: isTopThree ? 18 : 16,
            color: isTopThree ? rankColor : Colors.white,
          ),
        ),
        trailing: Text(
          formatter.format(score.score),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTopThree ? 20 : 18,
            color: isTopThree ? rankColor : Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.workspace_premium; // Medal
      case 3:
        return Icons.military_tech; // Medal
      default:
        return Icons.emoji_events;
    }
  }
}
