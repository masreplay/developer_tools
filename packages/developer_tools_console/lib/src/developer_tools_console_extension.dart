import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'console_log.dart';
import 'console_log_source.dart';
import 'console_log_tool_entry.dart';

/// Console integration for `developer_tools`.
///
/// Captures FlutterError.onError and PlatformDispatcher.onError, and provides
/// a tool entry to view the log.
///
/// Add this extension and call [installErrorHandlers] early in main:
///
/// ```dart
/// void main() {
///   DeveloperToolsConsole.installErrorHandlers();
///   runApp(MyApp());
/// }
///
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: [DeveloperToolsConsole()],
///   ),
///   ...
/// );
/// ```
class DeveloperToolsConsole extends DeveloperToolsExtension {
  const DeveloperToolsConsole({
    super.key,
    super.packageName = 'console',
    super.displayName = 'Console',
    this.enableConsoleLog = true,
    this.installErrorHandlersOnBuild = true,
  });

  /// Whether to show the console log tool entry.
  final bool enableConsoleLog;

  /// Whether to install global error handlers when the extension is first built.
  ///
  /// If true, [installErrorHandlers] is called automatically. Set to false
  /// if you prefer to call it manually in main().
  final bool installErrorHandlersOnBuild;

  static bool _handlersInstalled = false;

  /// Installs global error handlers (FlutterError.onError,
  /// PlatformDispatcher.instance.onError) that log to the console.
  ///
  /// Call this early in main(), or set [installErrorHandlersOnBuild] to true.
  static void installErrorHandlers() {
    if (_handlersInstalled) return;
    _handlersInstalled = true;
    installConsoleErrorHandlers();
  }

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    if (installErrorHandlersOnBuild) {
      installErrorHandlers();
    }
    // Register log source for the dock.
    DeveloperToolsLogSourceRegistry.instance.register(const ConsoleLogSource());

    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      if (enableConsoleLog)
        consoleLogToolEntry(context, sectionLabel: sectionLabel),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    final log = ConsoleLog.instance;
    if (!log.hasReceivedEvents) {
      return 'Console: no errors captured yet.';
    }

    final entries = log.entries;
    if (entries.isEmpty) return 'Console: log was cleared.';

    final buffer = StringBuffer();
    buffer.writeln('Total errors: ${entries.length}');
    final recent = entries.reversed.take(10).toList();
    for (final e in recent) {
      buffer.writeln('  [${e.timestamp}] ${e.message}');
    }
    if (entries.length > 10) {
      buffer.writeln('  ... and ${entries.length - 10} more');
    }
    return buffer.toString();
  }
}
