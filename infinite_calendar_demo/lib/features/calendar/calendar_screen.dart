import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/calendar_controller.dart';
import '../../models/event_entry.dart';
import '../../models/event_template.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/event_details_sheet.dart';
import 'widgets/loading_week_placeholder.dart';
import 'widgets/week_section.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _weekKeys = {};
  bool _hasAlignedToCurrentWeek = false;

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
    final notifier = ref.read(calendarControllerProvider.notifier);
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
    final state = ref.watch(calendarControllerProvider);

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
            title: const Text('Training calendar'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {},
              tooltip: 'Back',
            ),
            actions: [
              TextButton(onPressed: _handleSave, child: const Text('Save')),
            ],
          ),
          if (state.weeks.isEmpty)
            const SliverToBoxAdapter(child: LoadingWeekPlaceholder())
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
                  onResetPressed: _handleReset,
                  onCardTapped: _openEventDetails,
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
    ref.read(calendarControllerProvider.notifier).saveCurrentState();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Calendar saved.')));
  }

  void _handleReset() {
    ref.read(calendarControllerProvider.notifier).resetToSavedState();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes discarded.')));
    setState(() {
      _hasAlignedToCurrentWeek = false;
    });
  }

  Future<void> _openAddSheet(BuildContext context, DateTime day) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(calendarControllerProvider.notifier);
    final template = await showModalBottomSheet<EventTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddEventSheet(day: day);
      },
    );

    if (template == null) return;
    if (!mounted) return;
    final inserted = notifier.addEventFromTemplate(
      day: day,
      template: template,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text('Added to ${day.day} ${_monthFor(day)}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            notifier.removeEvent(day: day, event: inserted);
          },
        ),
      ),
    );
  }

  Future<void> _openEventDetails(DateTime day, CalendarEvent event) async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return EventDetailsSheet(event: event);
      },
    );

    if (!mounted) return;
    if (deleted == true) {
      final notifier = ref.read(calendarControllerProvider.notifier);
      notifier.removeEvent(day: day, event: event);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry removed.')));
    }
  }
}

String _monthFor(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return monthNames[date.month - 1];
}
