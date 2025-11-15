import 'package:flutter/foundation.dart';
import 'package:leader_board/src/exceptions/app_exception.dart';
import 'package:leader_board/src/features/settings/data/settings_repository.dart';
import 'package:leader_board/src/features/settings/domain/pinball_machine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  late final SettingsRepository _repository;

  @override
  void build() {
    _repository = ref.read(settingsRepositoryProvider.notifier);
  }

  Future<List<PinballMachine>> getPinballCollection() async {
    debugPrint('SettingsService: Fetching pinball collection');
    final collection = await _repository.fetchPinballCollection();
    debugPrint(
      'SettingsService: Fetched ${collection.length} pinball machines',
    );
    for (var pinball in collection) {
      debugPrint('  - ${pinball.id}: ${pinball.name}');
    }
    return collection;
  }

  Future<PinballMachine> fetchPinball({required String id}) async {
    final collection = await _repository.fetchPinballCollection();
    try {
      return collection.firstWhere((pinball) => pinball.id == id);
    } catch (e) {
      throw PinballNotFoundException(id);
    }
  }
}

@riverpod
Future<List<PinballMachine>> pinballCollection(ref) async {
  final service = ref.watch(settingsServiceProvider.notifier);
  return await service.getPinballCollection();
}
