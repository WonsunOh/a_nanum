// nanum_admin/lib/data/repositories/settings_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings_model.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

class SettingsRepository {
  final _client = Supabase.instance.client;

  Future<List<Setting>> fetchSettings() async {
    final response = await _client.from('settings').select();
    return response.map<Setting>((item) => Setting.fromJson(item)).toList();
  }

  Future<void> updateSettings(Map<String, String> updatedSettings) async {
    final futures = <Future>[];
    for (var entry in updatedSettings.entries) {
      futures.add(
        _client.from('settings').update({'value': entry.value}).eq('key', entry.key),
      );
    }
    await Future.wait(futures);
  }
}