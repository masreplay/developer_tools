# developer_tools_device_info

Device Info Plus integration for [developer_tools](https://pub.dev/packages/developer_tools). View detailed device information, hardware specs, and copy device info for bug reports from the debug overlay.

## Features

- **Device Overview** – View all device information organized by category (general, OS, hardware, identifiers).
- **Copy Device Info** – Copy all device info to clipboard as formatted text for bug reports.
- Platform-adaptive display: shows relevant info for Android, iOS, macOS, Linux, Windows, and Web.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.1
  developer_tools_device_info: ^0.0.1
  device_info_plus: ^12.0.0
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsDeviceInfo()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
- [developer_tools_package_info](https://pub.dev/packages/developer_tools_package_info) – Package Info Plus integration
- [developer_tools_shared_preferences](https://pub.dev/packages/developer_tools_shared_preferences) – Shared Preferences integration
