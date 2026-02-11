library;

import 'dart:async';

import 'package:flutter/material.dart';

/// Signature for a developer tool action.
///
/// The [BuildContext] is a navigator context when [DeveloperTools] is built
/// with [DeveloperTools.navigatorKey] (or [DeveloperTools.builder]'s
/// [navigatorKey]). Use it to show dialogs and push routes. Without a
/// navigator key, the context is the overlay and cannot be used for dialogs.
typedef DeveloperToolAction = FutureOr<void> Function(BuildContext context);

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

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
