import 'package:flura/flura.dart';

import '../../core/models/enums.dart';
import '../../core/models/service_order.dart';
import '../../core/repositories/order_repository.dart';
import '../../domain/order_status_transition_service.dart';

class OrderDetailsScreenModel extends ScreenModel {
  final OrderRepository orderRepository;
  final OrderStatusTransitionService transitionService;
  final AppLogger logger;

  final order = Signal<ServiceOrder?>(null);
  final actionInProgress = Signal<bool>(false);
  final statusMessage = Signal<String?>(null);

  String _orderId;

  OrderDetailsScreenModel({
    required String orderId,
    required this.orderRepository,
    required this.transitionService,
    required this.logger,
  }) : _orderId = orderId;

  @override
  void onInit() {
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await orderRepository.findById(_orderId);
      order.value = loaded;
    } catch (e) {
      statusMessage.value = 'Failed to load order: $e';
      logger.error('OrderDetails init failed', error: e);
    }
  }

  Future<void> advanceStatus(OrderStatus next) async {
    actionInProgress.value = true;
    try {
      await transitionService.transition(orderId: _orderId, next: next);
      await _load();
      statusMessage.value = 'Status updated';
    } catch (e) {
      statusMessage.value = 'Status update failed: $e';
    } finally {
      actionInProgress.value = false;
    }
  }

  void reload(String orderId) {
    _orderId = orderId;
    _load();
  }
}
