import 'dart:async';

import 'package:flura/flura.dart';

import '../../core/models/technician_location.dart';
import '../../core/repositories/technician_repository.dart';

class DispatchMapScreenModel extends ScreenModel {
  final TechnicianRepository technicianRepository;
  final AppLogger logger;

  final technicians = ReactiveList<TechnicianLocation>();
  StreamSubscription? _subscription;

  DispatchMapScreenModel({
    required this.technicianRepository,
    required this.logger,
  });

  @override
  void onInit() {
    _subscription?.cancel();
    _subscription = technicianRepository.watchActiveTechnicians().listen(
      (locations) {
        technicians
          ..clear()
          ..addAll(locations);
      },
      onError: (e) {
        logger.error('Map subscription error', error: e);
      },
    );
  }

  @override
  void onDispose() {
    _subscription?.cancel();
  }
}
