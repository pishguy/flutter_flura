import '../models/enums.dart';

class OrderStateMachine {
  static const _transitions = <OrderStatus, Set<OrderStatus>>{
    OrderStatus.draft: {OrderStatus.submitted, OrderStatus.cancelled},
    OrderStatus.submitted: {OrderStatus.awaitingPayment, OrderStatus.cancelled},
    OrderStatus.awaitingPayment: {OrderStatus.paid, OrderStatus.cancelled, OrderStatus.failed},
    OrderStatus.paid: {OrderStatus.dispatching, OrderStatus.cancelled, OrderStatus.refunded},
    OrderStatus.dispatching: {OrderStatus.assigned, OrderStatus.cancelled},
    OrderStatus.assigned: {OrderStatus.technicianEnRoute, OrderStatus.cancelled},
    OrderStatus.technicianEnRoute: {OrderStatus.arrived, OrderStatus.cancelled},
    OrderStatus.arrived: {OrderStatus.inProgress, OrderStatus.cancelled},
    OrderStatus.inProgress: {OrderStatus.awaitingCustomerConfirmation, OrderStatus.failed},
    OrderStatus.awaitingCustomerConfirmation: {OrderStatus.completed, OrderStatus.failed},
    OrderStatus.completed: {},
    OrderStatus.cancelled: {},
    OrderStatus.failed: {},
    OrderStatus.refunded: {},
  };

  static bool canTransition({required OrderStatus from, required OrderStatus to}) {
    final allowed = _transitions[from];
    return allowed != null && allowed.contains(to);
  }
}
