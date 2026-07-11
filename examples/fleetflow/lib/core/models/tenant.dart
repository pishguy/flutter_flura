import 'package:umay_db/umay_db.dart';

enum TenantStatus { active, suspended, disabled }

class Tenant extends UmayModel {
  @override
  dynamic id;
  String name;
  String slug;
  TenantStatus status;
  Map<String, dynamic> settings;

  Tenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.settings,
  });

  factory Tenant.fromMap(Map<String, dynamic> map) => Tenant(
        id: map['id'],
        name: map['name'] as String,
        slug: map['slug'] as String,
        status: TenantStatus.values[map['status'] as int],
        settings: Map<String, dynamic>.from(map['settings'] as Map),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slug': slug,
        'status': status.index,
        'settings': settings,
      };
}
