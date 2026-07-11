import 'package:flura/flura.dart';

import '../core/models/enums.dart';
import '../core/repositories/order_repository.dart';
import '../core/repositories/technician_repository.dart';
import '../core/services/clock.dart';

class AssignmentResult {
  final bool success;
  final String? technicianId;

  AssignmentResult._({required this.success, this.technicianId});

  factory AssignmentResult.noCandidate() => AssignmentResult._(success: false);
  factory AssignmentResult.assigned(String technicianId) => AssignmentResult._(success: true, technicianId: technicianId);
}

class DispatchService {
  final OrderRepository orders;
  final TechnicianRepository technicians;
  final AppLogger logger;
  final Clock clock;

  DispatchService({
    required this.orders,
    required this.technicians,
    required this.logger,
    required this.clock,
  });

  Future<AssignmentResult> autoAssign(String orderId) async {
    final order = await orders.findById(orderId);
    if (order == null) throw OrderNotFoundException(orderId);
    if (order.status != OrderStatus.dispatching) {
      throw InvalidOrderStateException(orderId: orderId, expected: OrderStatus.dispatching, actual: order.status);
    }

    final candidates = await technicians.findAvailableNear(address: order.serviceAddress, at: order.scheduledAt);
    if (candidates.isEmpty) {
      logger.warning('No technician found for order', context: {'orderId': orderId});
      return AssignmentResult.noCandidate();
    }

    final selected = candidates.first;
    order.technicianId = selected.toString();
    order.status = OrderStatus.assigned;
    order.updatedAt = clock.now();
    order.version++;
    await orders.save(order);

    logger.info('Technician assigned', context: {'orderId': orderId, 'technicianId': selected.toString()});
    return AssignmentResult.assigned(selected.toString());
  }
}
