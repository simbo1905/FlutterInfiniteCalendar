import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner_demo/util/uuid_generator.dart';

void main() {
  group('UUIDGenerator', () {
    test('generateUUIDsAreUnique', () {
      print('testGenerateUUIDsAreUnique starting');
      final uuids = <String>{};
      
      for (int i = 0; i < 10000; i++) {
        final uuid = UuidGenerator.generateUUIDString();
        expect(uuid, isNotNull);
        expect(uuids.contains(uuid), isFalse, reason: 'UUID should be unique: $uuid');
        uuids.add(uuid);
      }
      
      // All UUIDs should be unique
      expect(uuids.length, equals(10000));
    });

    test('generateUUIDsAreTimeOrdered', () {
      print('testGenerateUUIDsAreTimeOrdered starting');
      // Generate UUIDs and verify they are generally increasing (time-ordered)
      String previous = UuidGenerator.generateUUIDString();
      int ascendingCount = 0;

      for (int i = 0; i < 1000; i++) {
        final current = UuidGenerator.generateUUIDString();
        
        // Extract the most significant bits from the UUID string by parsing the first part
        final previousMsb = _extractMsbFromUuidString(previous);
        final currentMsb = _extractMsbFromUuidString(current);
        
        // Compare the most significant bits which contain the timestamp
        if (currentMsb >= previousMsb) {
          ascendingCount++;
        }
        previous = current;
      }

      // Most UUIDs should be in ascending order (allowing for some edge cases)
      // We expect at least 99% to be ascending
      expect(ascendingCount, greaterThan((1000 * 0.99).round()), 
             reason: 'UUIDs should be mostly time-ordered. Ascending: $ascendingCount/1000');
    });

    test('generateUUIDsAtHighRate', () {
      print('testGenerateUUIDsAtHighRate starting');
      // Test that we can generate many UUIDs quickly without collisions
      final uuids = <String>{};

      final startTime = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < 100000; i++) {
        final uuid = UuidGenerator.generateUUIDString();
        expect(uuids.contains(uuid), isFalse, 
               reason: 'Collision detected at iteration $i: $uuid');
        uuids.add(uuid);
      }
      
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final duration = endTime - startTime;
      final throughput = 100000 / (duration / 1000.0);
      
      print('Generated 100,000 UUIDs in ${duration}ms (${throughput.toStringAsFixed(2)} UUIDs/second)');
      
      // All UUIDs should be unique
      expect(uuids.length, equals(100000));
      
      // Should complete reasonably quickly (within 10 seconds)
      expect(duration, lessThan(10000), 
             reason: 'High rate generation should complete within 10 seconds');
    });

    test('generateUUIDReturnsCorrectFormat', () {
      final uuid = UuidGenerator.generateUUIDString();
      
      // Should be standard UUID format: 8-4-4-4-12 hex digits
      expect(uuid.length, equals(36), reason: 'UUID should be 36 characters long');
      expect(uuid, matches(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'),
             reason: 'UUID should match standard format');
    });

    test('generateUUIDComponentsAreValid', () {
      final (msb, lsb) = UuidGenerator.generateUUID();
      
      // MSB should have timestamp in high bits
      final timestamp = msb >> 20;
      final now = DateTime.now().millisecondsSinceEpoch;
      expect((timestamp - now).abs(), lessThan(1000), 
             reason: 'Timestamp should be recent (within 1 second)');
      
      // Counter should be in low 20 bits of MSB
      final counter = msb & 0xFFFFF;
      expect(counter, greaterThanOrEqualTo(0));
      expect(counter, lessThanOrEqualTo(0xFFFFF));
      
      // LSB should be random
      expect(lsb, isNot(equals(0)), reason: 'LSB should not be zero');
    });
  });
}

/// Helper function to extract MSB from UUID string
/// Parses the first part (timeLow) and reconstructs the MSB
int _extractMsbFromUuidString(String uuidStr) {
  // Parse the first part (8 hex digits = timeLow)
  final parts = uuidStr.split('-');
  final timeLow = int.parse(parts[0], radix: 16);
  final timeMid = int.parse(parts[1], radix: 16);
  final timeHighAndVersion = int.parse(parts[2], radix: 16);
  
  // Reconstruct MSB: timeLow << 32 | timeMid << 16 | timeHighAndVersion
  return (timeLow << 32) | (timeMid << 16) | timeHighAndVersion;
}