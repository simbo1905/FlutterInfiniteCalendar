import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/meal_controller.dart';
import '../../models/meal_instance.dart';
import '../../models/meal_template.dart';
import '../../util/app_logger.dart';
import 'widgets/week_section.dart';
import 'widgets/add_meal_sheet.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/meal_card_actions_sheet.dart';
import 'widgets/move_meal_date_picker.dart';

class MealCalendarScreen extends ConsumerStatefulWidget {
  const MealCalendarScreen({super.key});

  @override
  ConsumerState<MealCalendarScreen> createState() => _MealCalendarScreenState();
}

class _MealCalendarScreenState extends ConsumerState<MealCalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _weekKeys = {};
  bool _hasAlignedToCurrentWeek = false;
  bool _hasLoggedInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final notifier = ref.read(mealControllerProvider.notifier);
    final position = _scrollController.position;
    const threshold = 600.0;
    
    if (position.extentAfter < threshold) {
      notifier.loadNextWeek();
    }
    if (position.pixels <= threshold && position.extentBefore < threshold) {
      notifier.loadPreviousWeek();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealControllerProvider);

    if (!_hasLoggedInitialLoad && state.weeks.isNotEmpty) {
      AppLogger.screenLoad('Initial Load');
      _hasLoggedInitialLoad = true;
    }

    if (!_hasAlignedToCurrentWeek && state.weeks.any((w) => w.index == 0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasAlignedToCurrentWeek) {
          return;
        }
        final contextForWeek = _weekKeys[0]?.currentContext;
        if (contextForWeek != null) {
          Scrollable.ensureVisible(
            contextForWeek,
            duration: const Duration(milliseconds: 250),
            alignment: 0.05,
          );
          setState(() {
            _hasAlignedToCurrentWeek = true;
          });
        }
      });
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: const Text('Meal Planner'),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final count = ref.watch(plannedMealsCountProvider);
                  final text = count == 0 
                    ? 'No Planned Meals' 
                    : 'Planned Meals: $count';
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        text,
                        key: const Key('planned_meals_counter'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
              TextButton(
                key: const Key('saveButton'),
                onPressed: _handleSave,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Save'),
              ),
              Tooltip(
                message: 'Reset to last saved state',
                child: TextButton.icon(
                  key: const Key('resetButton'),
                  onPressed: _handleReset,
                  icon: const Icon(Icons.restore, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (state.weeks.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverList.builder(
              itemCount: state.weeks.length,
              itemBuilder: (context, index) {
                final week = state.weeks[index];
                final key = _weekKeys.putIfAbsent(
                  week.index,
                  () => GlobalKey(),
                );
                return WeekSection(
                  key: key,
                  week: week,
                  onAddPressed: (day) => _openAddSheet(context, day),
                  onMealLongPress: _handleMealLongPress,
                );
              },
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: state.isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    ref.read(mealControllerProvider.notifier).saveCurrentState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved')),
    );
  }

  void _handleReset() {
    ref.read(mealControllerProvider.notifier).resetToSavedState();
    if (!mounted) return;
    
    AppLogger.screenLoad('Reset');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes discarded')),
    );
    setState(() {
      _hasAlignedToCurrentWeek = false;
    });
  }

  Future<void> _openAddSheet(BuildContext context, DateTime day) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(mealControllerProvider.notifier);
    
    notifier.setSelectedDay(day);
    
    final template = await showModalBottomSheet<MealTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddMealSheet(day: day);
      },
    );

    if (template == null) return;
    if (!mounted) return;
    
    notifier.addMealFromTemplate(
      day: day,
      template: template,
    );
    
    messenger.showSnackBar(
      SnackBar(content: Text('Added ${template.title} to ${_formatDay(day)}')),
    );
  }

  Future<void> _handleMealLongPress(MealInstance meal, DateTime day) async {
    debugPrint('[ACTION] Long-press detected on meal: ${meal.title} on $day');
    await MealCardActionsSheet.show(
      context: context,
      mealTitle: meal.title,
      onMove: () => _handleMealMove(meal, day),
      onDelete: () => _handleMealDelete(day, meal),
    );
  }

  Future<void> _handleMealMove(MealInstance meal, DateTime fromDay) async {
    debugPrint('[ACTION] Move action selected for meal: ${meal.title}');
    await MoveMealDatePicker.show(
      context: context,
      initialDate: fromDay,
      onDateSelected: (newDate) {
        if (!mounted) return;
        
        debugPrint('[ACTION] Date selected: $newDate (from: $fromDay)');
        
        // Only move if date actually changed
        if (newDate.year != fromDay.year ||
            newDate.month != fromDay.month ||
            newDate.day != fromDay.day) {
          debugPrint('[ACTION] Moving meal ${meal.title} from $fromDay to $newDate');
          final notifier = ref.read(mealControllerProvider.notifier);
          notifier.moveMeal(
            fromDay: fromDay,
            toDay: newDate,
            meal: meal,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Moved ${meal.title} to ${_formatDay(newDate)}')),
          );
        } else {
          debugPrint('[ACTION] Date unchanged, no move performed');
        }
      },
    );
  }

  Future<void> _handleMealDelete(DateTime day, MealInstance meal) async {
    debugPrint('[ACTION] Delete action selected for meal: ${meal.title}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(mealTitle: meal.title);
      },
    );

    if (confirmed != true) {
      debugPrint('[ACTION] Delete cancelled');
      return;
    }
    if (!mounted) return;

    debugPrint('[ACTION] Delete confirmed, removing meal: ${meal.title}');
    final notifier = ref.read(mealControllerProvider.notifier);
    notifier.removeMeal(day: day, meal: meal);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal removed')),
    );
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
