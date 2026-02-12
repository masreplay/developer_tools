# developer_tools_shared_preferences

Shared Preferences integration for [developer_tools](https://pub.dev/packages/developer_tools). Browse, search, edit, add, delete, and export stored preferences from the debug overlay.

## Features

- **Preferences Browser** – View all stored key-value pairs with type indicators, search, edit, add, and delete.
- **Quick Actions** – Clear all preferences, export as JSON to clipboard, and view preference count.
- Supports all SharedPreferences types: `String`, `int`, `double`, `bool`, and `List<String>`.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.1
  developer_tools_shared_preferences: ^0.0.1
  shared_preferences: ^2.5.0
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsSharedPreferences()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
- [developer_tools_device_info](https://pub.dev/packages/developer_tools_device_info) – Device Info Plus integration
- [developer_tools_package_info](https://pub.dev/packages/developer_tools_package_info) – Package Info Plus integration
