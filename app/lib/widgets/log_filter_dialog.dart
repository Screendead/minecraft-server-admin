import 'package:flutter/material.dart';
import '../models/log_entry.dart';

class LogFilterDialog extends StatefulWidget {
  final LogFilter currentFilter;
  final Function(LogFilter) onApplyFilter;
  final VoidCallback onClearFilter;

  const LogFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  @override
  State<LogFilterDialog> createState() => _LogFilterDialogState();
}

class _LogFilterDialogState extends State<LogFilterDialog> {
  late List<LogLevel> _selectedLevels;
  late List<LogCategory> _selectedCategories;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _sessionIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLevels = List.from(widget.currentFilter.levels ?? []);
    _selectedCategories = List.from(widget.currentFilter.categories ?? []);
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _searchController.text = widget.currentFilter.searchQuery ?? '';
    _userIdController.text = widget.currentFilter.userId ?? '';
    _sessionIdController.text = widget.currentFilter.sessionId ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _userIdController.dispose();
    _sessionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Logs'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Log Levels
            Text(
              'Log Levels',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LogLevel.values.map((level) {
                final isSelected = _selectedLevels.contains(level);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        level.icon,
                        size: 16,
                        color: level.color,
                      ),
                      const SizedBox(width: 4),
                      Text(level.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLevels.add(level);
                      } else {
                        _selectedLevels.remove(level);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Log Categories
            Text(
              'Log Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LogCategory.values.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Date Range
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Start Date',
                            style: TextStyle(
                              color:
                                  _startDate != null ? null : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'End Date',
                            style: TextStyle(
                              color: _endDate != null ? null : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Query
            Text(
              'Search Query',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search in messages and details...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // User ID
            Text(
              'User ID',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                hintText: 'Filter by specific user ID...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Session ID
            Text(
              'Session ID',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sessionIdController,
              decoration: const InputDecoration(
                hintText: 'Filter by specific session ID...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClearFilter();
            Navigator.of(context).pop();
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyFilter,
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _applyFilter() {
    final filter = LogFilter(
      levels: _selectedLevels.isEmpty ? null : _selectedLevels,
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      startDate: _startDate,
      endDate: _endDate,
      searchQuery:
          _searchController.text.isEmpty ? null : _searchController.text,
      userId: _userIdController.text.isEmpty ? null : _userIdController.text,
      sessionId:
          _sessionIdController.text.isEmpty ? null : _sessionIdController.text,
    );

    widget.onApplyFilter(filter);
    Navigator.of(context).pop();
  }

}
