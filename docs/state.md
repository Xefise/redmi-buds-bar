# State

Current state of the project. Update it when a task changes any of this; history lives in git and in
[decisions/](decisions/).

_Last updated: 2026-10-05, releasing 1.1.0 (`VERSION` 1.1.0; earlier test tags and releases were deleted)._

## Models

| Model | Connects | Verified on hardware | Notes |
| --- | --- | --- | --- |
| REDMI Buds 8 | Yes | Yes (reference, test fixtures) | [models/buds-8.md](models/buds-8.md) |
| REDMI Buds 8 Pro | Yes, without handshake | Yes, with known issues: battery, noise mode, dual connection setting, spatial audio work | Several value tables differ from Buds 8, see [models/buds-8-pro.md](models/buds-8-pro.md) |
| Buds 8 Active, 6 / 6 Pro / 6 Active / 6 Lite, 5 Pro, 4 Active, 3 Pro | Unknown | No | Capabilities from Gadgetbridge |
| Other "Redmi Buds …" | Unknown | No | Generic fallback: battery + noise mode |

## Works

- Connection with SDP lookup, fallback channel, 12 s connect timeout and automatic retry.
- Battery in panel and menu bar, low battery notification (15 %, 5 % hysteresis).
- Noise control, equalizer presets and app-defined custom curves, gestures, find earbuds, toggles.
- Experimental spatial audio switch, Off (`02`) / Spatial (`03`) (Buds 8 Pro only).
- Every earbuds request and notification is acknowledged.
- English and Spanish UI, switchable at runtime. Launch at login (enabled on first run).
- CI: build + tests on PRs and `main`; release zip on `v*` tags.

## Known issues

- **Buds 8 Pro value tables are inherited from Buds 8 and partly wrong:** noise cancelling strength is
  reported as `0x13` (not in our enum, picker hidden), transparency sub-modes and equalizer (scene code `0x36`,
  different curve layout) differ, and code `0x25` may be in-ear detection rather than adaptive ANC.
- **Buds 8 Pro spatial audio:** Off (`02`) / Spatial (`03`) works by ear; "Spatial" sounds like Dolby Audio,
  but which mode it really is remains unknown. `GET_CONFIG 0x1D` always returns `0x00`, so the app shows the
  last mode chosen in the app.
- **Buds 8 Pro and the phone:** during testing the phone stopped finding the earbuds (re-pairing needed) and
  the earbuds would not stay connected to the Mac and the phone at the same time, although dual connection is
  on (`03 00 04 01`, never written by the app). Cause unknown; LDAC/LHDC on the phone is a suspect.
- **One control client at a time (suspected):** while one side holds the control channel, the other cannot
  configure the earbuds. README tells users to close the Xiaomi Earbuds app on the phone.
- Launch at login is enabled without asking.

## Open questions

- What do Buds 8 Pro `C7 07` notifications (`00`/`01`) mean? Active audio source, playback state?
- Is `0x00` from `GET_CONFIG 0x1D` "not available for this connection" or a firmware quirk?
- Does the Buds 8 Pro firmware support the handshake on another channel, or none at all?
- Real Buds 8 Pro mapping for `0x0B` strength (`0x13` = flag `0x10` + level 3?) and transparency sub-modes.

## Next steps

1. Capture Buds 8 Pro frames while switching each setting in the phone app; fix the 8 Pro value tables.
2. Find out why Buds 8 Pro do not stay connected to two devices (LDAC/LHDC off on the phone? run info entries
   `07 00` / `07 01` look like a connected-hosts list).
3. Add a "release control" action so the phone app can take over without quitting the Mac app.
4. Ask before enabling launch at login; keep `VERSION` in sync with tags.
