import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/droplet_config_provider.dart';
import '../providers/auth_provider.dart';
import '../services/ios_secure_api_key_service.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/digitalocean_api_service.dart';
import '../services/minecraft_versions_service.dart';
import '../utils/unit_formatter.dart';

class AddDropletPage extends StatefulWidget {
  const AddDropletPage({super.key});

  @override
  State<AddDropletPage> createState() => _AddDropletPageState();
}

class _AddDropletPageState extends State<AddDropletPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Selection state
  Region? _selectedRegion;
  String? _selectedCpuType; // 'basic' or 'dedicated'
  String? _selectedDedicatedCategory; // for dedicated CPU
  DropletSize? _selectedDropletSize;
  MinecraftVersion? _selectedMinecraftVersion;
  String? _selectedWorldSavePath;

  // UI state
  bool _isLoadingData = true;
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
      await configProvider.loadConfigurationData(apiKey);

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
        _selectedRegion = configProvider.availableRegions.isNotEmpty
            ? configProvider.availableRegions.first
            : null;
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
      _selectedCpuType = null;
      _selectedDedicatedCategory = null;
      _selectedDropletSize = null;
    });
  }

  void _onCpuTypeChanged(String? cpuType) {
    setState(() {
      _selectedCpuType = cpuType;
      // Clear dependent selections when CPU type changes
      _selectedDedicatedCategory = null;
      _selectedDropletSize = null;
    });
  }

  void _onDedicatedCategoryChanged(String? category) {
    setState(() {
      _selectedDedicatedCategory = category;
      // Clear droplet size selection when category changes
      _selectedDropletSize = null;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRegion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a region')),
        );
        return;
      }

      if (_selectedCpuType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a CPU type')),
        );
        return;
      }

      if (_selectedCpuType == 'dedicated' &&
          _selectedDedicatedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a dedicated CPU category')),
        );
        return;
      }

      if (_selectedDropletSize == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a droplet size')),
        );
        return;
      }

      if (_selectedMinecraftVersion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Minecraft version')),
        );
        return;
      }

      // TODO: Implement actual droplet creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Droplet configuration saved! (Creation not implemented yet)'),
        ),
      );
      Navigator.of(context).pop();
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
                            _DropletNameField(controller: _nameController),
                            const SizedBox(height: 16),

                            // Location selection (first)
                            _LocationDropdown(
                              selectedRegion: _selectedRegion,
                              regions: configProvider.availableRegions,
                              onChanged: _onRegionChanged,
                            ),
                            const SizedBox(height: 16),

                            // CPU Type selection
                            _CpuTypeDropdown(
                              selectedType: _selectedCpuType,
                              onChanged: _onCpuTypeChanged,
                              isEnabled: _selectedRegion != null,
                            ),
                            const SizedBox(height: 16),

                            // Dedicated CPU category (only if dedicated is selected)
                            if (_selectedCpuType == 'dedicated') ...[
                              _DedicatedCategoryDropdown(
                                selectedCategory: _selectedDedicatedCategory,
                                categories:
                                    configProvider.dedicatedCpuCategories,
                                onChanged: _onDedicatedCategoryChanged,
                                isEnabled: _selectedRegion != null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Droplet size selection
                            _DropletSizeDropdown(
                              selectedSize: _selectedDropletSize,
                              configProvider: configProvider,
                              selectedRegion: _selectedRegion,
                              selectedCpuType: _selectedCpuType,
                              selectedDedicatedCategory:
                                  _selectedDedicatedCategory,
                              onChanged: (size) =>
                                  setState(() => _selectedDropletSize = size),
                            ),
                            const SizedBox(height: 16),

                            // Minecraft version
                            _MinecraftVersionDropdown(
                              selectedVersion: _selectedMinecraftVersion,
                              versions: configProvider.releaseVersions,
                              onChanged: (version) => setState(
                                  () => _selectedMinecraftVersion = version),
                            ),
                            const SizedBox(height: 16),

                            // World save upload
                            _WorldSaveUpload(
                              selectedPath: _selectedWorldSavePath,
                              onPickFile: _pickWorldSave,
                              onRemoveFile: _removeWorldSave,
                            ),
                            const SizedBox(height: 32),

                            // Submit button
                            _SubmitButton(onPressed: _submitForm),
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

  const _DropletNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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

class _LocationDropdown extends StatelessWidget {
  final Region? selectedRegion;
  final List<Region> regions;
  final ValueChanged<Region?> onChanged;

  const _LocationDropdown({
    required this.selectedRegion,
    required this.regions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Region>(
      initialValue: selectedRegion,
      decoration: const InputDecoration(
        labelText: 'Location',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      items: regions.map((region) {
        return DropdownMenuItem<Region>(
          value: region,
          child: Text('${region.name} (${region.slug.toUpperCase()})'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _CpuTypeDropdown extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onChanged;
  final bool isEnabled;

  const _CpuTypeDropdown({
    required this.selectedType,
    required this.onChanged,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedType,
      decoration: const InputDecoration(
        labelText: 'CPU Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.memory),
      ),
      items: const [
        DropdownMenuItem(value: 'basic', child: Text('Basic (Shared CPU)')),
        DropdownMenuItem(value: 'dedicated', child: Text('Dedicated CPU')),
      ],
      onChanged: isEnabled ? onChanged : null,
    );
  }
}

class _DedicatedCategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onChanged;
  final bool isEnabled;

  const _DedicatedCategoryDropdown({
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
    required this.isEnabled,
  });

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'general_purpose':
        return 'General Purpose';
      case 'cpu_optimized':
        return 'CPU Optimized';
      case 'memory_optimized':
        return 'Memory Optimized';
      case 'storage_optimized':
        return 'Storage Optimized';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Dedicated CPU Category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tune),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(_getCategoryDisplayName(category)),
        );
      }).toList(),
      onChanged: isEnabled ? onChanged : null,
    );
  }
}

class _DropletSizeDropdown extends StatelessWidget {
  final DropletSize? selectedSize;
  final DropletConfigProvider configProvider;
  final Region? selectedRegion;
  final String? selectedCpuType;
  final String? selectedDedicatedCategory;
  final ValueChanged<DropletSize?> onChanged;

  const _DropletSizeDropdown({
    required this.selectedSize,
    required this.configProvider,
    required this.selectedRegion,
    required this.selectedCpuType,
    required this.selectedDedicatedCategory,
    required this.onChanged,
  });

  List<DropletSize> _getAvailableSizes() {
    if (selectedRegion == null || selectedCpuType == null) return [];

    if (selectedCpuType == 'basic') {
      return configProvider.getSharedCpuSizesForRegion(selectedRegion!.slug);
    } else if (selectedCpuType == 'dedicated') {
      return configProvider.getDedicatedCpuSizesForRegion(
          selectedRegion!.slug, selectedDedicatedCategory);
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final availableSizes = _getAvailableSizes();
    final isEnabled = selectedRegion != null &&
        selectedCpuType != null &&
        (selectedCpuType != 'dedicated' || selectedDedicatedCategory != null);

    if (!isEnabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Droplet Size',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.memory,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select location and CPU type first',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (availableSizes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Droplet Size',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'No sizes available for the selected configuration',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Droplet Size',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              child: Column(
                children: availableSizes.asMap().entries.expand((entry) {
                  final index = entry.key;
                  final size = entry.value;
                  final isSelected = selectedSize?.slug == size.slug;
                  final isLast = index == availableSizes.length - 1;

                  return [
                    _DropletSizeCard(
                      size: size,
                      isSelected: isSelected,
                      isLast: isLast,
                      onTap: () => onChanged(size),
                    ),
                    if (!isLast)
                      Divider(
                        height: 8,
                        thickness: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                        indent: 16,
                        endIndent: 16,
                      ),
                  ];
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropletSizeCard extends StatelessWidget {
  final DropletSize size;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  const _DropletSizeCard({
    required this.size,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          border: null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    size.slug,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _SpecChip(
                  icon: Icons.memory,
                  label: 'RAM',
                  value: UnitFormatter.formatMemory(size.memory),
                  isSelected: isSelected,
                ),
                _SpecChip(
                  icon: Icons.speed,
                  label: 'vCPUs',
                  value: UnitFormatter.formatCpuCount(size.vcpus),
                  isSelected: isSelected,
                ),
                _SpecChip(
                  icon: Icons.storage,
                  label: 'Storage',
                  value: '${UnitFormatter.formatStorage(size.disk)} SSD',
                  isSelected: isSelected,
                ),
                _SpecChip(
                  icon: Icons.cloud_upload,
                  label: 'Transfer',
                  value: UnitFormatter.formatTransfer(size.transfer),
                  isSelected: isSelected,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  UnitFormatter.formatPrice(size.priceMonthly, isMonthly: true),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${UnitFormatter.formatPrice(size.priceHourly, isMonthly: false)})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withValues(alpha: 0.7)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
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

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;

  const _SpecChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
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
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

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

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Configure Droplet',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
