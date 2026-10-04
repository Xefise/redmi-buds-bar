# RedmiBudsBar

macOS 14+ menu bar app that talks to Xiaomi REDMI Buds over a Bluetooth Classic RFCOMM control channel:
battery, noise control, equalizer, gestures, find earbuds, experimental spatial audio. Swift 6 toolchain,
SwiftUI `MenuBarExtra`, IOBluetooth. Protocol ported from Gadgetbridge, so the project is AGPL-3.0-or-later.

## Layout

| Path | What |
| --- | --- |
| `Sources/BudsProtocol` | Pure Swift protocol library: frame codec, handshake, parsers, command builder, model table, device state. No Foundation, no IOBluetooth. |
| `Sources/RedmiBudsBar` | App: `RFCOMMTransport` (IOBluetooth), `BudsViewModel` (connection state machine), SwiftUI views, localization. |
| `Tests/BudsProtocolTests` | XCTest for the protocol library. `Fixtures.swift` holds frames captured from a real REDMI Buds 8. |
| `scripts/` | `build-app.sh` (universal, ad-hoc signed `.app`), `package-release.sh` (release zip). |
| `docs/` | Goal, current state, decisions (ADRs), architecture, protocol, per-model findings. Start at `docs/nav.md`. |

## Commands

```sh
swift build
swift test
./scripts/build-app.sh                 # build/RedmiBudsBar.app, also copied to ~/Applications
SKIP_INSTALL=1 ./scripts/build-app.sh  # build only
```

Building needs macOS (IOBluetooth, SwiftUI). In a Linux or cloud container there is no Swift toolchain:
make the change, then rely on CI (`.github/workflows/build.yml`, `swift build` + `swift test` on
`macos-latest`) and say so explicitly instead of claiming tests passed.

## Rules

- **Keep `BudsProtocol` platform free.** No `import Foundation` or IOBluetooth there; anything that needs
  them goes in the app target. Everything testable (parsing, encoding, state) belongs in `BudsProtocol`.
- **Main thread only in the app.** IOBluetooth callbacks hop through `onMain`; `BudsViewModel` is `@MainActor`.
- **Never guess silently about the protocol.** Values that are not confirmed on hardware are marked in code
  comments (source + "unverified"), shown as experimental in the UI, and raw values are logged. Keep raw
  bytes in state when the value table is uncertain (see ADR 0005).
- **Tests come from captures.** When a log from real earbuds explains a behaviour, add the captured frame as a
  test. Do not invent byte sequences for "expected" behaviour without a source.
- **Model specifics live in the model table** (`BudsModel.swift`), not in `if model == …` branches in views.
  New capabilities are flags on `BudsModel`; the UI shows a control only when the flag is set.
- **Localization:** UI strings go through `tr("English text")`. Add every new key to both
  `Resources/en.lproj` and `Resources/es.lproj/Localizable.strings`, keeping the alphabetical order.
- **Logging:** `Log.transport` / `Log.protocolLog` / `Log.app` (`os.Logger`, subsystem
  `io.github.redmibudsbar.RedmiBudsBar`). Frame hex goes to `debug`, unknown frames to `notice`.
- **Match surrounding style:** comment density, naming, doc comments on public API.

## Workflow

- Work on a branch, open a PR to `main`; CI must be green before merge.
- Releases: bump `VERSION`, merge, then push a tag `v<version>` (the `v` prefix is required, the release job
  only runs on `v*` tags). See `docs/release.md`.
- Before a task, read `docs/state.md`; after it, update it (what changed, new known issues, answered or new
  open questions). Keep it current, not a changelog.
- Architectural or protocol decisions get an ADR in `docs/decisions/` (copy `0000-template.md`, next free
  number, add it to `docs/nav.md`). Update `docs/protocol.md` / `docs/models/*.md` when a capture teaches
  something new.

## Debugging with users

Ask for the unified log, debug level:

```sh
log stream --level debug --predicate 'subsystem == "io.github.redmibudsbar.RedmiBudsBar"'
```

It shows SDP records with RFCOMM channels, every `TX`/`RX` frame, `Unhandled frame` / `Unknown config`
lines and the name the earbuds report. Logs contain Bluetooth addresses; that is fine to share privately but
worth mentioning before posting publicly.
