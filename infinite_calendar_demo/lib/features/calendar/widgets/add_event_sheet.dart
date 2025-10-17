import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import '../../../models/event_template.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  const AddEventSheet({super.key, required this.day});

  final DateTime day;

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<EventTemplate> _templates;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(calendarControllerProvider.notifier);
    _templates = notifier.templates();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.read(calendarControllerProvider.notifier);
    final filtered = _query.trim().isEmpty
        ? _templates
        : notifier.searchTemplates(_query);

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add entry for ${widget.day.day} ${_monthFor(widget.day)}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search items',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matches',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final template = filtered[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: template.color.withValues(
                                alpha: 0.2,
                              ),
                              child: Icon(template.icon, color: template.color),
                            ),
                            title: Text(template.title),
                            subtitle: Text(template.quantity),
                            trailing: TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(template),
                              child: const Text('Add'),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
