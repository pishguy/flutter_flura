import 'package:umay_db/umay_db.dart';

class SupportMessage extends UmayModel {
  @override
  dynamic id;
  String tenantId;
  String ticketId;
  String senderId;
  String body;
  bool internal;
  DateTime createdAt;
  bool read;

  SupportMessage({
    required this.id,
    required this.tenantId,
    required this.ticketId,
    required this.senderId,
    required this.body,
    required this.internal,
    required this.createdAt,
    required this.read,
  });

  factory SupportMessage.fromMap(Map<String, dynamic> map) => SupportMessage(
        id: map['id'],
        tenantId: map['tenantId'] as String,
        ticketId: map['ticketId'] as String,
        senderId: map['senderId'] as String,
        body: map['body'] as String,
        internal: map['internal'] as bool,
        createdAt: DateTime.parse(map['createdAt'] as String),
        read: map['read'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ticketId': ticketId,
        'senderId': senderId,
        'body': body,
        'internal': internal,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };
}
