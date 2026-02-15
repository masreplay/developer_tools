import 'package:developer_tools_core/developer_tools_core.dart';

/// Internal log entry for the console (Flutter errors, etc.).
class ConsoleLogEntry {
  const ConsoleLogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    this.stackTrace,
    this.details,
  });

  final DateTime timestamp;
  final String message;
  final DeveloperToolsLogLevel level;
  final StackTrace? stackTrace;
  final String? details;

  DeveloperToolsLogEntry toUnified(String sourceId) {
    return DeveloperToolsLogEntry(
      timestamp: timestamp,
      message: message,
      sourceId: sourceId,
      level: level,
      details: details ?? stackTrace?.toString(),
    );
  }
}
