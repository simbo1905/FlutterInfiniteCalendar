import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/meal_controller.dart';
import '../../models/meal_instance.dart';
import '../../models/meal_template.dart';
import '../../util/app_logger.dart';
import 'widgets/week_section.dart';
import 'widgets/add_meal_sheet.dart';
import 'widgets/delete_confirmation_dialog.dart';

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
                  onMealDelete: _handleMealDelete,
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

  Future<void> _handleMealDelete(DateTime day, MealInstance meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(mealTitle: meal.title);
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

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
