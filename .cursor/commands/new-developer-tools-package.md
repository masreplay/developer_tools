---
description: Create a new developer_tools extension package for a pub.dev package
inputs:
  - id: package
    description: "Package name from pub.dev (e.g. 'connectivity_plus') OR a full pub.dev URL (e.g. 'https://pub.dev/packages/connectivity_plus')"
    required: true
---

# New Developer Tools Package

You are creating a new `developer_tools` extension package that wraps the Flutter/Dart package: **{{package}}**

## Step 0 — Resolve the Package

1. If `{{package}}` is a URL (contains `pub.dev/packages/`), extract the package name from it.
2. Store the resolved package name as `PACKAGE_NAME` for all steps below.
3. Derive a short human-readable label (e.g. `connectivity_plus` → `Connectivity Plus`). Store as `DISPLAY_NAME`.
4. The new package directory name is `developer_tools_PACKAGE_NAME` (replacing any `/` or `-` with `_`).

## Step 1 — Research the Package on pub.dev

**This step is critical. Do NOT skip it.**

1. Use the `pub_dev_search` tool to search for `PACKAGE_NAME` and confirm it exists.
2. Fetch the pub.dev page for the package: `https://pub.dev/packages/PACKAGE_NAME`
3. Fetch the package README / documentation page: `https://pub.dev/documentation/PACKAGE_NAME/latest/`
4. Fetch the API reference to understand ALL public classes, methods, getters, enums, and constants: `https://pub.dev/documentation/PACKAGE_NAME/latest/PACKAGE_NAME/PACKAGE_NAME-library.html`
5. If the package has sub-libraries, fetch those too.
6. Read and understand:
   - The main class(es) and their public API surface
   - How to initialize / get an instance (singleton, factory, async, etc.)
   - All properties, methods, and streams the package exposes
   - Any enums or models returned by the API
   - Platform-specific behavior (iOS vs Android vs Web vs Desktop)
   - Required setup (permissions, native config, etc.)

**You must have a thorough understanding of the package API before proceeding to implementation.**

## Step 2 — Plan ALL Possible Tool Entries

Based on your research, plan the maximum number of useful developer tool entries. Be **verbose and exhaustive** — every piece of inspectable state, every action, every copyable value should get its own tool entry.

Common patterns for tool entries (implement ALL that apply):

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Overview / Info Dialog** | Package exposes readable state or properties | Device info, package info, battery level |
| **Copy to Clipboard** | Any token, ID, version, or state text | FCM token, device ID, app version |
| **Browser / Inspector** | Package manages a collection of items | SharedPreferences browser, route stack |
| **Toggle / Switch** | Package has enable/disable features | Dark mode, notifications, location |
| **Action / Trigger** | Package has callable actions | Clear cache, delete token, request permission |
| **Log / History Viewer** | Package emits events or has history | Provider log, network log, event stream |
| **Live Monitor / Stream** | Package has streams or real-time data | Connectivity stream, sensor data, battery state |
| **Settings / Config Editor** | Package has configurable options | Edit preferences, change settings |
| **Subscription Manager** | Package has subscribe/unsubscribe | FCM topics, event channels |
| **Status / Health Check** | Package reports status or availability | Permission status, feature availability |
| **Export / Share** | Useful to share debug data externally | Export all preferences, share device report |

List every tool entry you plan to create before writing any code.

## Step 3 — Create the Package

### Directory Structure

Create the following files under `packages/developer_tools_PACKAGE_NAME/`:

```
packages/developer_tools_PACKAGE_NAME/
├── pubspec.yaml
├── CHANGELOG.md
├── LICENSE
├── lib/
│   ├── developer_tools_PACKAGE_NAME.dart          # Barrel exports
│   └── src/
│       ├── developer_tools_PACKAGE_NAME_extension.dart  # Extension class
│       ├── <name1>_tool_entry.dart                      # Tool entry 1
│       ├── <name2>_tool_entry.dart                      # Tool entry 2
│       └── ...                                          # As many as needed
```

### 3.1 — `pubspec.yaml`

```yaml
name: developer_tools_PACKAGE_NAME
description: "DISPLAY_NAME integration for developer_tools. <Describe what debug tools are provided>."
version: 0.0.1
topics: ["development", "debug", "tools", "<relevant-topic>", "flutter"]

repository: https://github.com/ramz/developer_tools
issue_tracker: https://github.com/ramz/developer_tools/issues
homepage: https://github.com/ramz/developer_tools/tree/main/packages/developer_tools_PACKAGE_NAME
license: MIT

resolution: workspace

environment:
  sdk: ^3.7.0

dependencies:
  flutter:
    sdk: flutter

  developer_tools_core: ^0.0.3

  PACKAGE_NAME: ^<LATEST_STABLE_VERSION>

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

Use the actual latest stable version of the target package from pub.dev.

### 3.2 — `CHANGELOG.md`

```markdown
## 0.0.1

- Initial release.
- <List each tool entry added>.
```

### 3.3 — `LICENSE`

Copy the MIT license. Use the same content as other packages in this repo.

### 3.4 — `lib/developer_tools_PACKAGE_NAME.dart` (Barrel Exports)

```dart
library;

export 'package:developer_tools_core/developer_tools_core.dart';

export 'src/<name1>_tool_entry.dart';
export 'src/<name2>_tool_entry.dart';
// ... export every tool entry file
export 'src/developer_tools_PACKAGE_NAME_extension.dart';
```

### 3.5 — `lib/src/developer_tools_PACKAGE_NAME_extension.dart`

```dart
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/widgets.dart';
// import the target package
// import all tool entry files

/// DISPLAY_NAME integration for `developer_tools`.
///
/// This class extends the core [DeveloperToolsExtension] so it can be passed to
/// `DeveloperTools.builder(extensions: [...])` in your `MaterialApp.builder`.
///
/// ```dart
/// MaterialApp(
///   builder: DeveloperTools.builder(
///     extensions: const [DeveloperToolsPACKAGE_CLASS_NAME()],
///   ),
/// );
/// ```
class DeveloperToolsPACKAGE_CLASS_NAME extends DeveloperToolsExtension {
  const DeveloperToolsPACKAGE_CLASS_NAME({
    super.key,
    super.packageName = 'PACKAGE_NAME',
    super.displayName = 'DISPLAY_NAME',
    // Add optional instance parameters if the package has a main singleton/instance
  });

  // Optional: Store any instance the user passes in
  // final SomeClass? instance;

  @override
  List<DeveloperToolEntry> buildEntries(BuildContext context) {
    final sectionLabel = displayName ?? packageName;
    return <DeveloperToolEntry>[
      // List ALL tool entries here
    ];
  }

  @override
  Future<String?> debugInfo(BuildContext context) async {
    // Implement a comprehensive debug report that includes ALL
    // readable state from the package. This is used in debug report exports.
    // Wrap each section in try/catch to be resilient.
    final buffer = StringBuffer();
    try {
      // ... collect all relevant state
    } catch (e) {
      buffer.writeln('Error: $e');
    }
    return buffer.toString();
  }
}
```

**Extension class rules:**
- If the package requires an instance (e.g. `SharedPreferences`, `PackageInfo`, router), accept it as an optional constructor parameter.
- The constructor MUST be `const` (use `super.key`).
- `packageName` should be the pub.dev package name.
- `displayName` should be the human-readable label.
- `buildEntries` must return ALL tool entries with `sectionLabel` passed through.
- `debugInfo` must collect and return ALL inspectable state as formatted text.

### 3.6 — Tool Entry Files (`lib/src/<name>_tool_entry.dart`)

Each tool entry file follows this pattern:

```dart
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // if clipboard is used
// import the target package

/// A [DeveloperToolEntry] that <describe what this entry does>.
///
/// <Additional context about when/why this is useful for debugging.>
DeveloperToolEntry someFeatureToolEntry({
  String? sectionLabel,
  // Optional: accept instance parameters if needed
}) {
  return DeveloperToolEntry(
    title: '<Short Title>',
    sectionLabel: sectionLabel,
    description: '<One-line description of what this does>',
    icon: Icons.<appropriate_icon>,
    debugInfo: (BuildContext context) async {
      // Return formatted debug info string for export reports
      // Return null if nothing to report
    },
    onTap: (BuildContext context) async {
      // Show a dialog, copy to clipboard, trigger an action, etc.
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _SomeFeatureDialog();
        },
      );
    },
  );
}

// Private StatefulWidget for complex dialogs
// Use FutureBuilder for async data loading
// Use proper error handling and loading states
// Use AlertDialog with title, content, and actions
// Include "Copy" and "Close" action buttons where appropriate
// Use SelectableText for copyable values
// Use monospace font for tokens, IDs, and technical values
// Use themed colors (theme.colorScheme.*) for styling
```

**Tool entry rules:**
- Each tool entry is a **top-level function** returning `DeveloperToolEntry`.
- Function name: `camelCaseToolEntry` (always ends with `ToolEntry`).
- Always accept `String? sectionLabel` as the first named parameter.
- Accept optional instance/config parameters matching the extension class.
- Choose appropriate Material `Icons.*` for each entry.
- Include `debugInfo` callback on entries that expose readable state.
- Dialog widgets are private (`_ClassName`) and `StatefulWidget` when they load async data.
- Always handle loading, error, and empty states in dialogs.
- Use `context.mounted` checks after async gaps.
- Use `ScaffoldMessenger` for success/error snackbars.
- Use `Clipboard.setData` for copy-to-clipboard actions.

## Step 4 — Register in Workspace

Add the new package path to the root `pubspec.yaml` workspace list:

```yaml
workspace:
  - packages/developer_tools
  # ... existing packages ...
  - packages/developer_tools_PACKAGE_NAME  # <-- add this
```

## Step 5 — Install Dependencies

Run `dart pub get` from the workspace root OR use the `pub` MCP tool with the `get` command to resolve dependencies.

## Step 6 — Verify

1. Run `dart analyze` on the new package to check for errors.
2. Fix any analysis issues.
3. Run `dart format .` on the new package.

## Quality Checklist

Before finishing, verify:

- [ ] Every public API method/property of the target package that could be useful for debugging has a corresponding tool entry
- [ ] All tool entries have proper `title`, `description`, `icon`, and `sectionLabel`
- [ ] The extension class has a comprehensive `debugInfo` override
- [ ] All async operations have loading states, error handling, and `mounted` checks
- [ ] Dialogs use `AlertDialog` with proper title icons, content, and action buttons
- [ ] Copy-to-clipboard functionality is included where values are inspectable
- [ ] `pubspec.yaml` uses the latest stable version of the target package
- [ ] Barrel export file exports all source files
- [ ] Package is registered in root workspace `pubspec.yaml`
- [ ] Code passes `dart analyze` with no errors
- [ ] Code is properly formatted with `dart format`

## Implementation Style Guide

- **Be verbose**: More tool entries is better. If in doubt, create a separate entry.
- **Dialogs over snackbars**: Use dialogs for viewing data. Use snackbars for confirming actions.
- **Async first**: Always assume data loading is async. Use `FutureBuilder` or `StreamBuilder`.
- **Resilient**: Every tool entry must work even if the underlying package throws. Catch and display errors gracefully.
- **Copyable**: Any value shown in a dialog should be selectable (`SelectableText`) or have a copy button.
- **Themed**: Use `Theme.of(context).colorScheme.*` for colors. Never hard-code colors.
- **Documented**: Every public function and class must have dartdoc comments.
- **Consistent**: Follow the exact naming and structure patterns from existing packages in this monorepo.
