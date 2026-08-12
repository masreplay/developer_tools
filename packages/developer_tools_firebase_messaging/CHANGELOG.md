## 0.0.7

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

## 0.0.6

- Refactor APNS token tool entry for readability and consistency.
- Bump `developer_tools_core` to `^0.0.4`.

## 0.0.5

- Add APNS token viewer tool entry with copy-to-clipboard support (iOS/macOS).
- Add Delete FCM Token tool entry with confirmation dialog.
- Include APNS token in debug info report.

## 0.0.4

- Remove redundant tooltip attribute from topic unsubscribe button.

## 0.0.3

- Add `debugInfo` override to report FCM token and notification permission settings in debug reports.
- Bump `developer_tools_core` to `^0.0.3`.

## 0.0.2 — 2026-02-12

- Bump `firebase_messaging` dependency from `^15.0.0` to `^16.1.1` for improved functionality and compatibility.

## 0.0.1

- Initial release.
- FCM token viewer with copy-to-clipboard support.
- Notification permissions viewer and request dialog.
- Topic subscription management.
