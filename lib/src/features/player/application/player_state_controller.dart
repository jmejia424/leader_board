import 'package:image_picker/image_picker.dart';
import 'package:leader_board/src/features/player/domain/player_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_state_controller.g.dart';

@Riverpod(keepAlive: true)
class PlayerStateController extends _$PlayerStateController {
  @override
  PlayerState build() {
    return const PlayerState();
  }

  void setSelectedPlayer(int playerNumber) {
    state = state.copyWith(selectedPlayer: playerNumber);
  }

  void setCapturedImage(XFile? image) {
    state = state.copyWith(capturedImage: image);
  }

  void clearCapturedImage() {
    state = state.copyWith(clearImage: true);
  }

  void setSelectedPinball(String pinballId) {
    state = state.copyWith(selectedPinballId: pinballId);
  }

  void reset() {
    state = const PlayerState();
  }
}
