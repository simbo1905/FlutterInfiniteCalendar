import 'dart:math';

/// Generates time-ordered identifiers that remain stable for this in-memory demo.
/// The high bits capture milliseconds since epoch plus a 20-bit counter, while
/// the low bits add randomness for uniqueness across runtimes.
class TimeOrderedUuidGenerator {
  TimeOrderedUuidGenerator([Random? random])
    : _random = random ?? Random.secure();

  final Random _random;
  int _sequence = 0;

  String generate() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final counter = (_sequence++ & 0xFFFFF); // 20 bits (1M ids/ms)
    final msb = (millis << 20) | counter;
    final lsbHigh = _random.nextInt(0x100000000) & 0xFFFFFFFF;
    final lsbLow = _random.nextInt(0x100000000) & 0xFFFFFFFF;
    final lsb = (lsbHigh << 32) | lsbLow;
    return '${msb.toRadixString(16).padLeft(16, '0')}-${lsb.toRadixString(16).padLeft(16, '0')}';
  }
}
