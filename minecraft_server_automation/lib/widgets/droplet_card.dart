import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/providers/droplets_provider.dart';
import 'package:minecraft_server_automation/services/minecraft_server_service.dart';
import 'package:minecraft_server_automation/common/widgets/forms/spec_chip.dart';

/// Widget displaying a single droplet card
class DropletCard extends StatelessWidget {
  final DropletInfo droplet;

  const DropletCard({
    super.key,
    required this.droplet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Droplet header
            Row(
              children: [
                Icon(
                  droplet.isMinecraftServer
                      ? Icons.sports_esports
                      : Icons.cloud,
                  color: droplet.isMinecraftServer ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    droplet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(droplet.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    droplet.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // IP address
            if (droplet.publicIp != null)
              Text(
                'IP: ${droplet.publicIp}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),

            // Minecraft server info
            if (droplet.isMinecraftServer && droplet.minecraftInfo != null)
              _buildMinecraftInfo(droplet.minecraftInfo!),

            // Droplet details
            const SizedBox(height: 8),
            Row(
              children: [
                SpecChip(
                  icon: Icons.location_on,
                  label: 'Region',
                  value: droplet.region,
                  isSelected: false,
                ),
                const SizedBox(width: 8),
                SpecChip(
                  icon: Icons.memory,
                  label: 'Size',
                  value: droplet.size,
                  isSelected: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinecraftInfo(MinecraftServerInfo minecraftInfo) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Minecraft Server',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Version: ${minecraftInfo.version}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Players: ${minecraftInfo.playersOnline}/${minecraftInfo.playersMax}',
            style: const TextStyle(fontSize: 12),
          ),
          if (minecraftInfo.motd != null)
            Text(
              'MOTD: ${minecraftInfo.motd}',
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'off':
        return Colors.red;
      case 'new':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
