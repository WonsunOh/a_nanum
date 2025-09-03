// lib/core/providers/loading_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_provider.g.dart';

@riverpod
class LoadingNotifier extends _$LoadingNotifier {
  @override
  Map<String, bool> build() {
    return {};
  }

  void setLoading(String key, bool isLoading) {
    state = {...state, key: isLoading};
  }

  bool isLoading(String key) {
    return state[key] ?? false;
  }

  void clearLoading(String key) {
    final newState = {...state};
    newState.remove(key);
    state = newState;
  }
}