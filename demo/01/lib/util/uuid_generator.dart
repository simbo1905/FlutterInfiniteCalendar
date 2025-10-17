import 'dart:math';

class UuidGenerator {
  static final _random = Random();

  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(0xFFFFFF);
    return '${timestamp.toRadixString(16)}-${randomPart.toRadixString(16)}';
  }
}
