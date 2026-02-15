library;

import 'dart:async';

import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/docked_log_panel.dart';

export 'package:developer_tools_core/developer_tools_core.dart';

/// Inherited widget that exposes the internal state of [DeveloperTools].
class _DeveloperToolsScope extends InheritedWidget {
  const _DeveloperToolsScope({required this.state, required super.child});

  final _DeveloperToolsState state;

  @override
  bool updateShouldNotify(covariant _DeveloperToolsScope oldWidget) {
    return state != oldWidget.state;
  }
}

/// Registration info for a screen‑scoped quick action.
class _QuickActionRegistration {
  const _QuickActionRegistration({
    required this.label,
    required this.onAction,
    this.icon,
  });

  /// Display label shown in the overlay and used for accessibility.
  final String label;

  /// Callback invoked when the quick action is triggered.
  final VoidCallback onAction;

  /// Optional leading icon for the quick action tile.
  final IconData? icon;
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
    this.extensions = const <DeveloperToolsExtension>[],
    this.enabled = true,
    this.initiallyVisible = false,
    this.buttonAlignment = Alignment.bottomRight,
    this.navigatorKey,
    this.dockConfig,
  });

  /// Child subtree that the overlay will be drawn on top of.
  final Widget child;

  /// Optional key for the app's [Navigator].
  ///
  /// When set, entry [DeveloperToolEntry.onTap] callbacks receive this
  /// navigator's [BuildContext], so they can show dialogs and push routes.
  /// Use the same key as [MaterialApp.navigatorKey] (or [ThemeData.navigatorKey]).
  final GlobalKey<NavigatorState>? navigatorKey;

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

  /// Pluggable extensions that contribute additional overlay entries.
  ///
  /// Extensions like [DeveloperToolsRiverpod] implement [DeveloperToolsExtension]
  /// and return entries via [DeveloperToolsExtension.buildEntries].
  final List<DeveloperToolsExtension> extensions;

  /// Optional configuration for the docked log panel.
  ///
  /// When set with [DeveloperToolsDockConfig.enabled] true, a log panel is
  /// shown at the top or bottom of the app with entries from enabled sources
  /// (e.g. riverpod, console).
  final DeveloperToolsDockConfig? dockConfig;

  /// Convenience builder you can plug directly into `MaterialApp.builder`
  /// or `GetMaterialApp.builder`, similar to `flutter_debug_overlay`.
  ///
  /// ```dart
  /// return MaterialApp(
  ///   builder: DeveloperTools.builder(entries: myEntries),
  ///   home: const HomePage(),
  /// );
  /// ```
  ///
  /// If entries need to show dialogs (e.g. [showDialog]), pass [navigatorKey]
  /// and use the same key for [MaterialApp.navigatorKey].
  static TransitionBuilder builder({
    List<DeveloperToolEntry> entries = const <DeveloperToolEntry>[],
    List<DeveloperToolsExtension> extensions =
        const <DeveloperToolsExtension>[],
    bool enabled = true,
    bool initiallyVisible = false,
    Alignment buttonAlignment = Alignment.bottomRight,
    GlobalKey<NavigatorState>? navigatorKey,
    DeveloperToolsDockConfig? dockConfig,
  }) {
    return (BuildContext context, Widget? child) {
      return DeveloperTools(
        entries: entries,
        extensions: extensions,
        enabled: enabled,
        initiallyVisible: initiallyVisible,
        buttonAlignment: buttonAlignment,
        navigatorKey: navigatorKey,
        dockConfig: dockConfig,
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
  // ignore: library_private_types_in_public_api
  static _DeveloperToolsState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_DeveloperToolsScope>();
    assert(scope != null, 'No DeveloperTools found in context');
    return scope!.state;
  }

  /// Like [of], but returns `null` when there is no [DeveloperTools] ancestor
  /// (e.g. when the overlay is disabled).
  // ignore: library_private_types_in_public_api
  static _DeveloperToolsState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_DeveloperToolsScope>()
        ?.state;
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

  // ── Quick‑action support ──────────────────────────────────────────────

  final List<_QuickActionRegistration> _quickActions =
      <_QuickActionRegistration>[];

  _QuickActionRegistration? get _activeQuickAction =>
      _quickActions.isNotEmpty ? _quickActions.last : null;

  bool _quickActionUpdateScheduled = false;

  /// Registers a quick action that can be triggered by **long‑pressing** the
  /// floating debug button or tapping **Run** in the overlay panel.
  ///
  /// Returns a callback that **unregisters** the action – call it in your
  /// widget's [State.dispose] or when the action is no longer relevant.
  ///
  /// Quick actions are stacked: only the most recently registered action is
  /// active. When it is removed the previous one becomes active again, which
  /// makes this work naturally with navigation (each screen pushes its own
  /// action and pops it on dispose).
  ///
  /// ```dart
  /// // Imperative usage (remember to call the returned callback to clean up):
  /// final removeAction = DeveloperTools.of(context).registerQuickAction(
  ///   label: 'Auto‑fill credentials',
  ///   onAction: () {
  ///     usernameCtrl.text = 'test@example.com';
  ///     passwordCtrl.text = 'password123';
  ///   },
  /// );
  /// ```
  ///
  /// For a declarative, widget‑based approach that handles cleanup
  /// automatically, see [DeveloperToolQuickAction].
  VoidCallback registerQuickAction({
    required String label,
    required VoidCallback onAction,
    IconData? icon,
  }) {
    final registration = _QuickActionRegistration(
      label: label,
      onAction: onAction,
      icon: icon,
    );
    _quickActions.add(registration);
    _scheduleQuickActionUpdate();
    return () {
      _quickActions.remove(registration);
      _scheduleQuickActionUpdate();
    };
  }

  // ── Debug report support ─────────────────────────────────────────────

  /// Collects debug information from all registered extensions and standalone
  /// entries and returns it as a single formatted report string.
  ///
  /// Each extension's [DeveloperToolsExtension.debugInfo] and each standalone
  /// entry's [DeveloperToolEntry.debugInfo] is invoked. Non-null results are
  /// joined under section headers.
  Future<String> exportReport() async {
    final buffer = StringBuffer();
    buffer.writeln('Developer Tools – Debug Report');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('${'=' * 50}\n');

    // Extensions
    for (final ext in widget.extensions) {
      final label =
          ext.displayName ?? ext.packageName ?? ext.runtimeType.toString();
      final info = await ext.debugInfo(context);
      if (info != null && info.isNotEmpty) {
        buffer.writeln('── $label ${'─' * (46 - label.length)}');
        buffer.writeln(info);
        buffer.writeln();
      }
    }

    // Standalone entries
    for (final entry in widget.entries) {
      if (entry.debugInfo != null) {
        final info = await entry.debugInfo!(context);
        if (info != null && info.isNotEmpty) {
          buffer.writeln(
            '── ${entry.title} ${'─' * (46 - entry.title.length)}',
          );
          buffer.writeln(info);
          buffer.writeln();
        }
      }
    }

    return buffer.toString();
  }

  void _scheduleQuickActionUpdate() {
    if (_quickActionUpdateScheduled) return;
    _quickActionUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quickActionUpdateScheduled = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final dockConfig = widget.dockConfig;
    final showDock =
        dockConfig != null &&
        dockConfig.enabled &&
        dockConfig.enabledLogSourceIds.isNotEmpty;

    return _DeveloperToolsScope(
      state: this,
      child: Stack(
        children: <Widget>[
          widget.child,
          if (showDock) ...[
            // Ensure extensions register their log sources (run buildEntries)
            Positioned(
              left: -10000,
              child: Builder(
                builder: (BuildContext ctx) {
                  for (final ext in widget.extensions) {
                    ext.buildEntries(ctx);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  dockConfig.position == DeveloperToolsDockPosition.bottom
                      ? 0
                      : null,
              top:
                  dockConfig.position == DeveloperToolsDockPosition.top
                      ? 0
                      : null,
              child: SafeArea(
                top: dockConfig.position != DeveloperToolsDockPosition.top,
                bottom:
                    dockConfig.position != DeveloperToolsDockPosition.bottom,
                child: DockedLogPanel(config: dockConfig),
              ),
            ),
          ],
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
                      child: GestureDetector(
                        onLongPress:
                            _activeQuickAction != null
                                ? () => _activeQuickAction!.onAction()
                                : null,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            FloatingActionButton.small(
                              heroTag: const Object(),
                              onPressed: toggle,
                              child: const Icon(Icons.bug_report),
                            ),
                            if (_activeQuickAction != null)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_visible)
            _OverlayPanel(
              entries: widget.entries,
              extensions: widget.extensions,
              onClose: hide,
              onExportReport: () async {
                final report = await exportReport();
                await Clipboard.setData(ClipboardData(text: report));
                if (mounted) {
                  hide();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debug report copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              navigatorKey: widget.navigatorKey,
              activeQuickAction: _activeQuickAction,
            ),
        ],
      ),
    );
  }
}

List<Widget> _buildOverlayEntries(
  BuildContext context,
  List<DeveloperToolEntry> entries,
  VoidCallback onClose,
  GlobalKey<NavigatorState>? navigatorKey,
) {
  final theme = Theme.of(context);
  final list = <Widget>[];
  String? lastSection;
  for (final entry in entries) {
    if (entry.sectionLabel != null && entry.sectionLabel != lastSection) {
      lastSection = entry.sectionLabel;
      list.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            lastSection!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }
    list.add(
      _buildOverlayEntryTile(
        context: context,
        entry: entry,
        onClose: onClose,
        navigatorKey: navigatorKey,
      ),
    );
  }
  return list;
}

Widget _buildOverlayEntryTile({
  required BuildContext context,
  required DeveloperToolEntry entry,
  required VoidCallback onClose,
  required GlobalKey<NavigatorState>? navigatorKey,
}) {
  final leading =
      entry.iconWidget ??
      (entry.icon != null ? Icon(entry.icon) : const Icon(Icons.bolt));

  if (entry.children.isNotEmpty) {
    return ExpansionTile(
      leading: leading,
      title: Text(entry.title),
      subtitle: entry.description != null ? Text(entry.description!) : null,
      children: _buildOverlayEntries(
        context,
        entry.children,
        onClose,
        navigatorKey,
      ),
    );
  }

  return ListTile(
    leading: leading,
    title: Text(entry.title),
    subtitle: entry.description != null ? Text(entry.description!) : null,
    onTap: () async {
      onClose();
      final navigatorContext = navigatorKey?.currentContext ?? context;
      await entry.onTap(navigatorContext);
    },
  );
}

/// Returns whether [entry] matches [query] (case-insensitive) by title,
/// description, or sectionLabel.
bool _entryMatchesSearch(DeveloperToolEntry entry, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  if (entry.title.toLowerCase().contains(q)) return true;
  if (entry.description != null &&
      entry.description!.toLowerCase().contains(q)) {
    return true;
  }
  if (entry.sectionLabel != null &&
      entry.sectionLabel!.toLowerCase().contains(q)) {
    return true;
  }
  for (final child in entry.children) {
    if (_entryMatchesSearch(child, query)) return true;
  }
  return false;
}

/// Returns whether [extension] or any of its entries match [query].
bool _extensionMatchesSearch(
  DeveloperToolsExtension extension,
  List<DeveloperToolEntry> extensionEntries,
  String query,
) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  final name = extension.displayName ?? extension.packageName ?? '';
  if (name.toLowerCase().contains(q)) return true;
  return extensionEntries.any((e) => _entryMatchesSearch(e, query));
}

class _OverlayPanel extends StatefulWidget {
  const _OverlayPanel({
    required this.entries,
    required this.extensions,
    required this.onClose,
    required this.onExportReport,
    this.navigatorKey,
    this.activeQuickAction,
  });

  final List<DeveloperToolEntry> entries;
  final List<DeveloperToolsExtension> extensions;
  final VoidCallback onClose;
  final Future<void> Function() onExportReport;
  final GlobalKey<NavigatorState>? navigatorKey;
  final _QuickActionRegistration? activeQuickAction;

  @override
  State<_OverlayPanel> createState() => _OverlayPanelState();
}

class _OverlayPanelState extends State<_OverlayPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<DeveloperToolEntry> _sortEntries(List<DeveloperToolEntry> list) {
    final pinned = list.where((e) => e.pinned).toList();
    final unpinned = list.where((e) => !e.pinned).toList();
    return [...pinned, ...unpinned];
  }

  List<DeveloperToolsExtension> _sortExtensions(
    List<DeveloperToolsExtension> list,
  ) {
    final pinned = list.where((e) => e.pinned).toList();
    final unpinned = list.where((e) => !e.pinned).toList();
    return [...pinned, ...unpinned];
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final theme = Theme.of(context);

    // Build extension entries once per extension (sorted by pinned).
    final sortedExtensions = _sortExtensions(widget.extensions);
    final extensionEntriesMap =
        <DeveloperToolsExtension, List<DeveloperToolEntry>>{};
    for (final ext in sortedExtensions) {
      final list = ext.buildEntries(context);
      extensionEntriesMap[ext] = _sortEntries(list);
    }

    final sortedStandalone = _sortEntries([...widget.entries]);

    // When searching: filter and show flat list. Otherwise: show expansion tiles.
    final hasSearch = query.isNotEmpty;

    final List<Widget> bodyChildren = [];
    if (hasSearch) {
      // Flat filtered list: standalone entries + extension entries that match.
      final List<DeveloperToolEntry> flat = [];
      for (final entry in sortedStandalone) {
        if (_entryMatchesSearch(entry, query)) flat.add(entry);
      }
      for (final ext in sortedExtensions) {
        final list = extensionEntriesMap[ext]!;
        if (!_extensionMatchesSearch(ext, list, query)) continue;
        for (final entry in list) {
          if (_entryMatchesSearch(entry, query)) flat.add(entry);
        }
      }
      if (flat.isEmpty) {
        bodyChildren.add(
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No tools match "$query"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      } else {
        bodyChildren.addAll(
          _buildOverlayEntries(
            context,
            flat,
            widget.onClose,
            widget.navigatorKey,
          ),
        );
      }
    } else {
      // Collapsible sections: one ExpansionTile per extension + standalone.
      if (sortedStandalone.isNotEmpty) {
        bodyChildren.add(
          ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(Icons.list, color: theme.colorScheme.primary),
            title: Text(
              'General',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            children: _buildOverlayEntries(
              context,
              sortedStandalone,
              widget.onClose,
              widget.navigatorKey,
            ),
          ),
        );
      }
      for (final ext in sortedExtensions) {
        final list = extensionEntriesMap[ext]!;
        if (list.isEmpty) continue;
        final displayName =
            ext.displayName ?? ext.packageName ?? ext.runtimeType.toString();
        bodyChildren.add(
          ExpansionTile(
            initiallyExpanded: ext.pinned || sortedExtensions.length <= 2,
            leading: Icon(Icons.extension, color: theme.colorScheme.primary),
            title: Text(
              displayName,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            children: _buildOverlayEntries(
              context,
              list,
              widget.onClose,
              widget.navigatorKey,
            ),
          ),
        );
      }
      if (bodyChildren.isEmpty) {
        bodyChildren.add(const _EmptyOverlayBody());
      }
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                color: theme.colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _OverlayHeader(
                      onClose: widget.onClose,
                      onExportReport: widget.onExportReport,
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search tools…',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon:
                              query.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                  : null,
                          isDense: true,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (widget.activeQuickAction != null)
                      _QuickActionTile(
                        action: widget.activeQuickAction!,
                        onClose: widget.onClose,
                      ),
                    if (widget.activeQuickAction != null)
                      const Divider(height: 1),
                    Expanded(
                      child:
                          bodyChildren.isEmpty
                              ? const _EmptyOverlayBody()
                              : ListView(
                                shrinkWrap: true,
                                children: bodyChildren,
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
  const _OverlayHeader({
    required this.onClose,
    required this.onExportReport,
  });

  final VoidCallback onClose;
  final Future<void> Function() onExportReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.developer_mode,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Developer tools',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          _ExportReportButton(onExportReport: onExportReport),
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _ExportReportButton extends StatefulWidget {
  const _ExportReportButton({required this.onExportReport});

  final Future<void> Function() onExportReport;

  @override
  State<_ExportReportButton> createState() => _ExportReportButtonState();
}

class _ExportReportButtonState extends State<_ExportReportButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onExportReport();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon:
          _loading
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
              : Icon(
                Icons.summarize_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
      onPressed: _loading ? null : _handleTap,
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
            Icon(
              Icons.info_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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

// ── Quick‑action overlay tile ───────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.onClose});

  final _QuickActionRegistration action;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        dense: true,
        leading: Icon(
          action.icon ?? Icons.flash_on,
          color: theme.colorScheme.tertiary,
        ),
        title: Text(action.label),
        subtitle: Text(
          'Long‑press the debug button to run',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: FilledButton.tonal(
          onPressed: () {
            onClose();
            action.onAction();
          },
          child: const Text('Run'),
        ),
      ),
    );
  }
}

// ── DeveloperToolQuickAction widget ─────────────────────────────────────

/// Widget that registers a quick action with the nearest [DeveloperTools].
///
/// The action is automatically registered when the widget is inserted into
/// the tree and unregistered when it is removed – no manual cleanup needed.
///
/// This is the **declarative** counterpart of
/// [_DeveloperToolsState.registerQuickAction].
///
/// ```dart
/// // In a login screen:
/// @override
/// Widget build(BuildContext context) {
///   return DeveloperToolQuickAction(
///     label: 'Auto‑fill credentials',
///     onAction: () {
///       usernameCtrl.text = 'test@example.com';
///       passwordCtrl.text = 'password123';
///     },
///     child: Scaffold(...),
///   );
/// }
/// ```
///
/// ```dart
/// // In a profile screen:
/// @override
/// Widget build(BuildContext context) {
///   return DeveloperToolQuickAction(
///     label: 'Logout',
///     icon: Icons.logout,
///     onAction: () => logout(),
///     child: Scaffold(...),
///   );
/// }
/// ```
class DeveloperToolQuickAction extends StatefulWidget {
  const DeveloperToolQuickAction({
    super.key,
    required this.label,
    required this.onAction,
    this.icon,
    required this.child,
  });

  /// Display label for the quick action.
  final String label;

  /// Callback executed when the action is triggered.
  final VoidCallback onAction;

  /// Optional leading icon.
  final IconData? icon;

  /// Child subtree – rendered as‑is.
  final Widget child;

  @override
  State<DeveloperToolQuickAction> createState() =>
      _DeveloperToolQuickActionState();
}

class _DeveloperToolQuickActionState extends State<DeveloperToolQuickAction> {
  VoidCallback? _unregister;

  // Stable callback that always delegates to the *current* widget's onAction.
  void _handleAction() => widget.onAction();

  void _register() {
    _unregister?.call();
    final state = DeveloperTools.maybeOf(context);
    if (state == null) return; // DeveloperTools disabled or absent.
    _unregister = state.registerQuickAction(
      label: widget.label,
      onAction: _handleAction,
      icon: widget.icon,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(DeveloperToolQuickAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re‑register when the metadata that is stored in the registration
    // actually changes. The callback is a stable bound method so closure
    // identity changes in onAction do *not* cause unnecessary churn.
    if (oldWidget.label != widget.label || oldWidget.icon != widget.icon) {
      _register();
    }
  }

  @override
  void dispose() {
    _unregister?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── BuildContext extension ──────────────────────────────────────────────

/// Convenience extension on [BuildContext] for quick access to
/// [DeveloperTools] state and common actions.
///
/// Instead of:
/// ```dart
/// DeveloperTools.of(context).show();
/// ```
///
/// You can write:
/// ```dart
/// context.showDeveloperTools();
/// ```
extension DeveloperToolsBuildContext on BuildContext {
  /// Returns the nearest [DeveloperTools] state, equivalent to
  /// `DeveloperTools.of(context)`.
  ///
  /// Throws if no [DeveloperTools] ancestor is found.
  // ignore: library_private_types_in_public_api
  _DeveloperToolsState get developerTools => DeveloperTools.of(this);

  /// Returns the nearest [DeveloperTools] state, or `null` if none exists.
  ///
  /// Equivalent to `DeveloperTools.maybeOf(context)`.
  // ignore: library_private_types_in_public_api
  _DeveloperToolsState? get maybeDeveloperTools => DeveloperTools.maybeOf(this);

  /// Shows the developer tools overlay panel.
  void showDeveloperTools() => developerTools.show();

  /// Hides the developer tools overlay panel.
  void hideDeveloperTools() => developerTools.hide();

  /// Toggles the developer tools overlay panel visibility.
  void toggleDeveloperTools() => developerTools.toggle();

  /// Registers a quick action with the nearest [DeveloperTools].
  ///
  /// Returns a callback that unregisters the action – call it when the
  /// action is no longer relevant (e.g. in [State.dispose]).
  ///
  /// ```dart
  /// final remove = context.registerDeveloperToolQuickAction(
  ///   label: 'Auto‑fill credentials',
  ///   onAction: () { /* ... */ },
  /// );
  /// ```
  VoidCallback registerDeveloperToolQuickAction({
    required String label,
    required VoidCallback onAction,
    IconData? icon,
  }) {
    return developerTools.registerQuickAction(
      label: label,
      onAction: onAction,
      icon: icon,
    );
  }

  /// Collects debug information from all extensions and entries and returns
  /// it as a single formatted report string.
  ///
  /// ```dart
  /// final report = await context.exportDeveloperToolsReport();
  /// ```
  Future<String> exportDeveloperToolsReport() => developerTools.exportReport();
}
