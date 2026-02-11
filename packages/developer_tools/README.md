# developer_tools

A set of runtime tools for developers to use in their Flutter projects. Provides a debug overlay with a floating button and configurable actions.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.1
```

## Usage

Wrap your app with `DeveloperTools.builder()`:

```dart
return MaterialApp(
  builder: DeveloperTools.builder(
    entries: [
      DeveloperToolEntry(
        title: 'Show toast',
        onTap: (context) {
          // run any debug action here
        },
      ),
    ],
  ),
  home: const HomePage(),
);
```

## Related packages

- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
- [developer_tools_riverpod](https://pub.dev/packages/developer_tools_riverpod) – Riverpod integration
- [developer_tools_get](https://pub.dev/packages/developer_tools_get) – GetX integration
