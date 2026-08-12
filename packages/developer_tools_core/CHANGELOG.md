## 0.0.5

- Point `repository`, `homepage` and `issue_tracker` at the real
  repository (github.com/masreplay/developer_tools). The previous
  URLs referenced a non-existent org, so every package page on
  pub.dev showed broken links.

## 0.0.4

- Refactor and improve code readability and consistency (log sources, memory log, formatting).

## 0.0.3

- Add `DebugInfoCallback` typedef for debug report contributions.
- Add optional `debugInfo` callback to `DeveloperToolEntry` for per-entry debug information.
- Add `debugInfo` method to `DeveloperToolsExtension` with default implementation that collects info from all entries.

## 0.0.2

- Refactor `DeveloperToolEntry` to extend `StatelessWidget` with a `build` method for rendering `ListTile`.
- Add `sectionLabel` support to group entries in the developer tools UI.
- Add optional `iconWidget` support in `DeveloperToolEntry` for custom icons.
- Remove Flutter version constraints from `pubspec.yaml` for better compatibility.

## 0.0.1

- Initial release.
