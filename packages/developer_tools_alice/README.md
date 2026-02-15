# developer_tools_alice

Alice HTTP Inspector integration for [developer_tools](https://pub.dev/packages/developer_tools). Open the HTTP inspector and view status from the debug overlay.

## Features

- **Open HTTP Inspector** – One tap to open Alice's fullscreen inspector and view captured HTTP requests and responses.
- **Inspector Status Overview** – See whether the inspector is open and if a navigator key is set; copy status to clipboard.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.1
  developer_tools_alice:
  alice: ^1.0.0
```

## Usage

Pass your [Alice](https://pub.dev/packages/alice) instance so the tools can open the inspector and report status:

```dart
final alice = Alice(
  configuration: AliceConfiguration(
    navigatorKey: navigatorKey,
  ),
);

MaterialApp(
  builder: DeveloperTools.builder(
    extensions: [DeveloperToolsAlice(instance: alice)],
  ),
);
```

If you omit `instance`, the overlay entries will show a message asking you to pass it.

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
- [alice](https://pub.dev/packages/alice) – HTTP Inspector
