import 'package:umay_db/umay_db.dart';

import 'enums.dart';

class User extends UmayModel {
  @override
  dynamic id;
  String tenantId;
  String fullName;
  String phone;
  Set<UserRole> roles;
  bool active;

  User({
    required this.id,
    required this.tenantId,
    required this.fullName,
    required this.phone,
    required this.roles,
    required this.active,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        tenantId: map['tenantId'] as String,
        fullName: map['fullName'] as String,
        phone: map['phone'] as String,
        roles: (map['roles'] as List).map((r) => UserRole.values[r as int]).toSet(),
        active: map['active'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'fullName': fullName,
        'phone': phone,
        'roles': roles.map((r) => r.index).toList(),
        'active': active,
      };
}
