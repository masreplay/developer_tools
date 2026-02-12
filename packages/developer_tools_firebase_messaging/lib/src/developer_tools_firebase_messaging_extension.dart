import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  @override
  Future<String?> debugInfo(BuildContext context) async {
    final buffer = StringBuffer();
    try {
      final token = await FirebaseMessaging.instance.getToken();
      buffer.writeln('FCM Token: ${token ?? "(unavailable)"}');
    } catch (e) {
      buffer.writeln('FCM Token: error ($e)');
    }
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      buffer.writeln(
        'Authorization: ${_authorizationLabel(settings.authorizationStatus)}',
      );
      buffer.writeln('Alert: ${_settingLabel(settings.alert)}');
      buffer.writeln('Badge: ${_settingLabel(settings.badge)}');
      buffer.writeln('Sound: ${_settingLabel(settings.sound)}');
      buffer.writeln('Lock Screen: ${_settingLabel(settings.lockScreen)}');
      buffer.writeln(
        'Notification Center: ${_settingLabel(settings.notificationCenter)}',
      );
    } catch (e) {
      buffer.writeln('Notification Settings: error ($e)');
    }
    return buffer.toString();
  }

  static String _authorizationLabel(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'Authorized',
      AuthorizationStatus.denied => 'Denied',
      AuthorizationStatus.notDetermined => 'Not Determined',
      AuthorizationStatus.provisional => 'Provisional',
    };
  }

  static String _settingLabel(AppleNotificationSetting setting) {
    return switch (setting) {
      AppleNotificationSetting.enabled => 'Enabled',
      AppleNotificationSetting.disabled => 'Disabled',
      AppleNotificationSetting.notSupported => 'Not Supported',
    };
  }
}
