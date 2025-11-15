import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { pending, processing, verified, rejected }

class ScoreSubmission {
  final String id;
  final String userId;
  final String pinballId;
  final int playerNumber;
  final String imageUrl;
  final SubmissionStatus status;
  final int? score;
  final DateTime submittedAt;
  final DateTime? processedAt;
  final String? error;
  final int retryCount;

  const ScoreSubmission({
    required this.id,
    required this.userId,
    required this.pinballId,
    required this.playerNumber,
    required this.imageUrl,
    required this.status,
    this.score,
    required this.submittedAt,
    this.processedAt,
    this.error,
    this.retryCount = 0,
  });

  factory ScoreSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScoreSubmission(
      id: doc.id,
      userId: data['userId'] as String,
      pinballId: data['pinballId'] as String,
      playerNumber: data['playerNumber'] as int,
      imageUrl: data['imageUrl'] as String,
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SubmissionStatus.pending,
      ),
      score: data['score'] as int?,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      error: data['error'] as String?,
      retryCount: data['retryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pinballId': pinballId,
      'playerNumber': playerNumber,
      'imageUrl': imageUrl,
      'status': status.name,
      'score': score,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'processedAt': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'error': error,
      'retryCount': retryCount,
    };
  }

  ScoreSubmission copyWith({
    String? id,
    String? userId,
    String? pinballId,
    int? playerNumber,
    String? imageUrl,
    SubmissionStatus? status,
    int? score,
    DateTime? submittedAt,
    DateTime? processedAt,
    String? error,
    int? retryCount,
  }) {
    return ScoreSubmission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pinballId: pinballId ?? this.pinballId,
      playerNumber: playerNumber ?? this.playerNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      score: score ?? this.score,
      submittedAt: submittedAt ?? this.submittedAt,
      processedAt: processedAt ?? this.processedAt,
      error: error ?? this.error,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
