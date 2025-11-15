import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/common_widgets/reusable_pinball_carousel.dart';
import 'package:leader_board/src/features/authentication/presentation/components/profile_icon.dart';
import 'package:leader_board/src/features/player/application/player_screen_controller.dart';
import 'package:leader_board/src/features/player/application/player_state_controller.dart';
import 'package:leader_board/src/features/player/presentation/components/image_capture.dart';
import 'package:leader_board/src/features/player/presentation/components/player_selector.dart';
import 'package:leader_board/src/utils/async_value_ui.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

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
                  ? () {
                      ref
                          .read(playerScreenControllerProvider.notifier)
                          .submitScore();
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
