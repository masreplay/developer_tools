import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'developer_tools_riverpod_base.dart';
import 'riverpod_provider_log_tool_entry.dart';

/// Riverpod integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// You must also add [observer] to [ProviderScope.observers]:
///
/// ```dart
/// ProviderScope(
///   observers: [DeveloperToolsRiverpod.observer()],
///   child: MyApp(),
/// );
/// ```
///
/// Use [isObserverInitialized] to check if the observer has received events.
class DeveloperToolsRiverpod extends DeveloperToolsExtension {
  const DeveloperToolsRiverpod({
    super.key,
    super.packageName = 'riverpod',
    super.displayName = 'Riverpod',
    this.enableProviderLog = true,
  });

  /// Whether to listen to the [riverpodProviderLog.listenable] and rebuild the entries when new events are added.
  final bool enableProviderLog;

  static bool _didWarnMissingObserver = false;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    _maybeWarnMissingObserver();
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      if (enableProviderLog)
        riverpodProviderLogToolEntry(context, sectionLabel: sectionLabel),
      // TODO: Add more entries here in the future, each from its own file.
    ];
  }

  static void _maybeWarnMissingObserver() {
    if (_didWarnMissingObserver) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didWarnMissingObserver) return;
      if (!riverpodProviderLog.hasReceivedEvents && kDebugMode) {
        _didWarnMissingObserver = true;
        debugPrint(
          'developer_tools_riverpod: Add observers: '
          '[DeveloperToolsRiverpod.observer()] to ProviderScope.',
        );
      }
    });
  }

  /// Returns the [ProviderObserver] to pass to [ProviderScope.observers].
  static RiverpodDeveloperToolsProviderObserver observer() =>
      RiverpodDeveloperToolsProviderObserver();

  /// Whether the observer has received at least one provider event.
  ///
  /// If `false`, either:
  /// - [observer] was not added to [ProviderScope.observers], or
  /// - No provider events have occurred yet (e.g. app just started).
  ///
  /// Use this to warn users when the Riverpod log may be empty due to a
  /// missing observer configuration.
  static bool get isObserverInitialized =>
      riverpodProviderLog.hasReceivedEvents;
}
