import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'preferences_actions_tool_entry.dart';
import 'preferences_browser_tool_entry.dart';

/// Shared Preferences integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsSharedPreferences()],
///   ),
/// );
/// ```
class DeveloperToolsSharedPreferences extends DeveloperToolsExtension {
  /// Creates a Shared Preferences developer tools extension.
  const DeveloperToolsSharedPreferences({
    super.key,
    super.packageName = 'shared_preferences',
    super.displayName = 'Shared Preferences',
  });

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      preferencesBrowserToolEntry(sectionLabel: sectionLabel),
      preferencesActionsToolEntry(sectionLabel: sectionLabel),
    ];
  }
}
