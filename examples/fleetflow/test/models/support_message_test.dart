import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/support_message.dart';

void main() {
  group('SupportMessage', () {
    test('fromMap / toMap roundtrip', () {
      final original = SupportMessage(
        id: 'msg-001',
        tenantId: 'tenant-a',
        ticketId: 'tkt-001',
        senderId: 'usr-001',
        body: 'Help needed',
        internal: false,
        createdAt: DateTime.utc(2026, 7, 11, 15, 0),
        read: false,
      );

      final map = original.toMap();
      final restored = SupportMessage.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tenantId, original.tenantId);
      expect(restored.ticketId, original.ticketId);
      expect(restored.senderId, original.senderId);
      expect(restored.body, original.body);
      expect(restored.internal, original.internal);
      expect(restored.createdAt, original.createdAt);
      expect(restored.read, original.read);
    });
  });
}
