import 'dart:convert';

import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_actions_tool_entry.dart';
import 'preferences_browser_tool_entry.dart';

/// Shared Preferences integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// Optionally accepts a [SharedPreferences] instance to reuse an already-fetched
/// result instead of calling [SharedPreferences.getInstance] internally:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: [
///       DeveloperToolsSharedPreferences(instance: prefs),
///     ],
///   ),
/// );
/// ```
class DeveloperToolsSharedPreferences extends DeveloperToolsExtension {
  /// Creates a Shared Preferences developer tools extension.
  ///
  /// If [instance] is provided, it will be used directly instead of calling
  /// [SharedPreferences.getInstance].
  const DeveloperToolsSharedPreferences({
    this.instance,
    super.key,
    super.packageName = 'shared_preferences',
    super.displayName = 'Shared Preferences',
  });

  /// Optional [SharedPreferences] instance to use instead of fetching one.
  final SharedPreferences? instance;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      preferencesBrowserToolEntry(
        sectionLabel: sectionLabel,
        instance: instance,
      ),
      preferencesActionsToolEntry(
        sectionLabel: sectionLabel,
        instance: instance,
      ),
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    try {
      final prefs = instance ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList()..sort();
      if (keys.isEmpty) return 'No stored preferences.';

      final buffer = StringBuffer();
      buffer.writeln(
        'Total: ${keys.length} preference${keys.length == 1 ? '' : 's'}',
      );

      // Type breakdown
      int stringCount = 0, intCount = 0, doubleCount = 0;
      int boolCount = 0, listCount = 0;
      final map = <String, Object?>{};
      for (final key in keys) {
        final value = prefs.get(key);
        map[key] = value;
        if (value is bool) {
          boolCount++;
        } else if (value is int) {
          intCount++;
        } else if (value is double) {
          doubleCount++;
        } else if (value is List) {
          listCount++;
        } else if (value is String) {
          stringCount++;
        }
      }
      final types = <String>[
        if (stringCount > 0) '$stringCount String',
        if (intCount > 0) '$intCount int',
        if (doubleCount > 0) '$doubleCount double',
        if (boolCount > 0) '$boolCount bool',
        if (listCount > 0) '$listCount List',
      ];
      buffer.writeln('Types: ${types.join(', ')}');
      buffer.writeln();
      buffer.write(const JsonEncoder.withIndent('  ').convert(map));
      return buffer.toString();
    } catch (e) {
      return 'Error reading shared preferences: $e';
    }
  }
}
