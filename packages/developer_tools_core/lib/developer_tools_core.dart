library;

import 'dart:async';

import 'package:flutter/material.dart';

export 'src/log_source.dart';
export 'src/memory_log.dart';

/// Signature for a developer tool action.
///
/// The [BuildContext] is a navigator context when [DeveloperTools] is built
/// with [DeveloperTools.navigatorKey] (or [DeveloperTools.builder]'s
/// [navigatorKey]). Use it to show dialogs and push routes. Without a
/// navigator key, the context is the overlay and cannot be used for dialogs.
typedef DeveloperToolAction = FutureOr<void> Function(BuildContext context);

/// Signature for a callback that returns debug information as a string.
///
/// Used by [DeveloperToolEntry.debugInfo] and
/// [DeveloperToolsExtension.debugInfo] to contribute sections to the
/// aggregated debug report produced by `exportDeveloperToolsReport()`.
///
/// Return `null` to indicate that there is nothing to report.
typedef DebugInfoCallback = Future<String?> Function(BuildContext context);

/// Simple model describing a single entry in the developer tools overlay.
class DeveloperToolEntry extends StatelessWidget {
  const DeveloperToolEntry({
    super.key,
    required this.title,
    required this.onTap,
    this.description,
    this.icon,
    this.iconWidget,
    this.sectionLabel,
    this.children = const <DeveloperToolEntry>[],
    this.debugInfo,
  });

  /// Title shown in the overlay list.
  final String title;

  /// Optional longer description shown under the title.
  final String? description;

  /// Optional section header shown above this entry when entries are grouped
  /// (e.g. extension display name like "Riverpod").
  final String? sectionLabel;

  /// Optional icon shown at the start of the list tile.
  final IconData? icon;

  /// Optional widget to show instead of the default icon.
  final Widget? iconWidget;

  /// Action executed when the user taps the entry.
  final DeveloperToolAction onTap;

  /// Optional nested developer tool entries.
  ///
  /// When using the `developer_tools` overlay package, entries in [children]
  /// are rendered as a nested list under this entry (for example inside an
  /// expansion tile). This allows you to create simple hierarchies/groups of
  /// actions instead of a single flat list.
  final List<DeveloperToolEntry> children;

  /// Optional callback that returns debug information for this entry.
  ///
  /// When the user exports a debug report, this callback is invoked and the
  /// returned string (if non-null) is included in the aggregated report.
  ///
  /// ```dart
  /// DeveloperToolEntry(
  ///   title: 'Auth State',
  ///   onTap: (_) {},
  ///   debugInfo: (_) async => 'Logged in as: ${user.email}',
  /// )
  /// ```
  final DebugInfoCallback? debugInfo;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: iconWidget ?? (icon != null ? Icon(icon) : const Icon(Icons.bolt)),
    title: Text(title),
    subtitle: description != null ? Text(description!) : null,
    onTap: () async {
      await onTap(context);
    },
  );
}

/// Base class for pluggable developer tools extensions.
///
/// Packages like `developer_tools_riverpod` or `developer_tools_get` can
/// subclass this and provide extra overlay entries that are merged into the
/// main `DeveloperTools` overlay.
///
/// The widget itself is never inserted into the tree – its [build] method
/// returns an empty box by default – but being a widget allows extensions to
/// use `BuildContext` and other Flutter APIs naturally.
abstract class DeveloperToolsExtension extends StatelessWidget {
  const DeveloperToolsExtension({
    super.key,
    this.packageName,
    this.displayName,
  });

  /// The name of the package that this extension is for.
  final String? packageName;

  /// Optional display name for this extension in the developer tools UI.
  final String? displayName;

  /// Returns the list of entries contributed by this extension.
  List<DeveloperToolEntry> buildEntries(BuildContext context);

  /// Returns debug information for this extension.
  ///
  /// The default implementation collects [DeveloperToolEntry.debugInfo] from
  /// every entry returned by [buildEntries] and joins them with newlines.
  /// Override this to provide a custom report or to add extension-level
  /// diagnostics that do not belong to a single entry.
  ///
  /// Return `null` to indicate that there is nothing to report.
  Future<String?> debugInfo(BuildContext context) async {
    final entries = buildEntries(context);
    final sections = <String>[];
    for (final entry in entries) {
      if (entry.debugInfo != null) {
        final info = await entry.debugInfo!(context);
        if (info != null && info.isNotEmpty) {
          sections.add(info);
        }
      }
    }
    return sections.isEmpty ? null : sections.join('\n');
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
