# Release

1. Bump `VERSION` (semver) in a PR; `build-app.sh` writes it into `Info.plist` and the zip name.
2. Merge after CI is green. CI (`.github/workflows/build.yml`) runs `swift build` and `swift test` on
   `macos-latest` for PRs, pushes to `main` and manual runs (`workflow_dispatch`).
3. Tag the merge commit `v<VERSION>` and push it (GitHub UI: Releases → Draft a new release → new tag).
   The tag must start with `v`; `1.2.0` does not trigger the release job.
4. The `release` job (only on `v*` tags, after `build`) runs `scripts/package-release.sh` and attaches
   `RedmiBudsBar-<VERSION>.zip` to the GitHub release for that tag, creating it if needed.

The app is ad-hoc signed, not notarized: users open it with right-click → Open or
`xattr -dr com.apple.quarantine /Applications/RedmiBudsBar.app`.

Agents working in cloud sessions can push branches but not tags; ask the user to create the tag.
