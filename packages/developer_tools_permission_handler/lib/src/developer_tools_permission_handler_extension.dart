import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'open_app_settings_tool_entry.dart';
import 'permission_report.dart';
import 'permission_status_overview_tool_entry.dart';
import 'request_permission_tool_entry.dart';

/// Permission Handler integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsPermissionHandler()],
///   ),
/// );
/// ```
class DeveloperToolsPermissionHandler extends DeveloperToolsExtension {
  /// Creates a Permission Handler developer tools extension.
  const DeveloperToolsPermissionHandler({
    super.key,
    super.packageName = 'permission_handler',
    super.displayName = 'Permission Handler',
  });

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      permissionStatusOverviewToolEntry(sectionLabel: sectionLabel),
      openAppSettingsToolEntry(sectionLabel: sectionLabel),
      requestPermissionToolEntry(sectionLabel: sectionLabel),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    try {
      return await buildPermissionReport();
    } catch (e) {
      return 'Error reading permission status: $e';
    }
  }
}
