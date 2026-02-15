import 'package:flutter/foundation.dart';

/// Generic in-memory log for developer tools extensions.
///
/// Extensions (Riverpod, Console, Network, etc.) use this to store log entries
/// that can be displayed in the overlay panel and/or the docked log viewer.
///
/// Listen to [listenable] to rebuild UI when entries are added or cleared.
class DeveloperToolsMemoryLog<T> {
  DeveloperToolsMemoryLog._();

  /// Creates a new in-memory log.
  factory DeveloperToolsMemoryLog() => DeveloperToolsMemoryLog<T>._();

  final List<T> _entries = <T>[];

  final ValueNotifier<int> _version = ValueNotifier<int>(0);

  bool _hasReceivedEvents = false;

  /// Listenable that notifies when [add] or [clear] is called.
  ValueListenable<int> get listenable => _version;

  /// Whether at least one event has been recorded since app start.
  bool get hasReceivedEvents => _hasReceivedEvents;

  /// Read-only view of all recorded entries.
  List<T> get entries => List<T>.unmodifiable(_entries);

  /// Adds an entry to the log.
  void add(T entry) {
    _hasReceivedEvents = true;
    _entries.add(entry);
    _version.value++;
  }

  /// Clears all entries from the log.
  void clear() {
    _entries.clear();
    _version.value++;
  }
}
