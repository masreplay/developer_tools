import 'package:alice/alice.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'inspector_status_overview_tool_entry.dart';
import 'open_inspector_tool_entry.dart';

/// Network HTTP Inspector integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// Pass your [Alice] instance (from package:alice) so that "Open HTTP Inspector"
/// and status tools work. If [instance] is null, those entries will show a
/// message asking for it.
///
/// ```dart
/// final alice = Alice(
///   configuration: AliceConfiguration(
///     navigatorKey: navigatorKey,
///   ),
/// );
///
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: [DeveloperToolsNetwork(instance: alice)],
///   ),
/// );
/// ```
class DeveloperToolsNetwork extends DeveloperToolsExtension {
  const DeveloperToolsNetwork({
    this.instance,
    super.key,
    super.packageName = 'network',
    super.displayName = 'Network',
  });

  /// Optional [Alice] instance. When set, open inspector and status entries work.
  final Alice? instance;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      openNetworkInspectorToolEntry(
        sectionLabel: sectionLabel,
        instance: instance,
      ),
      networkInspectorStatusOverviewToolEntry(
        sectionLabel: sectionLabel,
        instance: instance,
      ),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln('## Network');
    try {
      if (instance == null) {
        buffer.writeln('Instance: not provided.');
        return buffer.toString();
      }
      final alice = instance!;
      buffer.writeln('Inspector opened: ${alice.isInspectorOpened}');
      buffer.writeln('Navigator key set: ${alice.getNavigatorKey() != null}');
    } catch (e) {
      buffer.writeln('Error: $e');
    }
    return buffer.toString();
  }
}
