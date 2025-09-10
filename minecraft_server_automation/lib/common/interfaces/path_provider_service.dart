import 'dart:io';

/// Abstract interface for path provider operations
/// This allows for easy mocking in tests
abstract class PathProviderServiceInterface {
  Future<Directory> getApplicationDocumentsDirectory();
  Future<Directory> getTemporaryDirectory();
  Future<Directory> getApplicationSupportDirectory();
  Future<Directory> getLibraryDirectory();
}
