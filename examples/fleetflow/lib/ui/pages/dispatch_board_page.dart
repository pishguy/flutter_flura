import 'package:flutter/material.dart';
import 'package:flura/flura.dart';

import '../../main.dart';
import '../screen_models/dispatch_board_screen_model.dart';
import 'order_details_page.dart';

class DispatchBoardPage extends StatefulWidget {
  const DispatchBoardPage({super.key});

  @override
  State<DispatchBoardPage> createState() => _DispatchBoardPageState();
}

class _DispatchBoardPageState extends State<DispatchBoardPage> {
  late final DispatchBoardScreenModel _model;

  @override
  void initState() {
    super.initState();
    final container = AppContainer.of(context);
    _model = container.resolve<DispatchBoardScreenModel>();
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
      appBar: AppBar(title: const Text('Dispatch Board')),
      body: UltraBuilder(
        builder: (context) {
          if (_model.isLoading()) return const Center(child: CircularProgressIndicator());
          if (_model.error() != null) return Center(child: Text(_model.error()!, style: const TextStyle(color: Colors.red)));
          if (_model.orders.isEmpty) return const Center(child: Text('No open orders'));
          return ListView.builder(
            itemCount: _model.orders.length,
            itemBuilder: (context, index) {
              final order = _model.orders[index];
              return ListTile(
                title: Text('Order ${order.id}'),
                subtitle: Text('${order.status.name} - \$${order.estimatedPrice}'),
                trailing: ElevatedButton(
                  onPressed: () => _model.assignTechnician(order.id),
                  child: const Text('Assign'),
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(orderId: order.id),
                )),
              );
            },
          );
        },
      ),
    );
  }
}
