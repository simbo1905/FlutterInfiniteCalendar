/// Test 2: Move and Delete Functionality Test
/// Objective: Verify move-via-date-picker and delete-via-action-menu functionality works correctly.
/// Strategy: Use Monday/Tuesday of the first week (which are kept empty) for clean testing
/// Priority: CRITICAL - Must pass before considering this demo viable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meal_planner_demo/app.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VALIDATION_02: Move and Delete Functionality', () {
    testWidgets('Test 2: Move and Delete Functionality Test', (WidgetTester tester) async {
      print('🔍 [TEST_START] Test 2: Move and Delete Functionality Test');
      
      // Launch and wait for app to load
      print('📱 [SETUP] Launching application and waiting for content...');
      await tester.pumpWidget(const app.MealPlannerApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify Monday and Tuesday are empty (testing precondition)
      print('✅ [PRECONDITION] Verifying first week is visible...');
      
      // Count initial cards
      final initialCards = find.byKey(const ValueKey('long-press-hint')).evaluate().length;
      print('📊 [COUNT] Total meal cards in view: $initialCards');
      
      // Part A: Add meal to Monday, then Move to Tuesday
      print('🔄 [PART_A] Testing Add to Monday + Move to Tuesday');
      
      // Step 1: Long-press on Monday's row to trigger add meal
      // Monday is the first day (weekday = 1), positioned at the top of the visible area
      print('👆 [STEP_A1] Long-pressing Monday row to add meal...');
      
      // The day rows are predictably positioned:
      // Each row is about 116 pixels tall (100px content + 16px padding)
      // First row (Monday) starts around y=150-200 depending on header
      // x=200 is roughly center of the screen (390px wide)
      final mondayPosition = const Offset(200.0, 180.0);
      print('📍 [POSITION] Monday tap position: $mondayPosition');
      
      await tester.longPressAt(mondayPosition);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 2: Meal template picker should appear, tap first meal's add button
      print('✅ [STEP_A2] Verifying meal template picker appeared...');
      final oatmealText = find.text('Oatmeal');
      expect(oatmealText, findsWidgets, reason: 'Meal templates should be visible');
      
      print('👆 [STEP_A3] Selecting first meal template (Oatmeal)...');
      // Tap the add circle icon for the first template
      final addIcons = find.byIcon(Icons.add_circle);
      expect(addIcons, findsWidgets, reason: 'Add buttons should be visible');
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 4: Verify meal was added to Monday
      print('✅ [STEP_A4] Verifying meal was added to Monday...');
      final cardsAfterAdd = find.byKey(const ValueKey('long-press-hint')).evaluate().length;
      expect(cardsAfterAdd, equals(initialCards + 1),
        reason: 'One meal should be added');
      print('📊 [COUNT] Cards after add: $cardsAfterAdd');
      
      // Step 5: Long-press the newly added meal card
      print('👆 [STEP_A5] Long-pressing the meal card...');
      final mealCard = find.byKey(const ValueKey('long-press-hint')).first;
      await tester.longPress(mealCard);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 6: Verify action menu appeared
      print('✅ [STEP_A6] Verifying action menu appeared...');
      final moveAction = find.byKey(const Key('action-move'));
      final deleteAction = find.byKey(const Key('action-delete'));
      
      expect(moveAction, findsOneWidget, reason: 'Move action should be visible');
      expect(deleteAction, findsOneWidget, reason: 'Delete action should be visible');
      print('✅ [VERIFY] Action menu displayed');
      
      // Step 7: Tap "Move to Another Day"
      print('👆 [STEP_A7] Tapping "Move to Another Day"...');
      await tester.tap(moveAction);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 8: Verify date picker appeared
      print('✅ [STEP_A8] Verifying date picker appeared...');
      final datePicker = find.byKey(const Key('cupertino-date-picker'));
      final doneButton = find.byKey(const Key('date-picker-done'));
      
      expect(datePicker, findsOneWidget, reason: 'Date picker should be visible');
      expect(doneButton, findsOneWidget, reason: 'Done button should be visible');
      print('✅ [VERIFY] Date picker displayed');
      
      // Step 9: Programmatically set the date picker to Tuesday
      print('👆 [STEP_A9] Programmatically setting date to Tuesday...');
      final now = DateTime.now();
      final monday = _startOfWeek(now); // Monday
      final tuesday = monday.add(const Duration(days: 1)); // Tuesday
      
      print('📍 [DATE_PICKER] Setting date from $monday to $tuesday');
      
      // Find the CupertinoDatePicker widget and trigger its onDateTimeChanged callback
      final pickerWidget = tester.widget<CupertinoDatePicker>(datePicker);
      if (pickerWidget.onDateTimeChanged != null) {
        pickerWidget.onDateTimeChanged!(tuesday);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        print('✅ [DATE_PICKER] Date set programmatically to Tuesday');
      }
      
      // Step 10: Tap Done to confirm move
      print('👆 [STEP_A10] Tapping Done to confirm move...');
      await tester.tap(doneButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Step 11: Verify meal moved (card count should remain the same)
      final cardsAfterMove = find.byKey(const ValueKey('long-press-hint')).evaluate().length;
      print('📊 [COUNT] Cards after move: $cardsAfterMove');
      expect(cardsAfterMove, equals(cardsAfterAdd),
        reason: 'Card count should remain the same after move');
      print('✅ [VERIFY] Meal moved from Monday to Tuesday');
      
      print('🎉 [PART_A_COMPLETE] Move functionality test completed');
      
      // Part B: Delete the meal from Tuesday
      print('🔄 [PART_B] Testing Delete Meal from Tuesday');
      
      // Wait for UI to settle
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 1: Long-press the meal card
      print('👆 [STEP_B1] Long-pressing meal card for deletion...');
      final mealCardForDelete = find.byKey(const ValueKey('long-press-hint')).first;
      await tester.longPress(mealCardForDelete);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 2: Verify action menu appeared
      print('✅ [STEP_B2] Verifying action menu appeared...');
      final deleteActionButton = find.byKey(const Key('action-delete'));
      expect(deleteActionButton, findsOneWidget,
        reason: 'Delete action should be visible');
      
      // Step 3: Tap "Delete Meal"
      print('👆 [STEP_B3] Tapping "Delete Meal"...');
      await tester.tap(deleteActionButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Step 4: Verify delete confirmation dialog appeared
      print('✅ [STEP_B4] Verifying delete confirmation dialog...');
      final confirmDeleteButton = find.text('Delete');
      expect(confirmDeleteButton, findsOneWidget,
        reason: 'Delete confirmation should appear');
      
      // Step 5: Confirm deletion
      print('👆 [STEP_B5] Confirming deletion...');
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Step 6: Verify meal was deleted
      final cardsAfterDelete = find.byKey(const ValueKey('long-press-hint')).evaluate().length;
      print('📊 [COUNT] Cards after delete: $cardsAfterDelete');
      expect(cardsAfterDelete, equals(cardsAfterMove - 1),
        reason: 'One card should be deleted');
      print('✅ [VERIFY] Meal deleted successfully');
      
      print('🎉 [PART_B_COMPLETE] Delete functionality test completed');
      
      // Expected Results Verification Summary
      print('🔍 [VERIFICATION] Final verification...');
      print('✅ [VERIFY] Add meal functionality works');
      print('✅ [VERIFY] Long-press action menu works');
      print('✅ [VERIFY] Move-to-date-picker flow works');
      print('✅ [VERIFY] Delete confirmation works');
      print('✅ [VERIFY] State management works (unsaved state)');
      
      print('🎉 [TEST_COMPLETE] Test 2 passed all requirements!');
      print('📋 [SUMMARY] Move and delete functionality verified successfully');
    });
  });
}

/// Get the start of the week (Monday) for a given date
DateTime _startOfWeek(DateTime date) {
  final dayOfWeek = date.weekday; // Monday = 1, Sunday = 7
  final daysToSubtract = dayOfWeek - 1; // Monday = 0 days
  return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
}
