import 'package:umay_db/umay_db.dart';

class UmayCacheBackend {
  final UmayBox _box;

  UmayCacheBackend(this._box);

  static const String _cacheBoxName = 'flura_cache';

  static Future<UmayCacheBackend> create({String? directory}) async {
    final box = await UmayBox.open(_cacheBoxName, directory: directory);
    return UmayCacheBackend(box);
  }

  Future<Object?> get(String key) async {
    final raw = await _box.get(key);
    if (raw == null) return null;
    if (raw is! Map) return raw;

    final map = raw as Map<String, dynamic>;
    final expiresAt = map['e'] != null ? DateTime.tryParse(map['e'] as String) : null;

    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      await _box.delete(key);
      return null;
    }

    return map['v'];
  }

  Future<void> put(String key, Object? value, {Duration? ttl}) async {
    final map = <String, dynamic>{
      'v': value,
    };
    if (ttl != null) {
      map['e'] = DateTime.now().add(ttl).toIso8601String();
    }
    await _box.put(key, map);
  }

  Future<void> forget(String key) async {
    await _box.delete(key);
  }

  Future<bool> has(String key) async {
    final raw = await _box.get(key);
    if (raw == null) return false;
    if (raw is! Map) return true;

    final map = raw as Map<String, dynamic>;
    final expiresAt = map['e'] != null ? DateTime.tryParse(map['e'] as String) : null;

    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      await _box.delete(key);
      return false;
    }

    return true;
  }

  Future<void> flush() async {
    final keys = _box.indexKeys().toList();
    for (final key in keys) {
      await _box.delete(key);
    }
  }

  Future<T> remember<T>(
    String key,
    Duration ttl,
    Future<T> Function() resolver,
  ) async {
    final cached = await get(key);
    if (cached != null) return cached as T;
    final value = await resolver();
    await put(key, value, ttl: ttl);
    return value;
  }

  Future<void> close() async {
    await _box.close();
  }
}
