import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/foundation.dart';

import 'console_log_entry.dart';

/// Global in-memory log for Flutter errors and other console events.
class ConsoleLog {
  ConsoleLog._();

  static final ConsoleLog instance = ConsoleLog._();

  final DeveloperToolsMemoryLog<ConsoleLogEntry> _log =
      DeveloperToolsMemoryLog<ConsoleLogEntry>();

  static const String _sourceId = 'console';

  /// The underlying memory log.
  DeveloperToolsMemoryLog<ConsoleLogEntry> get log => _log;

  bool get hasReceivedEvents => _log.hasReceivedEvents;

  List<ConsoleLogEntry> get entries => _log.entries;

  ValueListenable<int> get listenable => _log.listenable;

  void add(ConsoleLogEntry entry) {
    _log.add(entry);
  }

  void clear() {
    _log.clear();
  }

  /// Converts internal entries to unified format for the dock/overlay.
  List<DeveloperToolsLogEntry> get unifiedEntries =>
      _log.entries.map((e) => e.toUnified(_sourceId)).toList();
}

/// Installs global error handlers that log to [ConsoleLog].
///
/// Chains with existing handlers so we don't break error reporting.
/// Call this early in [main] or when the extension is first built.
void installConsoleErrorHandlers() {
  final consoleLog = ConsoleLog.instance;

  // FlutterError.onError – synchronous Flutter framework errors
  final previousFlutterError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    consoleLog.add(
      ConsoleLogEntry(
        timestamp: DateTime.now(),
        message: details.exceptionAsString(),
        level: DeveloperToolsLogLevel.error,
        stackTrace: details.stack,
        details: details.context?.toString(),
      ),
    );
    previousFlutterError?.call(details);
  };

  // PlatformDispatcher.instance.onError – asynchronous errors
  final dispatcher = PlatformDispatcher.instance;
  final previousDispatcherError = dispatcher.onError;
  dispatcher.onError = (Object error, StackTrace stackTrace) {
    consoleLog.add(
      ConsoleLogEntry(
        timestamp: DateTime.now(),
        message: error.toString(),
        level: DeveloperToolsLogLevel.error,
        stackTrace: stackTrace,
        details: 'PlatformDispatcher.onError',
      ),
    );
    if (previousDispatcherError != null) {
      return previousDispatcherError(error, stackTrace);
    }
    return true;
  };
}
