import 'dart:io';

import 'package:test/test.dart';
import 'package:umay_db/umay_db.dart';
import 'package:flura_umay/flura_umay.dart';

void main() {
  setUpAll(() {
    TypeRegistry.registerAdapter(MapAdapter());
  });

  group('UmayCacheBackend', () {
    late UmayCacheBackend cache;

    setUp(() async {
      cache = await UmayCacheBackend.create(
        directory: Directory.systemTemp.createTempSync('cache_test_').path,
      );
    });

    tearDown(() async {
      await cache.close();
    });

    test('put and get', () async {
      await cache.put('key1', 'value1');
      final result = await cache.get('key1');
      expect(result, 'value1');
    });

    test('get returns null for missing key', () async {
      final result = await cache.get('missing');
      expect(result, null);
    });

    test('has returns true for existing key', () async {
      await cache.put('key', 'value');
      expect(await cache.has('key'), true);
    });

    test('has returns false for missing key', () async {
      expect(await cache.has('missing'), false);
    });

    test('forget removes key', () async {
      await cache.put('key', 'value');
      await cache.forget('key');
      expect(await cache.has('key'), false);
    });

    test('flush removes all keys', () async {
      await cache.put('a', 1);
      await cache.put('b', 2);
      await cache.flush();
      expect(await cache.has('a'), false);
      expect(await cache.has('b'), false);
    });

    test('ttl expiration', () async {
      await cache.put('key', 'value', ttl: const Duration(milliseconds: 50));
      expect(await cache.get('key'), 'value');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(await cache.get('key'), null);
    });

    test('remember caches the result', () async {
      var calls = 0;
      final result = await cache.remember('key', const Duration(minutes: 5), () async {
        calls++;
        return 'computed';
      });

      expect(result, 'computed');
      expect(calls, 1);

      final cached = await cache.remember('key', const Duration(minutes: 5), () async {
        calls++;
        return 'computed';
      });

      expect(cached, 'computed');
      expect(calls, 1);
    });
  });
}
