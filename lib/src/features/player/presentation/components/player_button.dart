import 'package:flutter/material.dart';

class PlayerButton extends StatelessWidget {
  final int playerNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const PlayerButton({
    super.key,
    required this.playerNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.grey[300],
            border: Border(
              right: playerNumber < 4
                  ? BorderSide(color: Colors.grey[400]!, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Center(
            child: Text(
              'Player $playerNumber',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
