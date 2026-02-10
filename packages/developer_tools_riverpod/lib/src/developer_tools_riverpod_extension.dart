import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'riverpod_provider_log_tool_entry.dart';

/// Riverpod integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
class DeveloperToolsRiverpod extends DeveloperToolsExtension {
  const DeveloperToolsRiverpod({super.key});

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    return <DeveloperToolEntry>[
      riverpodProviderLogToolEntry(),
      // TODO: Add more entries here in the future, each from its own file.
    ];
  }
}

