## 0.0.6

- Migrate from `package:flutter/material.dart` to `package:material_ui` (Flutter 3.47 decoupled Material library). Requires Dart 3.13 / Flutter 3.47.
- Require `auto_route` ^11.2.0.
- Require `developer_tools_core` ^0.0.6.

## 0.0.5

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

## 0.0.4

- Bump `developer_tools_core` to `^0.0.4` (dependency cascade).

## 0.0.3

- Add `debugInfo` override to report current route, navigation stack, and router state in debug reports.
- Bump `developer_tools_core` to `^0.0.3`.

## 0.0.2

- Add `.pubignore` and README with installation and usage instructions.
- Add Auto Route inspector tool entry for inspecting current routes.
- Add navigation stack tool entry for viewing the navigation stack.
- Add router state tool entry for viewing router state details.

## 0.0.1

- Initial release with Auto Route inspector tool entry.
