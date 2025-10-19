import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_boardview/board_item.dart';
import 'package:flutter_boardview/board_list.dart';
import 'package:flutter_boardview/boardview.dart';
import 'package:flutter_boardview/boardview_controller.dart';
import '../../controllers/board_controller.dart';
import '../../models/meal_instance.dart';
import '../../models/meal_template.dart';
import '../../util/app_logger.dart';
import 'widgets/add_meal_sheet.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/meal_card.dart';

class BoardMealScreen extends ConsumerStatefulWidget {
  const BoardMealScreen({super.key});

  @override
  ConsumerState<BoardMealScreen> createState() => _BoardMealScreenState();
}

class _BoardMealScreenState extends ConsumerState<BoardMealScreen> {
  late BoardViewController _boardViewController;
  bool _hasLoggedInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _boardViewController = BoardViewController();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boardControllerProvider);

    if (!_hasLoggedInitialLoad && state.days.isNotEmpty) {
      AppLogger.screenLoad('Initial Load');
      _hasLoggedInitialLoad = true;
    }

    return Scaffold(
      appBar: AppBar(
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
      body: state.days.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : BoardView(
              lists: _buildBoardLists(state),
              boardViewController: _boardViewController,
            ),
    );
  }

  List<BoardList> _buildBoardLists(BoardState state) {
    final lists = <BoardList>[];
    
    for (int i = 0; i < state.days.length; i++) {
      final day = state.days[i];
      final offset = state.dayMap.keys.elementAt(i);
      
      lists.add(
        BoardList(
          onStartDragList: (int? listIndex) {},
          onTapList: (int? listIndex) async {},
          onDropList: (int? listIndex, int? oldListIndex) {},
          headerBackgroundColor: day.isToday 
            ? Theme.of(context).colorScheme.primaryContainer
            : const Color.fromARGB(255, 235, 236, 240),
          backgroundColor: const Color.fromARGB(255, 245, 246, 250),
          header: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDayLabel(day.date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
                      color: day.isToday 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                    ),
                  ),
                  Text(
                    formatDayNumber(day.date),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                      color: day.isToday 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
          items: _buildBoardItems(day, offset),
        ),
      );
    }
    
    return lists;
  }

  List<BoardItem> _buildBoardItems(CalendarDay day, int dayOffset) {
    final items = <BoardItem>[];
    
    for (int i = 0; i < day.meals.length; i++) {
      final meal = day.meals[i];
      items.add(
        BoardItem(
          onStartDragItem: (int? listIndex, int? itemIndex, BoardItemState? state) {},
          onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex, int? oldItemIndex, BoardItemState? state) {
            if (listIndex == null || itemIndex == null || oldListIndex == null || oldItemIndex == null) {
              return;
            }
            
            final boardState = ref.read(boardControllerProvider);
            if (oldListIndex >= boardState.days.length || listIndex >= boardState.days.length) {
              return;
            }
            
            final fromDay = boardState.days[oldListIndex];
            final toDay = boardState.days[listIndex];
            
            if (oldItemIndex >= fromDay.meals.length) {
              return;
            }
            
            final mealToMove = fromDay.meals[oldItemIndex];
            
            ref.read(boardControllerProvider.notifier).moveMeal(
              fromDay: fromDay.date,
              toDay: toDay.date,
              meal: mealToMove,
              insertIndex: itemIndex,
            );
          },
          onTapItem: (int? listIndex, int? itemIndex, BoardItemState? state) async {},
          item: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: MealCard(
              meal: meal,
              onDelete: () => _handleMealDelete(day.date, meal),
            ),
          ),
        ),
      );
    }
    
    items.add(
      BoardItem(
        onStartDragItem: (int? listIndex, int? itemIndex, BoardItemState? state) {},
        onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex, int? oldItemIndex, BoardItemState? state) {},
        onTapItem: (int? listIndex, int? itemIndex, BoardItemState? state) async {
          if (listIndex != null && listIndex < ref.read(boardControllerProvider).days.length) {
            final day = ref.read(boardControllerProvider).days[listIndex];
            _openAddSheet(context, day.date);
          }
        },
        item: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Add Meal',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    return items;
  }

  void _handleSave() {
    ref.read(boardControllerProvider.notifier).saveCurrentState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved')),
    );
  }

  void _handleReset() {
    ref.read(boardControllerProvider.notifier).resetToSavedState();
    if (!mounted) return;
    
    AppLogger.screenLoad('Reset');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes discarded')),
    );
  }

  Future<void> _openAddSheet(BuildContext context, DateTime day) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(boardControllerProvider.notifier);
    
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

    final notifier = ref.read(boardControllerProvider.notifier);
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
