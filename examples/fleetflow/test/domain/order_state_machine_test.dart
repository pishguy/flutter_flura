import 'package:flutter_test/flutter_test.dart';
import 'package:fleetflow/core/models/enums.dart';
import 'package:fleetflow/core/services/order_state_machine.dart';

void main() {
  group('OrderStateMachine', () {
    test('valid transitions', () {
      expect(OrderStateMachine.canTransition(from: OrderStatus.draft, to: OrderStatus.submitted), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.submitted, to: OrderStatus.awaitingPayment), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.awaitingPayment, to: OrderStatus.paid), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.paid, to: OrderStatus.dispatching), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.dispatching, to: OrderStatus.assigned), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.assigned, to: OrderStatus.technicianEnRoute), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.technicianEnRoute, to: OrderStatus.arrived), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.arrived, to: OrderStatus.inProgress), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.inProgress, to: OrderStatus.awaitingCustomerConfirmation), isTrue);
      expect(OrderStateMachine.canTransition(from: OrderStatus.awaitingCustomerConfirmation, to: OrderStatus.completed), isTrue);
    });

    test('cancellation allowed from most states', () {
      final cancellableStates = OrderStatus.values.where((s) =>
        OrderStateMachine.canTransition(from: s, to: OrderStatus.cancelled) && s != OrderStatus.cancelled &&
        s != OrderStatus.completed && s != OrderStatus.failed && s != OrderStatus.refunded);
      expect(cancellableStates.length, greaterThan(5));
    });

    test('completed is terminal', () {
      expect(OrderStateMachine.canTransition(from: OrderStatus.completed, to: OrderStatus.cancelled), isFalse);
      expect(OrderStateMachine.canTransition(from: OrderStatus.completed, to: OrderStatus.draft), isFalse);
    });

    test('invalid transitions return false', () {
      expect(OrderStateMachine.canTransition(from: OrderStatus.draft, to: OrderStatus.completed), isFalse);
      expect(OrderStateMachine.canTransition(from: OrderStatus.paid, to: OrderStatus.submitted), isFalse);
      expect(OrderStateMachine.canTransition(from: OrderStatus.completed, to: OrderStatus.paid), isFalse);
    });
  });
}
