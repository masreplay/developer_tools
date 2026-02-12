import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'device_copy_tool_entry.dart';
import 'device_overview_tool_entry.dart';

/// Device Info Plus integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsDeviceInfo()],
///   ),
/// );
/// ```
class DeveloperToolsDeviceInfo extends DeveloperToolsExtension {
  /// Creates a Device Info Plus developer tools extension.
  const DeveloperToolsDeviceInfo({
    super.key,
    super.packageName = 'device_info_plus',
    super.displayName = 'Device Info',
  });

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      deviceOverviewToolEntry(sectionLabel: sectionLabel),
      deviceCopyToolEntry(sectionLabel: sectionLabel),
    ];
  }
}
