abstract interface class IdGenerator {
  String generate();
}

class UuidIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() => '${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
}
