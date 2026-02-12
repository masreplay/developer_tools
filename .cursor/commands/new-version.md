---
description: Analyze git changes, determine which packages need version bumps, update versions/changelogs, and run melos commands.
---

You are working in a Flutter/Dart monorepo managed by **Melos 7** (config lives in the root `pubspec.yaml`). Publishable packages live under `packages/`.

## Your task

### Step 0 — Discover all packages

1. Read the root `pubspec.yaml` to find the `workspace:` list — this is the source of truth for all packages.
2. For each package, read its `pubspec.yaml` to get its **name**, **version**, and **dependencies** (look for any dependency whose name starts with `developer_tools`).
3. Build a dependency graph so you know which packages depend on which.

### Step 1 — Identify changed packages

1. Run `git status` and `git diff --name-only HEAD` (or vs the last tag / main branch) to collect **all changed files** (staged, unstaged, and untracked).
2. Map each changed file to its owning package by matching the file path prefix (e.g. `packages/developer_tools_core/lib/foo.dart` → `developer_tools_core`).
3. Ignore changes inside `example/` directories — those are apps, not publishable packages.
4. If **no** publishable package has changes, inform the user and stop.

### Step 2 — Determine dependency cascade

Using the dependency graph from Step 0: if a package is bumped, **every package that depends on it** must also be bumped (even if it has no direct file changes), because the dependency constraint in their `pubspec.yaml` must be updated to point to the new version. Apply this transitively.

### Step 3 — Decide version bump type for each package

Analyze the nature of the changes in each package:

| Change type | Bump | Examples |
|-------------|------|----------|
| Breaking API changes (removed/renamed public classes, methods, parameters) | **minor** (pre-1.0) | Removing a public widget, renaming a method |
| New features, new public API surface | **minor** (pre-1.0) | Adding a new tool entry, new widget, new export |
| Bug fixes, internal refactors, docs, dependency-only bumps | **patch** | Fixing a bug, updating a dependency constraint |

> Since all packages are pre-1.0, use **minor** for breaking and **patch** for non-breaking. Ask the user to confirm if unsure.

### Step 4 — Apply version updates

For **each** package that needs a bump:

1. **Bump the version** in its `pubspec.yaml`.
2. **Update `CHANGELOG.md`** — prepend a new entry at the top with the new version, today's date, and a concise summary of changes. Follow the existing changelog format in the file. Group changes under headers like `## What's Changed`, or use bullet points.
3. **Update internal dependency constraints** — for every internal dependency that was bumped, update its version constraint (e.g. `^0.0.3`) in all dependent packages' `pubspec.yaml` files.

### Step 5 — Run melos commands

After all file edits are complete, run the following commands in order:

```sh
melos bootstrap        # Re-link workspace with updated versions
melos exec -- dart analyze lib  # Ensure no analysis errors
```

If `dart analyze` fails, fix the issues before proceeding.

### Step 6 — Show a summary

Print a clear summary table:

```
Package                              Old Version → New Version  Bump Type  Reason
developer_tools_core                 0.0.2 → 0.0.3             patch      <reason>
developer_tools                      0.0.2 → 0.0.3             patch      dependency cascade (core)
...
```

Then suggest the user review the changes and run:
- `melos run publish:dry` — to verify everything is publishable
- `melos run publish:to-pub` — when ready to publish

### Step 7 — Ask about git commit & push

1. Run `git status` to check if there are any uncommitted changes (staged or unstaged) resulting from the version bumps.
2. If there are **no changes** (e.g. everything was already committed or something went wrong), inform the user and skip this step.
3. If there **are changes**, ask the user:
   - **"Would you like me to commit and push these version changes to git?"**
4. If the user says **yes**:
   - Stage all changed files: `git add .`
   - Commit with a descriptive message summarizing which packages were bumped, e.g.:
     `chore: bump developer_tools_core 0.0.2 → 0.0.3, developer_tools 0.0.2 → 0.0.3`
   - Push to the current branch: `git push`
5. If the user says **no**, skip and let them handle git manually.

### Edge cases to handle

- **Only `pubspec.yaml` changed** (e.g. bumping an external dependency like `device_info_plus`): still counts as a patch bump for that package.
- **Only tests changed**: generally no version bump needed — inform the user and ask if they still want to bump.
- **Only README/docs changed**: inform the user — a patch bump is optional. Ask before proceeding.
- **New package added**: detect if a new `packages/*/pubspec.yaml` exists that wasn't previously tracked. Inform the user.
- **Multiple packages changed independently**: bump each with its own appropriate version.
- **No git history available**: fall back to asking the user which packages to bump.

at the end of command print all packages and it's remote pub version as table