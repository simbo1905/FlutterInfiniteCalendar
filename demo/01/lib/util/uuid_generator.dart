import 'dart:math';
import 'dart:typed_data';

class UuidGenerator {
  // Secure random for the least significant bits (matches Java SecureRandom)
  static final _secureRandom = Random.secure();
  
  // Atomic counter for the 20-bit sequence (matches Java AtomicLong)
  static int _sequence = 0;
  
  // Lock for thread-safe sequence increment (Dart equivalent of AtomicLong)
  static final _sequenceLock = Object();

  /// Generates the most significant bits using epoch time then counter (MSB)
  /// Matches Java's epochTimeThenCounterMsb() method exactly
  static int _epochTimeThenCounterMsb() {
    final currentMillis = DateTime.now().millisecondsSinceEpoch;
    
    // Thread-safe sequence increment (equivalent to AtomicLong)
    // In Dart, we can use a simple approach since it's single-threaded for UI
    // For isolate safety, we'd need more complex synchronization
    _sequence = (_sequence + 1) & 0xFFFFF; // 20-bit mask
    final counter20bits = _sequence;
    
    // Shift currentMillis left by 20 bits and OR with counter
    return (currentMillis << 20) | counter20bits;
  }

  /// Generates a UUID that matches Java's UUID structure exactly
  /// Returns a 128-bit UUID as two 64-bit integers (msb, lsb)
  static (int, int) generateUUID() {
    final msb = _epochTimeThenCounterMsb();
    final lsb = _secureRandom.nextInt(1 << 32) << 32 | _secureRandom.nextInt(1 << 32);
    return (msb, lsb);
  }

  /// Generates a UUID string in standard format (matches Java UUID.toString())
  static String generateUUIDString() {
    final (msb, lsb) = generateUUID();
    return _uuidToString(msb, lsb);
  }

  /// Converts UUID components to standard string format
  static String _uuidToString(int msb, int lsb) {
    // Standard UUID format: 8-4-4-4-12 hex digits
    final timeLow = msb >>> 32;
    final timeMid = (msb >>> 16) & 0xFFFF;
    final timeHighAndVersion = msb & 0xFFFF;
    final clockSeq = (lsb >>> 48) & 0xFFFF;
    final node = lsb & 0xFFFFFFFFFFFF;

    return '${timeLow.toRadixString(16).padLeft(8, '0')}-'
           '${timeMid.toRadixString(16).padLeft(4, '0')}-'
           '${timeHighAndVersion.toRadixString(16).padLeft(4, '0')}-'
           '${clockSeq.toRadixString(16).padLeft(4, '0')}-'
           '${node.toRadixString(16).padLeft(12, '0')}';
  }

  /// Legacy method for backward compatibility - now uses proper UUID generation
  static String generate() => generateUUIDString();
}
