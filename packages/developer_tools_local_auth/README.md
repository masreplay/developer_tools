# developer_tools_local_auth

Local Auth integration for [developer_tools](https://pub.dev/packages/developer_tools). Inspect biometric support and test authentication from the debug overlay, without writing a throwaway screen.

## Features

- **Auth Overview** – Whether the device supports biometrics and what is enrolled.
- **Available Biometrics** – The specific biometric types the OS reports.
- **Test Authentication** – Trigger a real prompt and see the result.
- **Copy Auth Status** – Copy the full status to the clipboard for a bug report.

## Installation

```yaml
dependencies:
  developer_tools: ^0.0.7
  developer_tools_local_auth: ^0.0.3
  local_auth: ^3.0.0
```

## Usage

```dart
MaterialApp(
  builder: DeveloperTools.builder(
    extensions: const [DeveloperToolsLocalAuth()],
  ),
);
```

## Related packages

- [developer_tools](https://pub.dev/packages/developer_tools) – Main Flutter overlay
- [developer_tools_core](https://pub.dev/packages/developer_tools_core) – Core abstractions
