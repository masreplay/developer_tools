import 'package:flutter/foundation.dart';

/// Severity/level of a log entry for display purposes.
enum DeveloperToolsLogLevel {
  info,
  warning,
  error,
}

/// Unified representation of a log entry for display in the dock or overlay.
///
/// All log sources (Riverpod, Console, Network, etc.) convert their internal
/// entries to this format so the dock can render them consistently.
class DeveloperToolsLogEntry {
  const DeveloperToolsLogEntry({
    required this.timestamp,
    required this.message,
    required this.sourceId,
    this.level = DeveloperToolsLogLevel.info,
    this.details,
    this.iconData,
  });

  final DateTime timestamp;
  final String message;
  final String sourceId;
  final DeveloperToolsLogLevel level;
  final String? details;
  final int? iconData;

  String get timeString =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';
}

/// Position of the docked log panel.
enum DeveloperToolsDockPosition {
  top,
  bottom,
}

/// Configuration for the docked log panel.
class DeveloperToolsDockConfig {
  const DeveloperToolsDockConfig({
    this.position = DeveloperToolsDockPosition.bottom,
    this.enabledLogSourceIds = const [],
    this.maxVisibleEntries = 10,
    this.enabled = false,
  });

  /// Where to show the dock (top or bottom of the app).
  final DeveloperToolsDockPosition position;

  /// IDs of log sources to include in the dock (e.g. 'riverpod', 'console').
  final List<String> enabledLogSourceIds;

  /// Maximum number of entries to show in the dock at once.
  final int maxVisibleEntries;

  /// Whether the dock is enabled.
  final bool enabled;

  DeveloperToolsDockConfig copyWith({
    DeveloperToolsDockPosition? position,
    List<String>? enabledLogSourceIds,
    int? maxVisibleEntries,
    bool? enabled,
  }) {
    return DeveloperToolsDockConfig(
      position: position ?? this.position,
      enabledLogSourceIds: enabledLogSourceIds ?? this.enabledLogSourceIds,
      maxVisibleEntries: maxVisibleEntries ?? this.maxVisibleEntries,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// A source of log entries that can be shown in the dock and overlay.
///
/// Extensions that have logs (Riverpod, Console, etc.) implement this and
/// register with [DeveloperToolsLogSourceRegistry].
abstract class DeveloperToolsLogSource {
  const DeveloperToolsLogSource();

  /// Unique identifier (e.g. 'riverpod', 'console', 'network').
  String get id;

  /// Human-readable display name.
  String get displayName;

  /// Whether this source has received any events.
  bool get hasReceivedEvents;

  /// Read-only list of entries converted to [DeveloperToolsLogEntry].
  List<DeveloperToolsLogEntry> get entries;

  /// Listenable to rebuild when entries change.
  Listenable get listenable;
}

/// Global registry of log sources for the dock.
///
/// Extensions register their sources here so the dock can aggregate and
/// display them.
class DeveloperToolsLogSourceRegistry {
  DeveloperToolsLogSourceRegistry._();

  static final DeveloperToolsLogSourceRegistry instance =
      DeveloperToolsLogSourceRegistry._();

  final List<DeveloperToolsLogSource> _sources = [];

  final ValueNotifier<int> _version = ValueNotifier<int>(0);

  ValueListenable<int> get listenable => _version;

  List<DeveloperToolsLogSource> get sources =>
      List<DeveloperToolsLogSource>.unmodifiable(_sources);

  void register(DeveloperToolsLogSource source) {
    if (!_sources.any((s) => s.id == source.id)) {
      _sources.add(source);
      _version.value++;
    }
  }

  void unregister(String id) {
    _sources.removeWhere((s) => s.id == id);
    _version.value++;
  }

  DeveloperToolsLogSource? get(String id) {
    try {
      return _sources.firstWhere((s) => s.id == id);
    } on StateError {
      return null;
    }
  }
}
