# State

Current state of the project. Update it when a task changes any of this; history lives in git and in
[decisions/](decisions/).

_Last updated: 2026-10-05, version 1.1.0 in `VERSION` (tags up to `v1.1.3`)._

## Models

| Model | Connects | Verified on hardware | Notes |
| --- | --- | --- | --- |
| REDMI Buds 8 | Yes | Yes (reference, test fixtures) | [models/buds-8.md](models/buds-8.md) |
| REDMI Buds 8 Pro | Yes, without handshake | Battery, noise mode, dual connection, spatial audio commands acknowledged | Several value tables differ from Buds 8, see [models/buds-8-pro.md](models/buds-8-pro.md) |
| Buds 8 Active, 6 / 6 Pro / 6 Active / 6 Lite, 5 Pro, 4 Active, 3 Pro | Unknown | No | Capabilities from Gadgetbridge |
| Other "Redmi Buds …" | Unknown | No | Generic fallback: battery + noise mode |

## Works

- Connection with SDP lookup, fallback channel, 12 s connect timeout and automatic retry.
- Battery in panel and menu bar, low battery notification (15 %, 5 % hysteresis).
- Noise control, equalizer presets and app-defined custom curves, gestures, find earbuds, toggles.
- Experimental spatial audio switch (Buds 8 Pro only).
- Every earbuds request and notification is acknowledged.
- English and Spanish UI, switchable at runtime. Launch at login (enabled on first run).
- CI: build + tests on PRs and `main`; release zip on `v*` tags.

## Known issues

- **Buds 8 Pro value tables are inherited from Buds 8 and partly wrong:** noise cancelling strength is
  reported as `0x13` (not in our enum, picker hidden), transparency sub-modes and equalizer (scene code `0x36`,
  different curve layout) differ, and code `0x25` may be in-ear detection rather than adaptive ANC.
- **Buds 8 Pro spatial audio:** set commands are acknowledged and change the sound, but `GET_CONFIG 0x1D`
  always returns `0x00`, so the app cannot read the current mode; it shows the last mode chosen in the app.
  By ear, "Off" (`03`) is the only value that sounds spatial; `0A` and `0B` sound unprocessed. The labels are
  wrong; BudsLink's table (`02` off, `03` on, `0B` on + head tracking) fits better.
- **One control client at a time (suspected):** while the Mac holds the control channel, the phone app cannot
  configure the earbuds. Quit the Mac app to use the phone app.
- `VERSION` lags behind the tags (`1.1.0` vs `v1.1.3`), so the zip and `Info.plist` show 1.1.0.
- Launch at login is enabled without asking.

## Open questions

- What do Buds 8 Pro `C7 07` notifications (`00`/`01`) mean? Active audio source, playback state?
- Is `0x00` from `GET_CONFIG 0x1D` "not available for this connection" or a firmware quirk?
- Does the Buds 8 Pro firmware support the handshake on another channel, or none at all?
- Real Buds 8 Pro mapping for `0x0B` strength (`0x13` = flag `0x10` + level 3?) and transparency sub-modes.

## Next steps

1. Relabel Buds 8 Pro spatial audio as Off (`02`) / On (`03`) after an A/B check of `02`.
2. Capture Buds 8 Pro frames while switching each setting in the phone app; fix the 8 Pro value tables.
3. Add a "release control" action so the phone app can take over without quitting the Mac app.
4. Ask before enabling launch at login; keep `VERSION` in sync with tags.
