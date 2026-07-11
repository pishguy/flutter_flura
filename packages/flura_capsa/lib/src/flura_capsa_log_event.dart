class FluraCapsaLogEvent {
  final String message;
  final int level;
  final DateTime timestamp;

  const FluraCapsaLogEvent({
    required this.message,
    required this.level,
    required this.timestamp,
  });
}
