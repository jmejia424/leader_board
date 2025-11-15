import 'package:flutter/material.dart';

class QrCode extends StatelessWidget {
  const QrCode({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      height: 75,
      child: Image.asset(
        'assets/images/leaderboard_qr.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
