import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/foundation.dart';

import 'console_log.dart';

/// [DeveloperToolsLogSource] implementation for the console.
class ConsoleLogSource extends DeveloperToolsLogSource {
  const ConsoleLogSource();

  @override
  String get id => 'console';

  @override
  String get displayName => 'Console';

  @override
  bool get hasReceivedEvents => ConsoleLog.instance.hasReceivedEvents;

  @override
  List<DeveloperToolsLogEntry> get entries =>
      ConsoleLog.instance.unifiedEntries;

  @override
  Listenable get listenable => ConsoleLog.instance.listenable;
}
