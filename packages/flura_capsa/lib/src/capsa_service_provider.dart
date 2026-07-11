import 'dart:async';

import 'package:flura_core/flura_core.dart';
import 'package:capsa/capsa.dart';

import 'flura_capsa_log_event.dart';

typedef CapsaLogForwarder = void Function(FluraCapsaLogEvent event);

class CapsaServiceProvider extends FluraServiceProvider {
  final CapsaLogForwarder? _forwarder;

  CapsaServiceProvider({CapsaLogForwarder? forwarder})
      : _forwarder = forwarder;

  @override
  void register(FluraContainer container) {
    CapsaLogger.enable(
      level: CapsaLogLevel.info,
    );
  }

  @override
  FutureOr<void> boot(FluraResolver resolver) {
    if (_forwarder != null) {
      final forwarder = _forwarder;
      CapsaLogger.sink = (CapsaLogRecord record) {
        forwarder(FluraCapsaLogEvent(
          message: record.message,
          level: record.level.index,
          timestamp: record.time,
        ));
      };
    }
  }

  @override
  FutureOr<void> shutdown(FluraResolver resolver) {
    CapsaLogger.disable();
  }
}
