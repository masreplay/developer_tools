library;

import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

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
  }) {
    return (BuildContext context, Widget? child) {
      return DeveloperTools(
        entries: entries,
        extensions: extensions,
        enabled: enabled,
        initiallyVisible: initiallyVisible,
        buttonAlignment: buttonAlignment,
        navigatorKey: navigatorKey,
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

class _OverlayPanel extends StatelessWidget {
  const _OverlayPanel({
    required this.entries,
    required this.extensions,
    required this.onClose,
    this.navigatorKey,
    this.activeQuickAction,
  });

  final List<DeveloperToolEntry> entries;
  final List<DeveloperToolsExtension> extensions;
  final VoidCallback onClose;
  final GlobalKey<NavigatorState>? navigatorKey;
  final _QuickActionRegistration? activeQuickAction;

  List<DeveloperToolEntry> _allEntries(BuildContext context) {
    final result = <DeveloperToolEntry>[...entries];
    for (final extension in extensions) {
      result.addAll(extension.buildEntries(context));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = _allEntries(context);
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _OverlayHeader(onClose: onClose),
                    const Divider(height: 1),
                    if (activeQuickAction != null)
                      _QuickActionTile(
                        action: activeQuickAction!,
                        onClose: onClose,
                      ),
                    if (activeQuickAction != null) const Divider(height: 1),
                    Expanded(
                      child:
                          allEntries.isEmpty
                              ? const _EmptyOverlayBody()
                              : ListView(
                                children: _buildOverlayEntries(
                                  context,
                                  allEntries,
                                  onClose,
                                  navigatorKey,
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
}
