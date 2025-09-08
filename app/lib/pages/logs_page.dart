import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/logs_provider.dart';
import '../models/log_entry.dart';
import '../widgets/log_filter_dialog.dart';
import '../widgets/log_entry_card.dart';
import '../widgets/log_statistics_card.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize logs provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLogs,
            tooltip: 'Refresh logs',
          ),
          PopupMenuButton<String>(
            onSelected: _handleExport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'text',
                child: Row(
                  children: [
                    Icon(Icons.text_snippet),
                    SizedBox(width: 8),
                    Text('Export as Text'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.download),
            tooltip: 'Export logs',
          ),
          PopupMenuButton<String>(
            onSelected: _handleClear,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'old_7',
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text('Clear Logs Older Than 7 Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'old_30',
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text('Clear Logs Older Than 30 Days'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.delete),
            tooltip: 'Clear logs',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                _buildFixedWidthTab('All', Icons.list),
                _buildFixedWidthTab('Errors', Icons.error),
                _buildFixedWidthTab('Warnings', Icons.warning),
                _buildFixedWidthTab('User Actions', Icons.person),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Statistics card
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LogStatisticsCard(),
          ),

          const SizedBox(height: 8),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLogsList(),
                _buildErrorLogsList(),
                _buildWarningLogsList(),
                _buildUserInteractionLogsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        if (logsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (logsProvider.error != null) {
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
                  logsProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshLogs,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final logs = _searchQuery.isEmpty
            ? logsProvider.logs
            : logsProvider.searchLogs(_searchQuery);

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
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'No logs have been recorded yet'
                      : 'No logs match your search',
                  style: Theme.of(context).textTheme.bodyMedium,
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
              onTap: () => _showLogDetails(log),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final errorLogs = logsProvider.getErrorLogs();
        return _buildLogsListFromLogs(errorLogs);
      },
    );
  }

  Widget _buildWarningLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final warningLogs = logsProvider.getWarningLogs();
        return _buildLogsListFromLogs(warningLogs);
      },
    );
  }

  Widget _buildUserInteractionLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final userLogs = logsProvider.getUserInteractionLogs();
        return _buildLogsListFromLogs(userLogs);
      },
    );
  }

  Widget _buildLogsListFromLogs(List<LogEntry> logs) {
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
          onTap: () => _showLogDetails(log),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => LogFilterDialog(
        currentFilter: context.read<LogsProvider>().currentFilter,
        onApplyFilter: (filter) {
          context.read<LogsProvider>().applyFilter(filter);
        },
        onClearFilter: () {
          context.read<LogsProvider>().clearFilter();
        },
      ),
    );
  }

  void _showLogDetails(LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getLogLevelIcon(log.level),
              color: _getLogLevelColor(log.level),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(log.level.displayName)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', log.category.displayName),
              _buildDetailRow('Timestamp', log.timestamp.toString()),
              _buildDetailRow('Message', log.message),
              if (log.details != null && log.details!.isNotEmpty)
                _buildDetailRow('Details', log.details!),
              if (log.userId != null) _buildDetailRow('User ID', log.userId!),
              if (log.sessionId != null)
                _buildDetailRow('Session ID', log.sessionId!),
              if (log.metadata != null && log.metadata!.isNotEmpty)
                _buildDetailRow('Metadata', log.metadata.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _refreshLogs() {
    context.read<LogsProvider>().refreshLogs();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _handleExport(String format) async {
    try {
      String content;
      String fileName;
      String mimeType;

      switch (format) {
        case 'json':
          content = await context.read<LogsProvider>().exportToJson();
          fileName = 'logs_${DateTime.now().millisecondsSinceEpoch}.json';
          mimeType = 'application/json';
          break;
        case 'csv':
          content = await context.read<LogsProvider>().exportToCsv();
          fileName = 'logs_${DateTime.now().millisecondsSinceEpoch}.csv';
          mimeType = 'text/csv';
          break;
        case 'text':
          content = await context.read<LogsProvider>().exportToText();
          fileName = 'logs_${DateTime.now().millisecondsSinceEpoch}.txt';
          mimeType = 'text/plain';
          break;
        default:
          return;
      }

      await Share.shareXFiles(
        [
          XFile.fromData(Uint8List.fromList(content.codeUnits),
              name: fileName, mimeType: mimeType)
        ],
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleClear(String action) async {
    final logsProvider = context.read<LogsProvider>();

    switch (action) {
      case 'all':
        final confirmed = await _showConfirmDialog(
          'Clear All Logs',
          'Are you sure you want to clear all logs? This action cannot be undone.',
        );
        if (confirmed == true) {
          await logsProvider.clearAllLogs();
        }
        break;
      case 'old_7':
        final confirmed = await _showConfirmDialog(
          'Clear Old Logs',
          'Are you sure you want to clear logs older than 7 days?',
        );
        if (confirmed == true) {
          await logsProvider.clearOldLogs(7);
        }
        break;
      case 'old_30':
        final confirmed = await _showConfirmDialog(
          'Clear Old Logs',
          'Are you sure you want to clear logs older than 30 days?',
        );
        if (confirmed == true) {
          await logsProvider.clearOldLogs(30);
        }
        break;
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  IconData _getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.fatal:
        return Icons.dangerous;
    }
  }

  Color _getLogLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blue;
      case LogLevel.info:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.fatal:
        return Colors.purple;
    }
  }

  Widget _buildFixedWidthTab(String text, IconData icon) {
    return SizedBox(
      width: 100, // Smaller width to ensure scrollability indication
      child: Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
