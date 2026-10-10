## 0.0.6

- Migrate from `package:flutter/material.dart` to `package:material_ui` (Flutter 3.47 decoupled Material library). Requires Dart 3.13 / Flutter 3.47.
- Require `riverpod_annotation` ^4.0.7 and `flutter_riverpod` ^3.4.3.
- Require `developer_tools_core` ^0.0.6.

## 0.0.5

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

## 0.0.4

- Refactor Riverpod extension and log source for readability and consistency.
- Bump `developer_tools_core` to `^0.0.4`.

## 0.0.3

- Add `debugInfo` override to report recent provider events and observer status in debug reports.
- Bump `developer_tools_core` to `^0.0.3`.

## 0.0.2

- Improve Riverpod provider log UI with `ListenableBuilder` for real-time updates.
- Implement observer warning for missing configuration.
- Add example app with manual and code-generated Riverpod providers.
- Add `riverpod_lint` plugin support.

## 0.0.1

- Initial release.
