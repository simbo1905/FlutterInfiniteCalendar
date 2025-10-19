import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Bottom sheet with date picker for moving a meal to another day
class MoveMealDatePicker extends StatefulWidget {
  const MoveMealDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  @override
  State<MoveMealDatePicker> createState() => _MoveMealDatePickerState();

  /// Show the date picker as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => MoveMealDatePicker(
        initialDate: initialDate,
        onDateSelected: onDateSelected,
      ),
    );
  }
}

class _MoveMealDatePickerState extends State<MoveMealDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    debugPrint('[DATE_PICKER] Initialized with date: ${widget.initialDate}');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DATE_PICKER] Building picker, current selected: $_selectedDate');
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with title and Done button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Move to Date',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextButton(
                    key: const Key('date-picker-done'),
                    onPressed: () {
                      debugPrint('[DATE_PICKER] Done pressed, selected date: $_selectedDate');
                      Navigator.pop(context);
                      widget.onDateSelected(_selectedDate);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Cupertino Date Picker
            Expanded(
              child: CupertinoDatePicker(
                key: const Key('cupertino-date-picker'),
                mode: CupertinoDatePickerMode.date,
                initialDateTime: widget.initialDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  // Log date changes for test verification
                  debugPrint('[DATE_PICKER] Date changed from $_selectedDate to $newDate');
                  setState(() {
                    _selectedDate = newDate;
                  });
                  debugPrint('[DATE_PICKER] State updated, new selected date: $_selectedDate');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
