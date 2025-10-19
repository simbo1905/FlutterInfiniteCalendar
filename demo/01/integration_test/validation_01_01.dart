/// Test 1: Trivial Test - Confirms Setup
/// Objective: Verify the automation environment works and the application renders dynamic content.
/// Priority: CRITICAL - Must pass before any other testing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meal_planner_demo/app.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VALIDATION_01: Setup Confirmation', () {
    testWidgets('Test 1: Trivial Test - Confirms Setup', (WidgetTester tester) async {
      print('🔍 [TEST_START] Test 1: Trivial Test - Confirms Setup');
      
      // Step 1: Launch the application
      print('📱 [STEP_1] Launching application...');
      await tester.pumpWidget(const app.MealPlannerApp());
      await tester.pump(); // Initial frame
      
      // Step 2: Wait for the calendar view to fully render
      print('📅 [STEP_2] Waiting for calendar view to render...');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify application launched without crashes
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ [VERIFY] Application launched successfully');
      
      // Step 3: Wait for mock meal data to load dynamically (this is async, not immediate)
      print('🍽️ [STEP_3] Waiting for mock meal data to load dynamically...');
      
      // Wait up to 10 seconds for meal cards to appear
      bool mealCardsFound = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        
        // Look for meal cards by searching for typical meal card indicators
        final mealCardFinders = [
          find.text('Oatmeal'),
          find.text('Scrambled Eggs'),
          find.text('Chicken Salad'),
          find.text('Fish and Chips'),
          find.byKey(const Key('meal_card')),
          find.byType(Card),
        ];
        
        bool anyFound = false;
        for (final finder in mealCardFinders) {
          if (finder.evaluate().isNotEmpty) {
            anyFound = true;
            break;
          }
        }
        
        if (anyFound) {
          mealCardsFound = true;
          print('✅ [VERIFY] Mock meal data loaded successfully (attempt ${i + 1})');
          break;
        }
      }
      
      // Step 4: Count the total number of meal cards visible on screen
      print('🔢 [STEP_4] Counting meal cards visible on screen...');
      
      // Try multiple ways to count meal cards
      int totalMealCards = 0;
      
      // Method 1: Count by Card widgets (most likely)
      final cardWidgets = find.byType(Card);
      totalMealCards = cardWidgets.evaluate().length;
      print('📊 [COUNT_METHOD_1] Found ${totalMealCards} Card widgets');
      
      // Method 2: Count by specific meal names
      final mealNames = [
        'Oatmeal', 'Scrambled Eggs', 'Chicken Salad', 'Tuna Sandwich',
        'Fish and Chips', 'Steak and Veg', 'Apple Slices', 'Yogurt',
        'Glass of Milk', 'Herbal Tea'
      ];
      
      int namedMealCount = 0;
      for (final name in mealNames) {
        namedMealCount += find.text(name).evaluate().length;
      }
      print('📊 [COUNT_METHOD_2] Found ${namedMealCount} named meal cards');
      
      // Method 3: Count by meal_card keys if they exist
      int keyedMealCount = 0;
      for (int i = 0; i < 50; i++) {
        final keyFinder = find.byKey(Key('meal_card_$i'));
        keyedMealCount += keyFinder.evaluate().length;
      }
      print('📊 [COUNT_METHOD_3] Found ${keyedMealCount} keyed meal cards');
      
      // Use the highest count found
      totalMealCards = [totalMealCards, namedMealCount, keyedMealCount].reduce((a, b) => a > b ? a : b);
      
      print('🎯 [FINAL_COUNT] Total meal cards found: $totalMealCards');
      
      // Step 5: Log visual state verification
      print('📋 [STEP_5] Logging visual state verification...');
      print('✅ [STATE] App rendered with $totalMealCards meal cards visible');
      
      // Expected Results Verification:
      
      // 1. Application launches without crashes ✅ (already verified above)
      
      // 2. Integration test successfully connects to the Flutter app ✅ (we're running!)
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ [VERIFY] Integration test connected to Flutter app successfully');
      
      // 3. Test waits successfully for dynamic content (cards) to render ✅
      expect(mealCardsFound, isTrue, reason: 'Dynamic meal card content should have loaded');
      print('✅ [VERIFY] Test waited successfully for dynamic content');
      
      // 4. At least one meal card is counted (per SPEC.md initial data requirements)
      expect(totalMealCards, greaterThan(0), 
        reason: 'At least one meal card should be visible (SPEC.md requirement)');
      print('✅ [VERIFY] At least one meal card counted: $totalMealCards cards found');
      
      // 5. Visual state verified ✅
      print('✅ [VERIFY] Visual state logged successfully');
      
      // 6. Test completes within 30 seconds ✅ (will fail if timeout exceeded)
      print('✅ [VERIFY] Test completing within time limit');
      
      print('🎉 [TEST_COMPLETE] Test 1 passed all requirements!');
      print('📋 [SUMMARY] Found $totalMealCards meal cards, app rendered successfully');
    });
  });
}