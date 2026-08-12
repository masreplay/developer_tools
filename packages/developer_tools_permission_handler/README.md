# developer_tools_permission_handler

Permission Handler integration for [developer_tools](https://pub.dev/packages/developer_tools). Inspect and exercise runtime permissions from the debug overlay — useful when a bug only reproduces in a particular permission state.

## Features

- **Permission Status Overview** – Every permission and its current status.
- **Request Permission** – Trigger a request and observe the outcome.
- **Open App Settings** – Jump straight to the OS settings page.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.7
  developer_tools_permission_handler: ^0.0.3
  permission_handler: ^12.0.0
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsPermissionHandler()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
