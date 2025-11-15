import 'package:flutter/material.dart';
import 'package:leader_board/src/features/settings/domain/pinball_machine.dart';
import 'package:leader_board/src/utils/firebase_storage_service.dart';

class PinballCard extends StatelessWidget {
  final PinballMachine pinball;
  final bool selected;
  final bool isLarge;
  final VoidCallback onTap;

  const PinballCard({
    super.key,
    required this.pinball,
    required this.selected,
    this.isLarge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isLarge ? 222.0 : 133.0;
    final cardHeight = isLarge ? 112.0 : 67.0;
    final fontSize = isLarge ? 16.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: Colors.blueAccent, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.4 : 0.2),
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FutureBuilder<String>(
            future: FirebaseStorageService.getPinballImageUrl(
              pinball.id,
              ImageSize.small,
            ),
            builder: (context, snapshot) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (snapshot.hasData && snapshot.data!.isNotEmpty)
                    Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  // Selection overlay
                  if (selected) Container(color: Colors.blue.withOpacity(0.4)),
                  // Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Pinball name
                  Positioned(
                    bottom: 6,
                    left: 8,
                    right: 8,
                    child: Text(
                      pinball.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
