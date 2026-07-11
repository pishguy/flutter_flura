import 'package:umay_db/umay_db.dart';

import 'enums.dart';

class ServiceOrder extends UmayModel {
  @override
  dynamic id;
  String tenantId;
  String customerId;
  String? technicianId;
  String serviceId;
  OrderStatus status;
  PaymentStatus paymentStatus;
  String serviceAddress;
  DateTime scheduledAt;
  double estimatedPrice;
  double? finalPrice;
  int version;
  DateTime createdAt;
  DateTime updatedAt;

  ServiceOrder({
    required this.id,
    required this.tenantId,
    required this.customerId,
    this.technicianId,
    required this.serviceId,
    required this.status,
    required this.paymentStatus,
    required this.serviceAddress,
    required this.scheduledAt,
    required this.estimatedPrice,
    this.finalPrice,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceOrder.fromMap(Map<String, dynamic> map) => ServiceOrder(
        id: map['id'],
        tenantId: map['tenantId'] as String,
        customerId: map['customerId'] as String,
        technicianId: map['technicianId'] as String?,
        serviceId: map['serviceId'] as String,
        status: OrderStatus.values[map['status'] as int],
        paymentStatus: PaymentStatus.values[map['paymentStatus'] as int],
        serviceAddress: map['serviceAddress'] as String,
        scheduledAt: DateTime.parse(map['scheduledAt'] as String),
        estimatedPrice: (map['estimatedPrice'] as num).toDouble(),
        finalPrice: (map['finalPrice'] as num?)?.toDouble(),
        version: map['version'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'customerId': customerId,
        'technicianId': technicianId,
        'serviceId': serviceId,
        'status': status.index,
        'paymentStatus': paymentStatus.index,
        'serviceAddress': serviceAddress,
        'scheduledAt': scheduledAt.toIso8601String(),
        'estimatedPrice': estimatedPrice,
        'finalPrice': finalPrice,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
