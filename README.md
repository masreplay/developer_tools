## Monorepo (Melos)

This repo is managed with [Melos](https://melos.invertase.dev) and [Pub Workspaces](https://dart.dev/tools/pub/workspaces). The main package lives at `packages/developer_tools`; the root is the workspace definition only.

### Prerequisites

- Dart SDK ^3.10.7
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

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.

# TODOS:

- Support firebase_crashlytics
  example
  ```dart
  FirebaseCrashlytics.instance.crash();
  ```
- Support sentry:
  example
  ```dart
  Sentry.captureException(Exception('Test message'));
  ```
