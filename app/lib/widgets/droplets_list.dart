import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/droplets_provider.dart';
import 'droplet_card.dart';

/// Widget displaying the list of droplets with Minecraft servers at the top
class DropletsList extends StatelessWidget {
  const DropletsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DropletsProvider>(
      builder: (context, dropletsProvider, child) {
        if (dropletsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (dropletsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading droplets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  dropletsProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => dropletsProvider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (dropletsProvider.droplets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No droplets found',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Create some droplets in your DigitalOcean account',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final minecraftDroplets = dropletsProvider.minecraftDroplets;
        final nonMinecraftDroplets = dropletsProvider.nonMinecraftDroplets;

        return RefreshIndicator(
          onRefresh: () => dropletsProvider.refresh(),
          child: CustomScrollView(
            slivers: [
              // Minecraft servers section
              if (minecraftDroplets.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sports_esports,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Minecraft Servers (${minecraftDroplets.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => DropletCard(
                      droplet: minecraftDroplets[index],
                    ),
                    childCount: minecraftDroplets.length,
                  ),
                ),
              ],

              // Other droplets section (collapsible)
              if (nonMinecraftDroplets.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Other Droplets (${nonMinecraftDroplets.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => DropletCard(
                      droplet: nonMinecraftDroplets[index],
                    ),
                    childCount: nonMinecraftDroplets.length,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
