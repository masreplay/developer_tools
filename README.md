# Developer Tools

A set of runtime developer tools for Flutter apps. Inspect device info, shared preferences, routes, FCM tokens, and more — all from a debug overlay inside your app.

## Packages

| Package | Version | Description |
| ------- | ------- | ----------- |
| [`developer_tools`](packages/developer_tools/) | 0.0.5 | Main package — runtime debug overlay and tool registry. |
| [`developer_tools_core`](packages/developer_tools_core/) | 0.0.3 | Core abstractions and utilities shared across all packages. |
| [`developer_tools_get`](packages/developer_tools_get/) | 0.0.2 | GetX integration for developer_tools. |
| [`developer_tools_riverpod`](packages/developer_tools_riverpod/) | 0.0.3 | Riverpod integration for developer_tools. |
| [`developer_tools_auto_route`](packages/developer_tools_auto_route/) | 0.0.3 | Auto Route integration — inspect routes, navigation stack, and router state. |
| [`developer_tools_device_info`](packages/developer_tools_device_info/) | 0.0.2 | Device Info Plus integration — view hardware specs and copy device info. |
| [`developer_tools_package_info`](packages/developer_tools_package_info/) | 0.0.2 | Package Info Plus integration — view app name, version, and build number. |
| [`developer_tools_firebase_messaging`](packages/developer_tools_firebase_messaging/) | 0.0.5 | Firebase Messaging integration — view FCM token, manage permissions, and subscribe to topics. |
| [`developer_tools_shared_preferences`](packages/developer_tools_shared_preferences/) | 0.0.3 | Shared Preferences integration — browse, search, edit, add, delete, and export preferences. |
| [`developer_tools_local_auth`](packages/developer_tools_local_auth/) | 0.0.1 | Local Auth integration — check biometric support, test authentication. |

## Monorepo (Melos)

This repo is managed with [Melos](https://melos.invertase.dev) and [Pub Workspaces](https://dart.dev/tools/pub/workspaces). The main package lives at `packages/developer_tools`; the root is the workspace definition only.

### Prerequisites

- Dart SDK ^3.7.0
- [Melos](https://melos.invertase.dev/getting-started) (optional: `dart pub global activate melos`, or use `dart run melos` from the repo)

### Commands

From the repo root:

| Command             | Description                                                        |
| ------------------- | ------------------------------------------------------------------ |
| `melos bootstrap`   | Install dependencies and link workspace packages (run after clone) |
| `melos run install` | Same as `melos bootstrap`                                          |
| `melos run clean`   | Clean build artifacts                                              |
| `melos run format`  | Format all packages                                                |
| `melos run analyze` | Run `dart analyze` in all packages                                 |
| `melos run test`    | Run tests in all packages                                          |
| `melos list`        | List workspace packages                                            |

### Versioning and releases

Versioning uses [Conventional Commits](https://www.conventionalcommits.org/). From the `main` branch:

- **Version packages and update changelogs:** `melos version`
  Bumps versions from commit history, updates dependency constraints of dependents, and generates/updates `CHANGELOG.md` per package and at workspace root.
- **Prerelease:** `melos run version:prerelease` (e.g. `0.1.0-dev.0`)
- **Graduate prerelease:** `melos run version:graduate`
- **Publish (dry run):** `melos run publish:dry`
- **Publish to pub.dev:** `melos run publish` (or `melos publish --no-dry-run`)

Configure `melos.repository` in the root `pubspec.yaml` to enable commit links in changelogs and release URL generation.
