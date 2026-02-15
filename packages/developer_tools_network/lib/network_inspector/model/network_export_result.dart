/// Model of export result.
class NetworkExportResult {
  final bool success;
  final NetworkExportResultError? error;
  final String? path;

  NetworkExportResult({required this.success, this.error, this.path});
}

/// Definition of all possible export errors.
enum NetworkExportResultError { logGenerate, empty, permission, file }
