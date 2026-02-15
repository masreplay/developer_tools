import 'package:permission_handler/permission_handler.dart';

/// Builds a plain-text report of all requestable permission statuses (and
/// service status where applicable). Used for debug export and copy-to-clipboard.
Future<String> buildPermissionReport() async {
  final buffer = StringBuffer();
  buffer.writeln('Permission status report');
  buffer.writeln('---');
  try {
    final permissions = Permission.values.where((p) => p != Permission.unknown);
    for (final permission in permissions) {
      final status = await permission.status;
      buffer.write('${permission.toString().split('.').last}: ${status.name}');
      if (permission is PermissionWithService) {
        final serviceStatus = await permission.serviceStatus;
        buffer.write(' (service: ${serviceStatus.name})');
      }
      buffer.writeln();
    }
  } catch (e) {
    buffer.writeln('Error: $e');
  }
  return buffer.toString();
}
