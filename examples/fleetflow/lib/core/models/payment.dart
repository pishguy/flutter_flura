import 'package:umay_db/umay_db.dart';

import 'enums.dart';

class Payment extends UmayModel {
  @override
  dynamic id;
  String tenantId;
  String orderId;
  int amount;
  String currency;
  PaymentStatus status;
  String? gatewayReference;
  DateTime? paidAt;

  Payment({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    this.gatewayReference,
    this.paidAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        id: map['id'],
        tenantId: map['tenantId'] as String,
        orderId: map['orderId'] as String,
        amount: map['amount'] as int,
        currency: map['currency'] as String,
        status: PaymentStatus.values[map['status'] as int],
        gatewayReference: map['gatewayReference'] as String?,
        paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt'] as String) : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'status': status.index,
        'gatewayReference': gatewayReference,
        'paidAt': paidAt?.toIso8601String(),
      };
}
