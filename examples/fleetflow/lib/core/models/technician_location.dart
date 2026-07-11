import 'package:umay_db/umay_db.dart';

class TechnicianLocation extends UmayModel {
  @override
  dynamic id;
  String tenantId;
  String technicianId;
  double latitude;
  double longitude;
  double accuracy;
  DateTime recordedAt;

  TechnicianLocation({
    required this.id,
    required this.tenantId,
    required this.technicianId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.recordedAt,
  });

  factory TechnicianLocation.fromMap(Map<String, dynamic> map) =>
      TechnicianLocation(
        id: map['id'],
        tenantId: map['tenantId'] as String,
        technicianId: map['technicianId'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        accuracy: (map['accuracy'] as num).toDouble(),
        recordedAt: DateTime.parse(map['recordedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'technicianId': technicianId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'recordedAt': recordedAt.toIso8601String(),
      };
}
