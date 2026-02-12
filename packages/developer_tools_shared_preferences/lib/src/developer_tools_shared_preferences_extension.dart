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
}
