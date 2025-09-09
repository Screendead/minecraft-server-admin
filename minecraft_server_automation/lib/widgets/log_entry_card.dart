import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

class LogEntryCard extends StatelessWidget {
  final LogEntry log;
  final VoidCallback? onTap;

  const LogEntryCard({
    super.key,
    required this.log,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    log.level.icon,
                    size: 20,
                    color: log.level.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.level.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: log.level.color,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimestamp(log.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(log.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(log.category)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      log.category.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(log.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (log.userId != null)
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                log.message,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (log.details != null && log.details!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  log.details!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (log.metadata != null && log.metadata!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${log.metadata!.length} metadata field${log.metadata!.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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
