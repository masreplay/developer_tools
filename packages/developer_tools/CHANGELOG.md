## 0.0.5

- Remove redundant tooltip attributes from IconButton widgets.
- Improve code formatting and line breaks for readability.

## 0.0.4

- Add `exportReport()` method to collect and export debug information from all registered extensions and standalone entries.
- Add export debug report button to the overlay header with clipboard support.
- Add `exportDeveloperToolsReport()` convenience method on the `BuildContext` extension.
- Bump `developer_tools_core` to `^0.0.3`.

## 0.0.3

- Add `DeveloperToolsBuildContext` extension on `BuildContext` for convenient access to `DeveloperTools` state and common actions (`showDeveloperTools`, `hideDeveloperTools`, `toggleDeveloperTools`, `registerDeveloperToolQuickAction`).

## 0.0.2

- Add pluggable extensions support to `DeveloperTools` widget for improved customization.
- Add `navigatorKey` support in the `DeveloperTools` widget for improved navigation handling.
- Refactor overlay entry building with a dedicated method for building list entries.
- Remove unused `developer_tools_riverpod` dependency.

## 0.0.1

- Initial release.
