import 'package:flutter/material.dart';
import 'package:flura/flura.dart';

import '../../main.dart';
import '../../core/models/enums.dart';
import '../../core/models/service_order.dart';
import '../../core/repositories/order_repository.dart';
import '../../domain/order_status_transition_service.dart';
import '../screen_models/order_details_screen_model.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late final OrderDetailsScreenModel _model;

  @override
  void initState() {
    super.initState();
    final container = AppContainer.of(context);
    _model = OrderDetailsScreenModel(
      orderId: widget.orderId,
      orderRepository: container.resolve<OrderRepository>(),
      transitionService: container.resolve<OrderStatusTransitionService>(),
      logger: container.resolve<AppLogger>(),
    );
    _model.attach();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${widget.orderId}')),
      body: UltraBuilder(
        builder: (context) {
          final currentOrder = _model.order();
          if (currentOrder == null) return const Center(child: CircularProgressIndicator());
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${currentOrder.id}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Status: ${currentOrder.status.name}'),
                Text('Address: ${currentOrder.serviceAddress}'),
                Text('Estimated: \$${currentOrder.estimatedPrice}'),
                const SizedBox(height: 16),
                if (_model.actionInProgress())
                  const CircularProgressIndicator()
                else
                  ..._statusActions(context, currentOrder),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _statusActions(BuildContext context, ServiceOrder currentOrder) {
    final next = _nextStatuses(currentOrder.status);
    return next.map((status) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _model.advanceStatus(status);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transitioning to ${status.name}...')));
          },
          child: Text('Move to ${status.name}'),
        ),
      ),
    )).toList();
  }

  List<OrderStatus> _nextStatuses(OrderStatus current) {
    const map = {
      OrderStatus.draft: [OrderStatus.submitted],
      OrderStatus.submitted: [OrderStatus.awaitingPayment],
      OrderStatus.paid: [OrderStatus.dispatching],
      OrderStatus.dispatching: [OrderStatus.assigned],
      OrderStatus.assigned: [OrderStatus.technicianEnRoute],
      OrderStatus.technicianEnRoute: [OrderStatus.arrived],
      OrderStatus.arrived: [OrderStatus.inProgress],
      OrderStatus.inProgress: [OrderStatus.awaitingCustomerConfirmation],
      OrderStatus.awaitingCustomerConfirmation: [OrderStatus.completed],
    };
    return map[current] ?? [];
  }
}
