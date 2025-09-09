import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:minecraft_server_automation/providers/droplet_config_provider.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/services/ios_secure_api_key_service.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';
import 'package:minecraft_server_automation/services/digitalocean_api_service.dart';
import 'package:minecraft_server_automation/services/minecraft_versions_service.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_creation_request.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/utils/memory_calculator.dart';
import 'package:minecraft_server_automation/common/widgets/forms/droplet_creation_form.dart';
import 'package:minecraft_server_automation/common/widgets/feedback/error_state_widget.dart';
import 'package:minecraft_server_automation/common/widgets/feedback/loading_state_widget.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

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
      final ubuntuImages = images
          .where((img) =>
              img['distribution'] == 'Ubuntu' &&
              img['slug'] != null &&
              img['slug'].toString().contains('x64'))
          .toList();
      ubuntuImages
          .sort((a, b) => b['name'].toString().compareTo(a['name'].toString()));
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

  /// Generates a random RCON password
  String _generateRconPassword() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes).substring(0, 16);
  }

  /// Generates user data script for initial server setup
  Future<String> _generateUserData() async {
    final minecraftVersion = _selectedMinecraftVersion!.id;
    final serverJarUrl = await _getServerJarUrl(minecraftVersion);

    // Calculate memory allocation based on droplet RAM
    final totalRamMB = _selectedDropletSize!.memory;
    final osRamMB = MemoryCalculator.calculateOSRamUsage(totalRamMB);
    final availableRamMB = totalRamMB - osRamMB;
    final jvmRamMB = MemoryCalculator.calculateJvmRamAllocation(availableRamMB);
    final rconPassword = _generateRconPassword();

    return '''
#cloud-config
runcmd:
  - apt-get update
  - apt-get install -y openjdk-21-jdk
  - useradd -m -s /bin/bash minecraft
  - mkdir -p /opt/minecraft
  - chown minecraft:minecraft /opt/minecraft
  - cd /opt/minecraft
  - wget -O server.jar "$serverJarUrl"
  - echo "eula=true" > eula.txt
  - |
    cat > server.properties << 'EOF'
    # Minecraft server properties
    # Generated for ${jvmRamMB}MB JVM allocation
    
    # Server settings
    server-port=25565
    enable-query=true
    enable-rcon=true
    rcon.port=25575
    rcon.password=$rconPassword
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
    view-distance=${MemoryCalculator.calculateViewDistance(jvmRamMB)}
    simulation-distance=${MemoryCalculator.calculateSimulationDistance(jvmRamMB)}
    max-tick-time=60000
    max-players=20
    network-compression-threshold=256
    max-chunk-loads-per-tick=8
    max-chunk-sends-per-tick=4
    
    # World settings
    level-name=world
    level-seed=
    level-type=minecraft\\:normal
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
    EOF
  - chown -R minecraft:minecraft /opt/minecraft
  - systemctl enable minecraft-server
  - systemctl start minecraft-server
  - ufw allow ssh
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
      ExecStart=java -Xmx${jvmRamMB}M -Xms${jvmRamMB}M -jar server.jar nogui
      Restart=always
      RestartSec=10

      [Install]
      WantedBy=multi-user.target
    owner: root:root
    permissions: '0644'
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
      // TODO: Consider implementing a more robust fallback strategy that fetches
      // the latest stable version or uses a configurable fallback URL
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
          ? const LoadingStateWidget(message: 'Loading configuration...')
          : _errorMessage != null
              ? ErrorStateWidget(
                  message: 'Error loading configuration',
                  details: _errorMessage,
                  onRetry: _loadConfigurationData,
                )
              : Consumer<DropletConfigProvider>(
                  builder: (context, configProvider, child) {
                    return DropletCreationForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      isRecommendedMode: _isRecommendedMode,
                      selectedRegion: _selectedRegion,
                      selectedCpuArchitecture: _selectedCpuArchitecture,
                      selectedCpuCategory: _selectedCpuCategory,
                      selectedCpuOption: _selectedCpuOption,
                      selectedStorageMultiplier: _selectedStorageMultiplier,
                      selectedDropletSize: _selectedDropletSize,
                      selectedMinecraftVersion: _selectedMinecraftVersion,
                      selectedWorldSavePath: _selectedWorldSavePath,
                      availableRegions: configProvider.availableRegions,
                      minecraftVersions: configProvider.releaseVersions,
                      isLoadingData: _isLoadingData,
                      isCreatingDroplet: _isCreatingDroplet,
                      onConfigurationModeChanged: _onConfigurationModeChanged,
                      onRegionChanged: _onRegionChanged,
                      onCpuArchitectureChanged: _onCpuArchitectureChanged,
                      onCpuCategoryChanged: _onCpuCategoryChanged,
                      onCpuOptionChanged: _onCpuOptionChanged,
                      onStorageMultiplierChanged: _onStorageMultiplierChanged,
                      onDropletSizeChanged: (size) =>
                          setState(() => _selectedDropletSize = size),
                      onMinecraftVersionChanged: (version) =>
                          setState(() => _selectedMinecraftVersion = version),
                      onPickWorldSave: _pickWorldSave,
                      onRemoveWorldSave: _removeWorldSave,
                      onSubmit: _submitForm,
                    );
                  },
                ),
    );
  }
}
