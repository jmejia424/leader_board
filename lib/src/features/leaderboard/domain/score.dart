import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Score extends Equatable {
  final String userId;
  final String displayName;
  final String pinballId;
  final int score;
  final DateTime submittedAt;
  final int? playerNumber;
  final String? imageUrl;

  const Score({
    required this.userId,
    required this.displayName,
    required this.pinballId,
    required this.score,
    required this.submittedAt,
    this.playerNumber,
    this.imageUrl,
  });

  factory Score.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Score(
      userId: data['userId'] as String,
      displayName: data['displayName'] as String,
      pinballId: data['pinballId'] as String,
      score: data['score'] as int,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      playerNumber: data['playerNumber'] as int?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Score copyWith({
    String? userId,
    String? displayName,
    String? pinballId,
    int? score,
    DateTime? submittedAt,
    int? playerNumber,
    String? imageUrl,
  }) {
    return Score(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      pinballId: pinballId ?? this.pinballId,
      score: score ?? this.score,
      submittedAt: submittedAt ?? this.submittedAt,
      playerNumber: playerNumber ?? this.playerNumber,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    displayName,
    pinballId,
    score,
    submittedAt,
    playerNumber,
    imageUrl,
  ];

  @override
  bool get stringify => true;
}
