import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';
import 'package:minecraft_server_automation/widgets/log_entry_card.dart';

class FilteredLogsList extends StatelessWidget {
  final List<LogEntry> logs;
  final Function(LogEntry) onLogTap;

  const FilteredLogsList({
    super.key,
    required this.logs,
    required this.onLogTap,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No logs found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return LogEntryCard(
          log: log,
          onTap: () => onLogTap(log),
        );
      },
    );
  }
}
