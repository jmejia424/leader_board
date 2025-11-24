import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leader_board/src/common_widgets/reusable_pinball_carousel.dart';
import 'package:leader_board/src/features/authentication/presentation/components/profile_icon.dart';
import 'package:leader_board/src/features/player/application/player_screen_controller.dart';
import 'package:leader_board/src/features/player/application/player_state_controller.dart';
import 'package:leader_board/src/features/player/presentation/components/image_capture.dart';
import 'package:leader_board/src/features/player/presentation/components/player_selector.dart';
import 'package:leader_board/src/features/settings/application/settings_service.dart';
import 'package:leader_board/src/routing/app_routes.dart';
import 'package:leader_board/src/utils/async_value_ui.dart';
import 'package:leader_board/src/utils/firebase_storage_service.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  Future<void> _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    int playerNumber,
    String pinballName,
    String pinballId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<String>(
              future: FirebaseStorageService.getPinballImageUrl(
                pinballId,
                ImageSize.small,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error);
                } else {
                  return Image.network(snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: 'Submit score for ',
                children: [
                  TextSpan(
                    text: 'Player #$playerNumber',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'on ',
                children: [
                  TextSpan(
                    text: pinballName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(playerScreenControllerProvider.notifier).submitScore();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      playerScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final playerState = ref.watch(playerStateControllerProvider);
    final controllerState = ref.watch(playerScreenControllerProvider);
    final isSubmitting = controllerState.isLoading;
    final canSubmit = playerState.isValid && !isSubmitting;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                ],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: const Icon(Icons.leaderboard, color: Colors.white),
          ),
          onPressed: () {
            context.goNamed(AppRoute.leaderboard.name);
          },
        ),
        title: const Text('Capture Player Score'),
        actions: const [ProfileIcon()],
      ),
      body: Center(
        child: Column(
          children: [
            const PlayerSelector(),
            const SizedBox(height: 16),
            const ImageCapture(),
            const SizedBox(height: 16),
            ReusablePinballCarousel(
              onPinballSelected: (pinballId) {
                ref
                    .read(playerStateControllerProvider.notifier)
                    .setSelectedPinball(pinballId);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: canSubmit
                  ? () async {
                      final pinballsAsync = await ref.read(
                        pinballCollectionProvider.future,
                      );
                      final selectedPinball = pinballsAsync.firstWhere(
                        (p) => p.id == playerState.selectedPinballId,
                        orElse: () => throw Exception('Pinball not found'),
                      );

                      if (context.mounted) {
                        await _showConfirmationDialog(
                          context,
                          ref,
                          playerState.selectedPlayer,
                          selectedPinball.name,
                          selectedPinball.id,
                        );
                      }
                    }
                  : null,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: const Text('Submit Score'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
