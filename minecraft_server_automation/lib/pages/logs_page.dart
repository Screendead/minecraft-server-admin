import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:minecraft_server_automation/providers/logs_provider.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';
import 'package:minecraft_server_automation/widgets/log_filter_dialog.dart';
import 'package:minecraft_server_automation/widgets/log_statistics_card.dart';
import 'package:minecraft_server_automation/common/widgets/forms/fixed_width_tab.dart';
import 'package:minecraft_server_automation/common/widgets/lists/logs_list_builder.dart';
import 'package:minecraft_server_automation/common/widgets/lists/filtered_logs_list.dart';

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
          child: SizedBox(
            height: 48,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                FixedWidthTab(text: 'All', icon: Icons.list),
                FixedWidthTab(text: 'Errors', icon: Icons.error),
                FixedWidthTab(text: 'Warnings', icon: Icons.warning),
                FixedWidthTab(text: 'User Actions', icon: Icons.person),
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
                LogsListBuilder(
                  searchQuery: _searchQuery,
                  onRefresh: _refreshLogs,
                  onLogTap: _showLogDetails,
                ),
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

  Widget _buildErrorLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final errorLogs = logsProvider.getErrorLogs();
        return FilteredLogsList(
          logs: errorLogs,
          onLogTap: _showLogDetails,
        );
      },
    );
  }

  Widget _buildWarningLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final warningLogs = logsProvider.getWarningLogs();
        return FilteredLogsList(
          logs: warningLogs,
          onLogTap: _showLogDetails,
        );
      },
    );
  }

  Widget _buildUserInteractionLogsList() {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final userLogs = logsProvider.getUserInteractionLogs();
        return FilteredLogsList(
          logs: userLogs,
          onLogTap: _showLogDetails,
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
              log.level.icon,
              color: log.level.color,
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
}
