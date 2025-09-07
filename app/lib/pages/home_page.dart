import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/droplets_provider.dart';
import '../widgets/api_key_management_banner.dart';
import '../widgets/droplets_list.dart';
import 'add_droplet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load droplets when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DropletsProvider>().loadDroplets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minecraft Server Admin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DropletsProvider>().refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // API Key Management Banner (always visible)
          const ApiKeyManagementBanner(),

          // Main content - droplets list
          const Expanded(
            child: DropletsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddDropletPage(),
            ),
          );
        },
        tooltip: 'Add New Droplet',
        child: const Icon(Icons.add),
      ),
    );
  }
}
