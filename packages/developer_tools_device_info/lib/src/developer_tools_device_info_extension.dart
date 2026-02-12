import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';

import 'device_copy_tool_entry.dart';
import 'device_overview_tool_entry.dart';

/// Device Info Plus integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// Optionally accepts a [DeviceInfoPlugin] instance to reuse an existing plugin
/// instead of creating a new one internally:
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: [
///       DeveloperToolsDeviceInfo(instance: DeviceInfoPlugin()),
///     ],
///   ),
/// );
/// ```
class DeveloperToolsDeviceInfo extends DeveloperToolsExtension {
  /// Creates a Device Info Plus developer tools extension.
  ///
  /// If [instance] is provided, it will be used to fetch device info.
  /// Otherwise, a new [DeviceInfoPlugin] instance is created internally.
  const DeveloperToolsDeviceInfo({
    this.instance,
    super.key,
    super.packageName = 'device_info_plus',
    super.displayName = 'Device Info',
  });

  /// Optional [DeviceInfoPlugin] instance to use for fetching device info.
  final DeviceInfoPlugin? instance;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      deviceOverviewToolEntry(sectionLabel: sectionLabel, instance: instance),
      deviceCopyToolEntry(sectionLabel: sectionLabel, instance: instance),
    ];
  }
}
