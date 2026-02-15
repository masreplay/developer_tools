import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/foundation.dart';

import 'developer_tools_riverpod_base.dart';

/// [DeveloperToolsLogSource] implementation for Riverpod provider events.
class RiverpodLogSource extends DeveloperToolsLogSource {
  const RiverpodLogSource();

  @override
  String get id => 'riverpod';

  @override
  String get displayName => 'Riverpod';

  @override
  bool get hasReceivedEvents => riverpodProviderLog.hasReceivedEvents;

  @override
  List<DeveloperToolsLogEntry> get entries => riverpodProviderLog.entries
      .map((e) => DeveloperToolsLogEntry(
            timestamp: e.timestamp,
            message: '[${e.type.name.toUpperCase()}] ${e.providerName}: ${e.message}',
            sourceId: id,
            level: e.type == RiverpodProviderEventType.fail ||
                    e.type == RiverpodProviderEventType.mutationError
                ? DeveloperToolsLogLevel.error
                : DeveloperToolsLogLevel.info,
          ))
      .toList();

  @override
  Listenable get listenable => riverpodProviderLog.listenable;
}
