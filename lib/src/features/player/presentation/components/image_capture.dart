import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leader_board/src/features/player/application/player_state_controller.dart';

class ImageCapture extends ConsumerWidget {
  const ImageCapture({super.key});

  Future<void> _pickImage(WidgetRef ref) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality:
          70, // Compress to ~70% quality, significantly reduces file size
      maxWidth: 800, // Resize to a max width of 800 pixels
    );
    if (pickedFile != null) {
      ref
          .read(playerStateControllerProvider.notifier)
          .setCapturedImage(pickedFile);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateControllerProvider);
    final pickedImage = playerState.capturedImage;

    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ref),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: pickedImage == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50),
                            SizedBox(height: 8),
                            Text('Tap to take a picture'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: kIsWeb
                            ? Image.network(pickedImage.path, fit: BoxFit.cover)
                            : Image.file(
                                File(pickedImage.path),
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
            if (pickedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ref),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake Picture'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
