import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Type of lifecycle event captured from Riverpod.
enum RiverpodProviderEventType {
  add,
  update,
  fail,
  dispose,

  /// Mutation‑related events (for `Mutation` API).
  mutationStart,
  mutationSuccess,
  mutationError,
  mutationReset,
}

/// Single log entry for a Riverpod provider lifecycle event.
class RiverpodProviderLogEntry {
  const RiverpodProviderLogEntry({
    required this.type,
    required this.providerName,
    required this.message,
    required this.timestamp,
  });

  /// The type of event that was observed.
  final RiverpodProviderEventType type;

  /// Human‑readable provider name (or runtime type if unnamed).
  final String providerName;

  /// Short textual description of the event/value.
  final String message;

  /// When the event happened.
  final DateTime timestamp;
}

/// Global in‑memory log for Riverpod provider events.
///
/// This is intentionally simple and kept in memory only – it resets when
/// the app restarts. It is exposed so that apps can inspect the log directly
/// in tests if desired.
///
/// Listen to [listenable] to rebuild UI when entries are added or cleared.
class RiverpodProviderLog {
  RiverpodProviderLog._();

  static final RiverpodProviderLog instance = RiverpodProviderLog._();

  final List<RiverpodProviderLogEntry> _entries = <RiverpodProviderLogEntry>[];

  final ValueNotifier<int> _version = ValueNotifier<int>(0);

  bool _hasReceivedEvents = false;

  /// Listenable that notifies when [add] or [clear] is called.
  ///
  /// Use with [ListenableBuilder] or [ValueListenableBuilder] so the UI
  /// updates when new provider events are logged.
  ValueListenable<int> get listenable => _version;

  /// Whether at least one event has been recorded since app start.
  ///
  /// Used to detect if [DeveloperToolsRiverpod.observer()] is attached to
  /// [ProviderScope.observers]. Once true, it stays true until the app
  /// restarts.
  bool get hasReceivedEvents => _hasReceivedEvents;

  /// Read‑only view of all recorded entries.
  List<RiverpodProviderLogEntry> get entries =>
      List<RiverpodProviderLogEntry>.unmodifiable(_entries);

  void add(RiverpodProviderLogEntry entry) {
    _hasReceivedEvents = true;
    _entries.add(entry);
    _version.value++;
  }

  void clear() {
    _entries.clear();
    _version.value++;
  }
}

/// Convenient global accessor for the Riverpod provider log.
final RiverpodProviderLog riverpodProviderLog = RiverpodProviderLog.instance;

/// [ProviderObserver] that records provider lifecycle events into the global log.
///
/// Attach this to your `ProviderScope`/`ProviderContainer`:
///
/// ```dart
/// ProviderScope(
///   observers: const [RiverpodDeveloperToolsProviderObserver()],
///   child: MyApp(),
/// );
/// ```
@internal
final class RiverpodDeveloperToolsProviderObserver extends ProviderObserver {
  const RiverpodDeveloperToolsProviderObserver();

  String _providerName(ProviderObserverContext context) {
    return context.provider.name ?? context.provider.runtimeType.toString();
  }

  void _recordEvent(
    RiverpodProviderEventType type,
    ProviderObserverContext context, {
    String? message,
  }) {
    riverpodProviderLog.add(
      RiverpodProviderLogEntry(
        type: type,
        providerName: _providerName(context),
        message: message ?? '',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    _recordEvent(
      RiverpodProviderEventType.add,
      context,
      message: 'value: $value',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _recordEvent(
      RiverpodProviderEventType.fail,
      context,
      message: 'error: $error',
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _recordEvent(
      RiverpodProviderEventType.update,
      context,
      message: 'new: $newValue, previous: $previousValue',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    _recordEvent(
      RiverpodProviderEventType.dispose,
      context,
      message: 'provider disposed',
    );
  }

  @override
  void mutationError(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
    Object error,
    StackTrace stackTrace,
  ) {
    _recordEvent(
      RiverpodProviderEventType.mutationError,
      context,
      message: 'mutation: $mutation, error: $error',
    );
  }

  @override
  void mutationReset(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
  ) {
    _recordEvent(
      RiverpodProviderEventType.mutationReset,
      context,
      message: 'mutation reset: $mutation',
    );
  }

  @override
  void mutationStart(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
  ) {
    _recordEvent(
      RiverpodProviderEventType.mutationStart,
      context,
      message: 'mutation started: $mutation',
    );
  }

  @override
  void mutationSuccess(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
    Object? result,
  ) {
    _recordEvent(
      RiverpodProviderEventType.mutationSuccess,
      context,
      message: 'mutation: $mutation, result: $result',
    );
  }
}
