# Developer Tools

A set of runtime developer tools for Flutter apps. Inspect device info, shared preferences, routes, FCM tokens, and more — all from a debug overlay inside your app.

## Packages

[`developer_tools_riverpod`](https://pub.dev/packages/developer_tools_riverpod/)
[`developer_tools_get`](https://pub.dev/packages/developer_tools_get/)
[`developer_tools_auto_route`](https://pub.dev/packages/developer_tools_auto_route/)
[`developer_tools_device_info`](https://pub.dev/packages/developer_tools_device_info/)
[`developer_tools_package_info`](https://pub.dev/packages/developer_tools_package_info/)
[`developer_tools_firebase_messaging`](https://pub.dev/packages/developer_tools_firebase_messaging/)
[`developer_tools_shared_preferences`](https://pub.dev/packages/developer_tools_shared_preferences/)
[`developer_tools_local_auth`](https://pub.dev/packages/developer_tools_local_auth/)

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
