## 0.0.5

- Migrate from `package:flutter/material.dart` to `package:material_ui` (Flutter 3.47 decoupled Material library). Requires Dart 3.13 / Flutter 3.47.
- Require `device_info_plus` ^13.3.0.
- Require `developer_tools_core` ^0.0.6.

## 0.0.4

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

## 0.0.3

- Bump `developer_tools_core` to `^0.0.4` (dependency cascade).

## 0.0.2

- Add `debugInfo` callback to device copy tool entry for including device info in debug reports.
- Bump `developer_tools_core` to `^0.0.3`.

## 0.0.1

- Initial release with device info overview and copy-to-clipboard tool entries.
