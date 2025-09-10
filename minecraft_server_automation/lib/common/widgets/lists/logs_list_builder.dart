import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minecraft_server_automation/providers/logs_provider.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';
import 'package:minecraft_server_automation/widgets/log_entry_card.dart';
import 'package:minecraft_server_automation/common/widgets/feedback/loading_overlay.dart';

class LogsListBuilder extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onRefresh;
  final Function(LogEntry) onLogTap;

  const LogsListBuilder({
    super.key,
    required this.searchQuery,
    required this.onRefresh,
    required this.onLogTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        if (logsProvider.error != null) {
          return _buildErrorState(context, logsProvider.error!, onRefresh);
        }

        final logs = searchQuery.isEmpty
            ? logsProvider.logs
            : logsProvider.searchLogs(searchQuery);

        if (logs.isEmpty && !logsProvider.isLoading) {
          return _buildEmptyState(context, searchQuery);
        }

        return LoadingOverlay(
          isLoading: logsProvider.isLoading,
          loadingMessage: 'Loading logs...',
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return LogEntryCard(
                log: log,
                onTap: () => onLogTap(log),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
      BuildContext context, String error, VoidCallback onRefresh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading logs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery) {
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
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'No logs have been recorded yet'
                : 'No logs match your search',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
