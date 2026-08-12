## 0.0.3

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

## 0.0.2

- Refactor console log and tool entry for readability and consistency.
- Bump `developer_tools_core` to `^0.0.4`.

## 0.0.1

- Initial release.
- Captures FlutterError.onError and PlatformDispatcher.instance.onError.
- Console log tool entry with full-screen dialog to view and clear errors.
- DeveloperToolsLogSource for dock integration.
