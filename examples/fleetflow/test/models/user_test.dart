import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/enums.dart';
import 'package:fleetflow/core/models/user.dart';

void main() {
  group('User', () {
    test('fromMap / toMap roundtrip', () {
      final original = User(
        id: 'usr-001',
        tenantId: 'tenant-a',
        fullName: 'Alice',
        phone: '09120000001',
        roles: {UserRole.dispatcher, UserRole.tenantOwner},
        active: true,
      );

      final map = original.toMap();
      final restored = User.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tenantId, original.tenantId);
      expect(restored.fullName, original.fullName);
      expect(restored.phone, original.phone);
      expect(restored.roles, original.roles);
      expect(restored.active, original.active);
    });
  });
}
