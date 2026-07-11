import 'package:flura/flura.dart';

import '../../core/models/service_order.dart';
import '../../core/repositories/order_repository.dart';
import '../../domain/dispatch_service.dart';

class DispatchBoardScreenModel extends ScreenModel {
  final OrderRepository orderRepository;
  final DispatchService dispatchService;
  final AppLogger logger;

  final orders = ReactiveList<ServiceOrder>();
  final isLoading = Signal<bool>(true);
  final error = Signal<String?>(null);

  DispatchBoardScreenModel({
    required this.orderRepository,
    required this.dispatchService,
    required this.logger,
  });

  @override
  void onInit() {
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      final open = await orderRepository.findOpenOrders();
      orders
        ..clear()
        ..addAll(open);
    } catch (e) {
      error.value = 'Failed to load orders: $e';
      logger.error('DispatchBoard init failed', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignTechnician(String orderId) async {
    try {
      final result = await dispatchService.autoAssign(orderId);
      if (result.success) {
        logger.info('Assigned technician to order', context: {'orderId': orderId});
        await _load();
      }
    } catch (e) {
      error.value = 'Assignment failed: $e';
    }
  }
}
