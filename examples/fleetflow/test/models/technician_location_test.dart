import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/technician_location.dart';

void main() {
  group('TechnicianLocation', () {
    test('fromMap / toMap roundtrip', () {
      final original = TechnicianLocation(
        id: 'loc-001',
        tenantId: 'tenant-a',
        technicianId: 'tech-001',
        latitude: 35.6892,
        longitude: 51.3890,
        accuracy: 12.5,
        recordedAt: DateTime.utc(2026, 7, 11, 14, 30, 0),
      );

      final map = original.toMap();
      final restored = TechnicianLocation.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tenantId, original.tenantId);
      expect(restored.technicianId, original.technicianId);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.accuracy, original.accuracy);
      expect(restored.recordedAt, original.recordedAt);
    });
  });
}
