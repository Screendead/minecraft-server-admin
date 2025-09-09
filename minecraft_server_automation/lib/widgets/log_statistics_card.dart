import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minecraft_server_automation/providers/logs_provider.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

class LogStatisticsCard extends StatelessWidget {
  const LogStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogsProvider>(
      builder: (context, logsProvider, child) {
        final stats = logsProvider.getLogStatistics();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Log Statistics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Total count
                _buildStatRow(
                  'Total Logs',
                  stats['total_count']?.toString() ?? '0',
                  Icons.list,
                  Colors.blue,
                ),

                const SizedBox(height: 8),

                // Level counts
                Row(
                  children: [
                    Expanded(
                      child: _buildStatRow(
                        'Debug',
                        stats['debug_count']?.toString() ?? '0',
                        Icons.bug_report,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 24), // Add spacing between columns
                    Expanded(
                      child: _buildStatRow(
                        'Info',
                        stats['info_count']?.toString() ?? '0',
                        Icons.info,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatRow(
                        'Warning',
                        stats['warning_count']?.toString() ?? '0',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 24), // Add spacing between columns
                    Expanded(
                      child: _buildStatRow(
                        'Error',
                        stats['error_count']?.toString() ?? '0',
                        Icons.error,
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatRow(
                        'Fatal',
                        stats['fatal_count']?.toString() ?? '0',
                        Icons.dangerous,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 24), // Add spacing for consistency
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 16),

                // Category counts
                Text(
                  'By Category',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                // Create a grid-like layout for categories
                LayoutBuilder(
                  builder: (context, constraints) {
                    final categories = LogCategory.values
                        .where((category) =>
                            (stats['${category.name}_count'] ?? 0) > 0)
                        .toList();

                    if (categories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final count = stats['${category.name}_count'] ?? 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  _getCategoryColor(category).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getCategoryColor(category),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getCategoryColor(category),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(LogCategory category) {
    switch (category) {
      case LogCategory.userInteraction:
        return Colors.blue;
      case LogCategory.apiCall:
        return Colors.green;
      case LogCategory.authentication:
        return Colors.purple;
      case LogCategory.dropletManagement:
        return Colors.orange;
      case LogCategory.serverManagement:
        return Colors.teal;
      case LogCategory.error:
        return Colors.red;
      case LogCategory.system:
        return Colors.grey;
      case LogCategory.security:
        return Colors.indigo;
    }
  }
}
