import 'package:alice/alice.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'inspector_status_overview_tool_entry.dart';
import 'open_inspector_tool_entry.dart';

/// Alice HTTP Inspector integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// Pass your [Alice] instance so that "Open HTTP Inspector" and status tools
/// work. If [instance] is null, those entries will show a message asking for it.
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
///     extensions: [DeveloperToolsAlice(instance: alice)],
///   ),
/// );
/// ```
class DeveloperToolsAlice extends DeveloperToolsExtension {
  /// Creates an Alice developer tools extension.
  ///
  /// If [instance] is provided, "Open HTTP Inspector" and "Inspector Status
  /// Overview" will use it. Otherwise they will prompt the user to pass it.
  const DeveloperToolsAlice({
    this.instance,
    super.key,
    super.packageName = 'alice',
    super.displayName = 'Alice',
  });

  /// Optional [Alice] instance. When set, open inspector and status entries work.
  final Alice? instance;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      openInspectorToolEntry(
        sectionLabel: sectionLabel,
        instance: instance,
      ),
      inspectorStatusOverviewToolEntry(
        sectionLabel: sectionLabel,
        instance: instance,
      ),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln('## Alice');
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
