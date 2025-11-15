import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:leader_board/src/features/settings/domain/pinball_machine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.g.dart';

@Riverpod(keepAlive: true)
class SettingsRepository extends _$SettingsRepository {
  late final FirebaseFirestore _firestore;

  @override
  void build() {
    _firestore = FirebaseFirestore.instance;
  }

  Future<List<PinballMachine>> fetchPinballCollection() async {
    try {
      final doc = await _firestore.collection('settings').doc('pinballs').get();
      final List<dynamic> collection = doc.data()?['collection'] ?? [];
      final machines = collection
          .map((map) => PinballMachine.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      // Add some dummy data for testing the carousel
      if (machines.length < 5) {
        machines.addAll([
          const PinballMachine(id: 'test1', name: 'Medieval Madness'),
          const PinballMachine(id: 'test2', name: 'Attack from Mars'),
          const PinballMachine(id: 'test3', name: 'The Addams Family'),
          const PinballMachine(id: 'test4', name: 'Twilight Zone'),
          const PinballMachine(id: 'test5', name: 'Monster Bash'),
        ]);
      }

      return machines;
    } catch (e) {
      debugPrint('Error fetching pinball collection: $e');
      return [];
    }
  }
}
