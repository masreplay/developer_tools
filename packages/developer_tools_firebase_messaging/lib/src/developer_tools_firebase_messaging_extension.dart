import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';

import 'fcm_token_tool_entry.dart';
import 'notification_permissions_tool_entry.dart';
import 'topic_subscription_tool_entry.dart';

/// Firebase Messaging integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsFirebaseMessaging()],
///   ),
/// );
/// ```
class DeveloperToolsFirebaseMessaging extends DeveloperToolsExtension {
  /// Creates a Firebase Messaging developer tools extension.
  const DeveloperToolsFirebaseMessaging({
    super.key,
    super.packageName = 'firebase_messaging',
    super.displayName = 'Firebase Messaging',
  });

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      fcmTokenToolEntry(sectionLabel: sectionLabel),
      notificationPermissionsToolEntry(sectionLabel: sectionLabel),
      topicSubscriptionToolEntry(sectionLabel: sectionLabel),
    ];
  }
}
