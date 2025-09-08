import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/droplet_config_provider.dart';
import '../providers/auth_provider.dart';
import '../services/ios_secure_api_key_service.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/digitalocean_api_service.dart';
import '../services/minecraft_versions_service.dart';
import '../models/cpu_architecture.dart';
import '../models/cpu_category.dart';
import '../models/cpu_option.dart';
import '../models/storage_multiplier.dart';
import '../models/droplet_creation_request.dart';
import '../widgets/recommended_config_widget.dart';
import '../widgets/custom_config_widget.dart';

class AddDropletPage extends StatefulWidget {
  const AddDropletPage({super.key});

  @override
  State<AddDropletPage> createState() => _AddDropletPageState();
}

class _AddDropletPageState extends State<AddDropletPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Configuration mode
  bool?
      _isRecommendedMode; // null = no selection, true = recommended, false = custom

  // Selection state
  Region? _selectedRegion;
  CpuArchitecture? _selectedCpuArchitecture;
  CpuCategory? _selectedCpuCategory;
  CpuOption? _selectedCpuOption;
  StorageMultiplier? _selectedStorageMultiplier;
  DropletSize? _selectedDropletSize;
  MinecraftVersion? _selectedMinecraftVersion;
  String? _selectedWorldSavePath;

  // UI state
  bool _isLoadingData = true;
  bool _isCreatingDroplet = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfigurationData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigurationData() async {
    try {
      // Get API key
      final authProvider = context.read<AuthProvider>();
      final configProvider = context.read<DropletConfigProvider>();

      final apiKeyService = IOSSecureApiKeyService(
        firestore: authProvider.firestore,
        auth: authProvider.firebaseAuth,
        biometricService: IOSBiometricEncryptionService(),
      );
      final apiKey = await apiKeyService.getApiKey();

      if (apiKey == null) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'No API key found. Please configure your DigitalOcean API key first.';
            _isLoadingData = false;
          });
        }
        return;
      }

      // Load configuration data using the provider
      await configProvider.loadConfigurationData(context);

      if (!mounted) return;

      if (configProvider.error != null) {
        setState(() {
          _errorMessage = configProvider.error;
          _isLoadingData = false;
        });
        return;
      }

      // Set default selections
      setState(() {
        _selectedRegion = null; // No default selection
        _selectedMinecraftVersion = configProvider.releaseVersions.isNotEmpty
            ? configProvider.releaseVersions.first
            : null;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading configuration: $e';
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _pickWorldSave() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedWorldSavePath = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _removeWorldSave() {
    setState(() {
      _selectedWorldSavePath = null;
    });
  }

  void _onRegionChanged(Region? region) {
    setState(() {
      _selectedRegion = region;
      // Clear dependent selections when region changes
      _selectedCpuArchitecture = null;
      _selectedCpuCategory = null;
      _selectedCpuOption = null;
      _selectedStorageMultiplier = null;
      _selectedDropletSize = null;
    });

    // If in recommended mode and region is selected, set up recommended configuration
    if (_isRecommendedMode == true && region != null) {
      _setRecommendedConfiguration();
    }
  }

  void _onCpuArchitectureChanged(CpuArchitecture? architecture) {
    setState(() {
      _selectedCpuArchitecture = architecture;
      // Clear dependent selections when architecture changes
      _selectedCpuCategory = null;
      _selectedCpuOption = null;
      _selectedStorageMultiplier = null;
      _selectedDropletSize = null;
    });
  }

  void _onCpuCategoryChanged(CpuCategory? category) {
    setState(() {
      _selectedCpuCategory = category;
      // Clear dependent selections when category changes
      _selectedCpuOption = null;
      _selectedStorageMultiplier = null;
      _selectedDropletSize = null;
    });
  }

  void _onCpuOptionChanged(CpuOption? option) {
    setState(() {
      _selectedCpuOption = option;
      // Clear dependent selections when option changes
      _selectedStorageMultiplier = null;
      _selectedDropletSize = null;
    });
  }

  void _onStorageMultiplierChanged(StorageMultiplier? multiplier) {
    setState(() {
      _selectedStorageMultiplier = multiplier;
      // Clear droplet size selection when storage changes
      _selectedDropletSize = null;
    });
  }

  void _onConfigurationModeChanged(bool? isRecommended) {
    setState(() {
      _isRecommendedMode = isRecommended;
      if (isRecommended == true) {
        // Clear custom selections when switching to recommended
        _selectedCpuArchitecture = null;
        _selectedCpuCategory = null;
        _selectedCpuOption = null;
        _selectedStorageMultiplier = null;
        _selectedDropletSize = null;
        _selectedRegion = null; // Clear region so it can be auto-detected
      } else if (isRecommended == false) {
        // Clear recommended selections when switching to custom
        _selectedCpuArchitecture = null;
        _selectedCpuCategory = null;
        _selectedCpuOption = null;
        _selectedStorageMultiplier = null;
        _selectedDropletSize = null;
        _selectedRegion = null;
      }
    });
  }

  void _setRecommendedConfiguration() {
    if (_selectedRegion == null) return;

    setState(() {
      // Set recommended configuration: Shared CPU / Basic / Regular
      _selectedCpuArchitecture = CpuArchitecture.shared;
      _selectedCpuCategory = CpuCategory.basic;
      _selectedCpuOption = CpuOption.regular;
      _selectedStorageMultiplier = StorageMultiplier.x1;

      // Find the s-1vcpu-512mb-10gb size
      final configProvider = context.read<DropletConfigProvider>();
      final availableSizes = configProvider.getSizesForStorage(
        _selectedRegion!.slug,
        CpuArchitecture.shared,
        CpuCategory.basic,
        CpuOption.regular,
        StorageMultiplier.x1,
      );

      if (availableSizes.isNotEmpty) {
        _selectedDropletSize = availableSizes.firstWhere(
          (size) => size.slug == 's-1vcpu-512mb-10gb',
          orElse: () => availableSizes.first,
        );
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a region')),
      );
      return;
    }

    if (_isRecommendedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a configuration mode')),
      );
      return;
    }

    if (_isRecommendedMode == true) {
      // For recommended mode, validate that we have the basic required selections
      if (_selectedDropletSize == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please wait for configuration to load')),
        );
        return;
      }
    } else {
      // For custom mode, validate all selections
      if (_selectedCpuArchitecture == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a CPU architecture')),
        );
        return;
      }

      if (_selectedCpuCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a CPU category')),
        );
        return;
      }

      if (_selectedCpuOption == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a CPU option')),
        );
        return;
      }

      if (_selectedStorageMultiplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a storage option')),
        );
        return;
      }

      if (_selectedDropletSize == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a droplet size')),
        );
        return;
      }
    }

    if (_selectedMinecraftVersion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Minecraft version')),
      );
      return;
    }

    // Start droplet creation
    setState(() {
      _isCreatingDroplet = true;
      _errorMessage = null;
    });

    try {
      // Get API key
      final authProvider = context.read<AuthProvider>();
      final apiKeyService = IOSSecureApiKeyService(
        firestore: authProvider.firestore,
        auth: authProvider.firebaseAuth,
        biometricService: IOSBiometricEncryptionService(),
      );
      final apiKey = await apiKeyService.getApiKey();

      if (apiKey == null) {
        throw Exception(
            'No API key found. Please configure your DigitalOcean API key first.');
      }

      // Fetch available images and select latest Ubuntu LTS image
      final images = await DigitalOceanApiService.fetchImages(apiKey);
      final ubuntuImages = images.where((img) =>
        img['distribution'] == 'Ubuntu' &&
        img['slug'] != null &&
        img['slug'].toString().contains('x64')
      ).toList();
      ubuntuImages.sort((a, b) =>
        b['name'].toString().compareTo(a['name'].toString())
      );
      final selectedImageSlug = ubuntuImages.isNotEmpty
          ? ubuntuImages.first['slug'].toString()
          : 'ubuntu-22-04-x64'; // fallback if no images found

      // Create droplet creation request
      final request = DropletCreationRequest.fromFormData(
        name: _nameController.text.trim(),
        region: _selectedRegion!.slug,
        size: _selectedDropletSize!.slug,
        image: selectedImageSlug,
        tags: [
          'minecraft-server',
          'minecraft-${_selectedMinecraftVersion!.id}'
        ],
        userData: await _generateUserData(),
      );

      // Create the droplet
      final droplet =
          await DigitalOceanApiService.createDroplet(apiKey, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Droplet "${droplet['name']}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create droplet: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create droplet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingDroplet = false;
        });
      }
    }
  }

  /// Generates user data script for initial server setup
  Future<String> _generateUserData() async {
    final minecraftVersion = _selectedMinecraftVersion!.id;
    final serverJarUrl = await _getServerJarUrl(minecraftVersion);
    
    // Calculate memory allocation based on droplet RAM
    final totalRamMB = _selectedDropletSize!.memory;
    final osRamMB = _calculateOSRamUsage(totalRamMB);
    final availableRamMB = totalRamMB - osRamMB;
    final jvmRamMB = _calculateJvmRamAllocation(availableRamMB);
    final serverProperties = _generateServerProperties(jvmRamMB);

    return '''
#cloud-config
runcmd:
  - apt-get update
  - apt-get install -y openjdk-17-jdk
  - useradd -m -s /bin/bash minecraft
  - mkdir -p /opt/minecraft
  - chown minecraft:minecraft /opt/minecraft
  - cd /opt/minecraft
  - wget -O server.jar $serverJarUrl
  - echo "eula=true" > eula.txt
  - cat > server.properties << 'EOF'
$serverProperties
EOF
  - chown -R minecraft:minecraft /opt/minecraft
  - systemctl enable minecraft-server
  - systemctl start minecraft-server
  - ufw allow 25565
  - ufw allow 25575
  - ufw --force enable

write_files:
  - path: /etc/systemd/system/minecraft-server.service
    content: |
      [Unit]
      Description=Minecraft Server
      After=network.target

      [Service]
      Type=simple
      User=minecraft
      WorkingDirectory=/opt/minecraft
      ExecStart=/usr/bin/java -Xmx${jvmRamMB}M -Xms${jvmRamMB}M -jar server.jar nogui
      Restart=always
      RestartSec=10

      [Install]
      WantedBy=multi-user.target
    owner: root:root
    permissions: '0644'
''';
  }

  /// Calculates OS RAM usage based on total system RAM
  int _calculateOSRamUsage(int totalRamMB) {
    // Ubuntu 22.04 LTS typically uses:
    // - 512MB: ~200MB for OS
    // - 1GB: ~300MB for OS  
    // - 2GB+: ~400MB for OS
    if (totalRamMB <= 512) {
      return 200; // Conservative for small droplets
    } else if (totalRamMB <= 1024) {
      return 300;
    } else if (totalRamMB <= 2048) {
      return 400;
    } else {
      return 500; // More services running on larger droplets
    }
  }

  /// Calculates appropriate JVM memory allocation
  int _calculateJvmRamAllocation(int availableRamMB) {
    // Reserve some memory for JVM overhead and other processes
    // Use 80% of available RAM, with minimum 256MB and maximum 8GB
    final jvmRam = (availableRamMB * 0.8).round();
    return jvmRam.clamp(256, 8192);
  }

  /// Generates server.properties with appropriate settings for the available RAM
  String _generateServerProperties(int jvmRamMB) {
    // Calculate view distance and simulation distance based on available RAM
    // More RAM = higher distances for better gameplay experience
    int viewDistance;
    int simulationDistance;
    
    if (jvmRamMB < 512) {
      // Very limited RAM - minimal settings
      viewDistance = 6;
      simulationDistance = 4;
    } else if (jvmRamMB < 1024) {
      // Limited RAM - conservative settings
      viewDistance = 8;
      simulationDistance = 6;
    } else if (jvmRamMB < 2048) {
      // Moderate RAM - balanced settings
      viewDistance = 10;
      simulationDistance = 8;
    } else if (jvmRamMB < 4096) {
      // Good RAM - comfortable settings
      viewDistance = 12;
      simulationDistance = 10;
    } else {
      // Plenty of RAM - high settings
      viewDistance = 16;
      simulationDistance = 12;
    }

    return '''# Minecraft server properties
# Generated for ${jvmRamMB}MB JVM allocation

# Server settings
server-port=25565
enable-query=false
enable-rcon=true
rcon.port=25575
rcon.password=minecraft123
enable-command-block=false
gamemode=survival
force-gamemode=false
hardcore=false
difficulty=easy
allow-flight=false
allow-nether=true
enable-command-block=false
spawn-protection=16
max-world-size=29999984

# Performance settings (optimized for ${jvmRamMB}MB RAM)
view-distance=$viewDistance
simulation-distance=$simulationDistance
max-tick-time=60000
max-players=20
network-compression-threshold=256
max-chunk-loads-per-tick=8
max-chunk-sends-per-tick=4

# World settings
level-name=world
level-seed=
level-type=minecraft\:normal
generate-structures=true
generator-settings={}
level-name=world
level-seed=
level-type=minecraft\:normal
generate-structures=true
generator-settings={}

# Player settings
online-mode=true
prevent-proxy-connections=false
pvp=true
player-idle-timeout=0
require-resource-pack=false
resource-pack=
resource-pack-prompt=
resource-pack-sha1=

# Chat settings
enable-status=true
motd=A Minecraft Server
enforce-whitelist=false
white-list=false

# Other settings
function-permission-level=2
op-permission-level=4
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
sync-chunk-writes=true
enable-jmx-monitoring=false
enable-query=false
query.port=25565
''';
  }

  /// Gets the server JAR URL for the specified Minecraft version
  Future<String> _getServerJarUrl(String version) async {
    try {
      // Use the MinecraftVersionsService to fetch the actual download URL from the Minecraft version manifest
      return await MinecraftVersionsService.getServerJarUrlForVersion(version);
    } catch (e) {
      // Fallback to a generic URL if version-specific fetching fails
      // This ensures the droplet creation doesn't fail due to version manifest issues
      return 'https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec60ec15b/server.jar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure New Droplet'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadConfigurationData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Consumer<DropletConfigProvider>(
                  builder: (context, configProvider, child) {
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _DropletNameField(
                              controller: _nameController,
                              enabled: !_isCreatingDroplet,
                            ),
                            const SizedBox(height: 16),

                            // Configuration mode selection
                            _ConfigurationModeSelector(
                              isRecommended: _isRecommendedMode,
                              onChanged: _isCreatingDroplet
                                  ? (_) {}
                                  : _onConfigurationModeChanged,
                            ),
                            const SizedBox(height: 16),

                            // Configuration widgets based on mode
                            if (_isRecommendedMode == null) ...[
                              _ModeSelectionPrompt(),
                            ] else if (_isRecommendedMode == true) ...[
                              RecommendedConfigWidget(
                                selectedRegion: _selectedRegion,
                                availableRegions:
                                    configProvider.availableRegions,
                                onRegionChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : _onRegionChanged,
                                isLoading: _isLoadingData,
                              ),
                            ] else ...[
                              CustomConfigWidget(
                                selectedRegion: _selectedRegion,
                                selectedCpuArchitecture:
                                    _selectedCpuArchitecture,
                                selectedCpuCategory: _selectedCpuCategory,
                                selectedCpuOption: _selectedCpuOption,
                                selectedStorageMultiplier:
                                    _selectedStorageMultiplier,
                                selectedDropletSize: _selectedDropletSize,
                                availableRegions:
                                    configProvider.availableRegions,
                                configProvider: configProvider,
                                onRegionChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : _onRegionChanged,
                                onCpuArchitectureChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : _onCpuArchitectureChanged,
                                onCpuCategoryChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : _onCpuCategoryChanged,
                                onCpuOptionChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : _onCpuOptionChanged,
                                onStorageMultiplierChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : _onStorageMultiplierChanged,
                                onDropletSizeChanged: _isCreatingDroplet
                                    ? (_) {}
                                    : (size) => setState(
                                        () => _selectedDropletSize = size),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Minecraft version (always shown)
                            _MinecraftVersionDropdown(
                              selectedVersion: _selectedMinecraftVersion,
                              versions: configProvider.releaseVersions,
                              onChanged: _isCreatingDroplet
                                  ? (_) {}
                                  : (version) => setState(() =>
                                      _selectedMinecraftVersion = version),
                            ),
                            const SizedBox(height: 16),

                            // World save upload (always shown)
                            _WorldSaveUpload(
                              selectedPath: _selectedWorldSavePath,
                              onPickFile:
                                  _isCreatingDroplet ? null : _pickWorldSave,
                              onRemoveFile:
                                  _isCreatingDroplet ? null : _removeWorldSave,
                            ),
                            const SizedBox(height: 32),

                            // Submit button
                            _SubmitButton(
                              onPressed:
                                  _isCreatingDroplet ? null : _submitForm,
                              isLoading: _isCreatingDroplet,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _DropletNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _DropletNameField({
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Droplet Name',
        hintText: 'Enter a name for your Minecraft server',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.computer),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a droplet name';
        }
        if (value.trim().length < 3) {
          return 'Name must be at least 3 characters long';
        }
        return null;
      },
    );
  }
}

class _MinecraftVersionDropdown extends StatelessWidget {
  final MinecraftVersion? selectedVersion;
  final List<MinecraftVersion> versions;
  final ValueChanged<MinecraftVersion?> onChanged;

  const _MinecraftVersionDropdown({
    required this.selectedVersion,
    required this.versions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MinecraftVersion>(
      initialValue: selectedVersion,
      decoration: const InputDecoration(
        labelText: 'Minecraft Version',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.games),
      ),
      items: versions.map((version) {
        return DropdownMenuItem<MinecraftVersion>(
          value: version,
          child: Text(version.displayName),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _WorldSaveUpload extends StatelessWidget {
  final String? selectedPath;
  final VoidCallback? onPickFile;
  final VoidCallback? onRemoveFile;

  const _WorldSaveUpload({
    required this.selectedPath,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_file),
                const SizedBox(width: 8),
                Text(
                  'Initial World Save (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a .zip file containing your world save to start with an existing world.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            if (selectedPath == null)
              OutlinedButton.icon(
                onPressed: onPickFile,
                icon: const Icon(Icons.upload),
                label: const Text('Choose .zip file'),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedPath!.split('/').last,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onRemoveFile,
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove file',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelectionPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.settings_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Configuration Mode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you want to configure your droplet above to get started.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigurationModeSelector extends StatelessWidget {
  final bool? isRecommended;
  final ValueChanged<bool?> onChanged;

  const _ConfigurationModeSelector({
    required this.isRecommended,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ModeOption(
                    title: 'Recommended',
                    subtitle: 'Optimized for most Minecraft servers',
                    icon: Icons.star,
                    isSelected: isRecommended == true,
                    onTap: () => onChanged(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeOption(
                    title: 'Custom',
                    subtitle: 'Full control over all settings',
                    icon: Icons.tune,
                    isSelected: isRecommended == false,
                    onTap: () => onChanged(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SubmitButton({
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Creating Droplet...'),
              ],
            )
          : const Text(
              'Create Droplet',
              style: TextStyle(fontSize: 16),
            ),
    );
  }
}
