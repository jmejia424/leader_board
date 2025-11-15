import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:leader_board/src/features/player/domain/score_submission.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'score_submission_repository.g.dart';

class ScoreSubmissionRepository {
  ScoreSubmissionRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  /// Submit a score with image upload and Firestore record creation
  Future<String> submitScore({
    required String userId,
    required String pinballId,
    required int playerNumber,
    required XFile imageFile,
  }) async {
    // Generate UUID for the image filename
    final imageId = _uuid.v4();
    final imageFileName = '$imageId.jpg';

    // Upload image to Storage first
    final imageUrl = await _uploadImage(imageFile, imageFileName);

    // Create Firestore document
    final submission = ScoreSubmission(
      id: '', // Will be set by Firestore
      userId: userId,
      pinballId: pinballId,
      playerNumber: playerNumber,
      imageUrl: imageUrl,
      status: SubmissionStatus.pending,
      submittedAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('score_submissions')
        .add(submission.toFirestore());

    return docRef.id;
  }

  /// Upload image to Firebase Storage
  Future<String> _uploadImage(XFile file, String fileName) async {
    final ref = _storage.ref().child('score_submissions/$fileName');

    if (kIsWeb) {
      final data = await file.readAsBytes();
      final uploadTask = ref.putData(
        data,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);
      return snapshot.ref.fullPath; // Return storage path, not download URL
    } else {
      final uploadTask = ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);
      return snapshot.ref.fullPath; // Return storage path, not download URL
    }
  }

  /// Get user's submission history
  Stream<List<ScoreSubmission>> watchUserSubmissions(String userId) {
    return _firestore
        .collection('score_submissions')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ScoreSubmission.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get a specific submission by ID
  Future<ScoreSubmission?> getSubmission(String submissionId) async {
    final doc = await _firestore
        .collection('score_submissions')
        .doc(submissionId)
        .get();
    if (!doc.exists) return null;
    return ScoreSubmission.fromFirestore(doc);
  }

  /// Stream a specific submission for real-time updates
  Stream<ScoreSubmission?> watchSubmission(String submissionId) {
    return _firestore
        .collection('score_submissions')
        .doc(submissionId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ScoreSubmission.fromFirestore(doc);
        });
  }
}

@Riverpod(keepAlive: true)
ScoreSubmissionRepository scoreSubmissionRepository(Ref ref) {
  return ScoreSubmissionRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
}

/// Stream provider for user's submissions
@riverpod
Stream<List<ScoreSubmission>> userSubmissions(Ref ref, String userId) {
  final repository = ref.watch(scoreSubmissionRepositoryProvider);
  return repository.watchUserSubmissions(userId);
}

/// Stream provider for a specific submission
@riverpod
Stream<ScoreSubmission?> submissionById(Ref ref, String submissionId) {
  final repository = ref.watch(scoreSubmissionRepositoryProvider);
  return repository.watchSubmission(submissionId);
}
