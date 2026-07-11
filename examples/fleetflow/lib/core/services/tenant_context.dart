import '../models/enums.dart';

enum UserPermission { viewOrders, assignTechnicians, managePayments, viewReports }

class TenantContext {
  final String tenantId;
  final String userId;
  final Set<UserRole> roles;

  const TenantContext({
    required this.tenantId,
    required this.userId,
    required this.roles,
  });

  bool can(UserPermission permission) {
    if (roles.contains(UserRole.superAdmin)) return true;
    if (roles.contains(UserRole.tenantOwner)) return true;

    return switch (permission) {
      UserPermission.viewOrders =>
        roles.contains(UserRole.dispatcher) || roles.contains(UserRole.technician),
      UserPermission.assignTechnicians => roles.contains(UserRole.dispatcher),
      UserPermission.managePayments => roles.contains(UserRole.accountant),
      UserPermission.viewReports => roles.contains(UserRole.accountant),
    };
  }
}
