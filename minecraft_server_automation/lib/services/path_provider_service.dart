import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:minecraft_server_automation/common/interfaces/path_provider_service.dart';

/// Implementation of PathProviderServiceInterface using path_provider plugin
class PathProviderService implements PathProviderServiceInterface {
  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

  @override
  Future<Directory> getLibraryDirectory() async {
    return await getLibraryDirectory();
  }
}
