import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'package_copy_tool_entry.dart';
import 'package_overview_tool_entry.dart';

/// Package Info Plus integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsPackageInfo()],
///   ),
/// );
/// ```
class DeveloperToolsPackageInfo extends DeveloperToolsExtension {
  /// Creates a Package Info Plus developer tools extension.
  const DeveloperToolsPackageInfo({
    super.key,
    super.packageName = 'package_info_plus',
    super.displayName = 'Package Info',
  });

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      packageOverviewToolEntry(sectionLabel: sectionLabel),
      packageCopyToolEntry(sectionLabel: sectionLabel),
    ];
  }
}
