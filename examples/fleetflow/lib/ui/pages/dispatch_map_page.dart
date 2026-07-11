import 'package:flutter/material.dart';
import 'package:flura/flura.dart';

import '../../main.dart';
import '../screen_models/dispatch_map_screen_model.dart';

class DispatchMapPage extends StatefulWidget {
  const DispatchMapPage({super.key});

  @override
  State<DispatchMapPage> createState() => _DispatchMapPageState();
}

class _DispatchMapPageState extends State<DispatchMapPage> {
  late final DispatchMapScreenModel _model;

  @override
  void initState() {
    super.initState();
    final container = AppContainer.of(context);
    _model = container.resolve<DispatchMapScreenModel>();
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
      appBar: AppBar(title: const Text('Live Map')),
      body: UltraBuilder(
        builder: (context) {
          final techs = _model.technicians;
          if (techs.isEmpty) {
            return const Center(child: Text('No active technicians'));
          }
          return ListView.builder(
            itemCount: techs.length,
            itemBuilder: (context, index) {
              final tech = techs[index];
              return ListTile(
                leading: const Icon(Icons.person_pin_circle, color: Colors.green),
                title: Text('Technician ${tech.technicianId}'),
                subtitle: Text('${tech.latitude.toStringAsFixed(4)}, ${tech.longitude.toStringAsFixed(4)}'),
              );
            },
          );
        },
      ),
    );
  }
}
