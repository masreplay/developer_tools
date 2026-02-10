library developer_tools_core;

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Signature for a developer tool action.
///
/// The [BuildContext] passed in is the context of the overlay itself, so you
/// can use it to show dialogs, navigate, etc.
typedef DeveloperToolAction = FutureOr<void> Function(BuildContext context);

/// Simple model describing a single entry in the developer tools overlay.
class DeveloperToolEntry {
  const DeveloperToolEntry({
    required this.title,
    required this.onTap,
    this.description,
    this.icon,
  });

  /// Title shown in the overlay list.
  final String title;

  /// Optional longer description shown under the title.
  final String? description;

  /// Optional icon shown at the start of the list tile.
  final IconData? icon;

  /// Action executed when the user taps the entry.
  final DeveloperToolAction onTap;
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
  const DeveloperToolsExtension({super.key});

  /// Returns the list of entries contributed by this extension.
  List<DeveloperToolEntry> buildEntries(BuildContext context);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

