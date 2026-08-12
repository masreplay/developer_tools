# developer_tools_console

Console/global error logging integration for [developer_tools](https://pub.dev/packages/developer_tools). Captures `FlutterError`, `WidgetsBinding` and `PlatformDispatcher` errors and surfaces them in the debug overlay, so an exception thrown on a tester's device is readable without a cable.

## Features

- **Console log** – Browse captured errors and stack traces from inside the app.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.7
  developer_tools_console: ^0.0.3
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsConsole()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
