library developer_tools;

import 'dart:async';

import 'package:flutter/material.dart';

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

/// Inherited widget that exposes the internal state of [DeveloperTools].
class _DeveloperToolsScope extends InheritedWidget {
  const _DeveloperToolsScope({
    required this.state,
    required super.child,
  });

  final _DeveloperToolsState state;

  @override
  bool updateShouldNotify(covariant _DeveloperToolsScope oldWidget) {
    return state != oldWidget.state;
  }
}

/// Top‑level widget that adds a simple developer tools overlay to your app.
///
/// The overlay behaves similarly to packages like `flutter_debug_overlay`,
/// but with a much smaller feature set: it simply shows a floating debug
/// button that opens a panel with a list of actions you provide.
///
/// Typical usage from your root `MaterialApp`/`GetMaterialApp`:
///
/// ```dart
/// return MaterialApp(
///   builder: DeveloperTools.builder(
///     entries: [
///       DeveloperToolEntry(
///         title: 'Show toast',
///         onTap: (context) {
///           // run any debug action here
///         },
///       ),
///     ],
///   ),
///   home: const HomePage(),
/// );
/// ```
class DeveloperTools extends StatefulWidget {
  const DeveloperTools({
    super.key,
    required this.child,
    this.entries = const <DeveloperToolEntry>[],
    this.enabled = true,
    this.initiallyVisible = false,
    this.buttonAlignment = Alignment.bottomRight,
  });

  /// Child subtree that the overlay will be drawn on top of.
  final Widget child;

  /// Static list of developer tool entries.
  ///
  /// For many use cases this is enough – you can create the list once in your
  /// app root. If you need something more dynamic you can also rebuild the
  /// widget with a different list.
  final List<DeveloperToolEntry> entries;

  /// Globally enables or disables the overlay.
  ///
  /// When `false`, the overlay is not rendered at all and has no impact on
  /// hit‑testing.
  final bool enabled;

  /// Whether the overlay panel should be visible when the widget is first
  /// built.
  final bool initiallyVisible;

  /// Where to place the small floating debug button.
  final Alignment buttonAlignment;

  /// Convenience builder you can plug directly into `MaterialApp.builder`
  /// or `GetMaterialApp.builder`, similar to `flutter_debug_overlay`.
  ///
  /// ```dart
  /// return MaterialApp(
  ///   builder: DeveloperTools.builder(entries: myEntries),
  ///   home: const HomePage(),
  /// );
  /// ```
  static TransitionBuilder builder({
    List<DeveloperToolEntry> entries = const <DeveloperToolEntry>[],
    bool enabled = true,
    bool initiallyVisible = false,
    Alignment buttonAlignment = Alignment.bottomRight, required List<dynamic> extensions,
  }) {
    return (BuildContext context, Widget? child) {
      return DeveloperTools(
        entries: entries,
        enabled: enabled,
        initiallyVisible: initiallyVisible,
        buttonAlignment: buttonAlignment,
        child: child ?? const SizedBox.shrink(),
      );
    };
  }

  /// Retrieves the internal state from the nearest [DeveloperTools] above
  /// in the tree.
  ///
  /// This can be used to programmatically show/hide the overlay:
  ///
  /// ```dart
  /// DeveloperTools.of(context).toggle();
  /// ```
  static _DeveloperToolsState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_DeveloperToolsScope>();
    assert(scope != null, 'No DeveloperTools found in context');
    return scope!.state;
  }

  @override
  State<DeveloperTools> createState() => _DeveloperToolsState();
}

class _DeveloperToolsState extends State<DeveloperTools> {
  late bool _visible = widget.initiallyVisible;

  void show() {
    if (!_visible) {
      setState(() => _visible = true);
    }
  }

  void hide() {
    if (_visible) {
      setState(() => _visible = false);
    }
  }

  void toggle() {
    setState(() => _visible = !_visible);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return _DeveloperToolsScope(
      state: this,
      child: Stack(
        children: <Widget>[
          widget.child,
          // Small floating debug button.
          Positioned.fill(
            child: SafeArea(
              child: Align(
                alignment: widget.buttonAlignment,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IgnorePointer(
                    ignoring: false,
                    child: Opacity(
                      opacity: 0.8,
                      child: FloatingActionButton.small(
                        heroTag: const Object(),
                        onPressed: toggle,
                        child: const Icon(Icons.bug_report),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_visible) _OverlayPanel(entries: widget.entries, onClose: hide),
        ],
      ),
    );
  }
}

class _OverlayPanel extends StatelessWidget {
  const _OverlayPanel({
    required this.entries,
    required this.onClose,
  });

  final List<DeveloperToolEntry> entries;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
                maxHeight: 520,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _OverlayHeader(onClose: onClose),
                    const Divider(height: 1),
                    Expanded(
                      child: entries.isEmpty
                          ? const _EmptyOverlayBody()
                          : ListView.builder(
                              itemCount: entries.length,
                              itemBuilder: (BuildContext context, int index) {
                                final entry = entries[index];
                                return ListTile(
                                  leading: entry.icon != null
                                      ? Icon(entry.icon)
                                      : const Icon(Icons.bolt),
                                  title: Text(entry.title),
                                  subtitle: entry.description != null
                                      ? Text(entry.description!)
                                      : null,
                                  onTap: () async {
                                    // Close the panel before running the action.
                                    onClose();
                                    await entry.onTap(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayHeader extends StatelessWidget {
  const _OverlayHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.developer_mode, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Developer tools',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onPrimaryContainer),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _EmptyOverlayBody extends StatelessWidget {
  const _EmptyOverlayBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.info_outline,
                size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            const Text(
              'No developer tools configured.\n'
              'Provide entries via DeveloperTools.builder().',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

