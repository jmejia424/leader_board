import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class PlayerState extends Equatable {
  final int selectedPlayer;
  final XFile? capturedImage;
  final String? selectedPinballId;

  const PlayerState({
    this.selectedPlayer = 1,
    this.capturedImage,
    this.selectedPinballId,
  });

  bool get isValid => capturedImage != null && selectedPinballId != null;

  PlayerState copyWith({
    int? selectedPlayer,
    XFile? capturedImage,
    String? selectedPinballId,
    bool clearImage = false,
  }) {
    return PlayerState(
      selectedPlayer: selectedPlayer ?? this.selectedPlayer,
      capturedImage: clearImage ? null : (capturedImage ?? this.capturedImage),
      selectedPinballId: selectedPinballId ?? this.selectedPinballId,
    );
  }

  @override
  List<Object?> get props => [selectedPlayer, capturedImage, selectedPinballId];
}
