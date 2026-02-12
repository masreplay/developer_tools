import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package_copy_tool_entry.dart';
import 'package_overview_tool_entry.dart';

/// Package Info Plus integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// Optionally accepts a [PackageInfo] instance to reuse an already-fetched
/// result instead of calling [PackageInfo.fromPlatform] internally:
///
/// ```dart
/// final packageInfo = await PackageInfo.fromPlatform();
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: [
///       DeveloperToolsPackageInfo(instance: packageInfo),
///     ],
///   ),
/// );
/// ```
class DeveloperToolsPackageInfo extends DeveloperToolsExtension {
  /// Creates a Package Info Plus developer tools extension.
  ///
  /// If [instance] is provided, it will be used directly instead of calling
  /// [PackageInfo.fromPlatform].
  const DeveloperToolsPackageInfo({
    this.instance,
    super.key,
    super.packageName = 'package_info_plus',
    super.displayName = 'Package Info',
  });

  /// Optional [PackageInfo] instance to use instead of fetching from platform.
  final PackageInfo? instance;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      packageOverviewToolEntry(sectionLabel: sectionLabel, instance: instance),
      packageCopyToolEntry(sectionLabel: sectionLabel, instance: instance),
    ];
  }
}
