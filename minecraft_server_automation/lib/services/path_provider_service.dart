import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:minecraft_server_automation/common/interfaces/path_provider_service.dart';

/// Implementation of PathProviderServiceInterface using path_provider plugin
class PathProviderService implements PathProviderServiceInterface {
  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return await path_provider.getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    return await path_provider.getTemporaryDirectory();
  }

  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return await path_provider.getApplicationSupportDirectory();
  }

  @override
  Future<Directory> getLibraryDirectory() async {
    return await path_provider.getLibraryDirectory();
  }
}
