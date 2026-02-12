# developer_tools_package_info

Package Info Plus integration for [developer_tools](https://pub.dev/packages/developer_tools). View app name, version, build number, installer store, and copy package info for bug reports from the debug overlay.

## Features

- **Package Info Overview** – View app name, package name, version, build number, build signature, installer store, and install/update times.
- **Copy Package Info** – Copy all package info to clipboard as formatted text for bug reports.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.1
  developer_tools_package_info: ^0.0.1
  package_info_plus: ^9.0.0
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsPackageInfo()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
- [developer_tools_device_info](https://pub.dev/packages/developer_tools_device_info) – Device Info Plus integration
- [developer_tools_shared_preferences](https://pub.dev/packages/developer_tools_shared_preferences) – Shared Preferences integration
