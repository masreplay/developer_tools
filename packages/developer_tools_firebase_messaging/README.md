# developer_tools_firebase_messaging

Firebase Messaging integration for [developer_tools](https://pub.dev/packages/developer_tools). View FCM tokens, manage notification permissions, and subscribe to topics from the debug overlay.

## Features

- **FCM Token** – View, copy, refresh, or delete the device FCM token.
- **Notification Permissions** – View current authorization status and per-setting details; request permissions at runtime.
- **Topic Subscriptions** – Subscribe and unsubscribe from FCM topics with a simple UI, with action history.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.1
  developer_tools_firebase_messaging: ^0.0.1
  firebase_messaging: ^15.0.0
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsFirebaseMessaging()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
- [developer_tools_device_info](https://pub.dev/packages/developer_tools_device_info) – Device Info Plus integration
- [developer_tools_package_info](https://pub.dev/packages/developer_tools_package_info) – Package Info Plus integration
- [developer_tools_shared_preferences](https://pub.dev/packages/developer_tools_shared_preferences) – Shared Preferences integration
