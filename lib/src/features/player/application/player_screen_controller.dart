import 'package:firebase_auth/firebase_auth.dart';
import 'package:leader_board/src/features/player/application/player_state_controller.dart';
import 'package:leader_board/src/features/player/data/score_submission_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class PlayerScreenController extends _$PlayerScreenController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<String> submitScore() async {
    final playerState = ref.read(playerStateControllerProvider);

    // Validate that all required state is present
    if (!playerState.isValid) {
      throw Exception('Cannot submit score: missing required data');
    }

    final submissionRepository = ref.read(scoreSubmissionRepositoryProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    state = const AsyncLoading();

    late String submissionId;
    state = await AsyncValue.guard(() async {
      submissionId = await submissionRepository.submitScore(
        userId: user.uid,
        pinballId: playerState.selectedPinballId!,
        playerNumber: playerState.selectedPlayer,
        imageFile: playerState.capturedImage!,
      );
    });

    // Reset state after successful submission
    if (state.hasValue) {
      ref.read(playerStateControllerProvider.notifier).reset();
      return submissionId;
    } else {
      throw state.error ?? Exception('Unknown error');
    }
  }
}
