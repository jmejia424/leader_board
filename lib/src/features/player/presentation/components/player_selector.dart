import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/features/player/application/player_state_controller.dart';

import 'player_button.dart';

class PlayerSelector extends ConsumerWidget {
  const PlayerSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateControllerProvider);
    final selectedPlayer = playerState.selectedPlayer;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(4, (index) {
          final playerNumber = index + 1;
          return PlayerButton(
            playerNumber: playerNumber,
            isSelected: selectedPlayer == playerNumber,
            onTap: () {
              ref
                  .read(playerStateControllerProvider.notifier)
                  .setSelectedPlayer(playerNumber);
            },
          );
        }),
      ),
    );
  }
}
