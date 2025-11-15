import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_known_path_notifier.g.dart';

@Riverpod(keepAlive: true)
class LastKnownPathNotifier extends _$LastKnownPathNotifier {
  @override
  String build() {
    return '/signIn';
  }

  void updatePath(String path) {
    state = path;
  }
}
