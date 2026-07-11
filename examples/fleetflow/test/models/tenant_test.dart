import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/tenant.dart';

void main() {
  group('Tenant', () {
    test('fromMap / toMap roundtrip', () {
      final original = Tenant(
        id: 'tenant-a',
        name: 'ACME Corp',
        slug: 'acme-corp',
        status: TenantStatus.active,
        settings: {'timezone': 'Asia/Tehran'},
      );

      final map = original.toMap();
      final restored = Tenant.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.slug, original.slug);
      expect(restored.status, original.status);
      expect(restored.settings, original.settings);
    });
  });
}
