# 0005. Unverified protocol values are experimental and kept raw

- Status: Accepted
- Date: 2026-10-05

## Context

Spatial audio on Buds 8 Pro was added from a third-party capture; another project (BudsLink, Buds 6 Pro) uses
the same code with different values. Sending wrong values to closed firmware is low risk but not zero, and
wrong labels mislead users.

## Decision

- Commands only send byte values seen being sent by an official app in some capture; no guessing.
- Features without hardware confirmation are labelled experimental in the UI and limited to the models they
  were captured on (`supportsSpatialAudio` only for Buds 8 Pro).
- State keeps the raw value (`DeviceState.spatialAudio: UInt8?`); unknown values are shown as "Unknown (0x..)"
  and logged. Readbacks known to carry no information (Buds 8 Pro `GET_CONFIG 0x1D` → `0x00`) do not overwrite
  the last known value.
- Config codes outside Gadgetbridge's list are requested only from models that declare support.

Applied: the first Buds 8 Pro table (`03` off, `0A` Dolby, `0B` Immersive) turned out wrong by ear; the switch
was reduced to the values that made an audible difference (Off `02` / Spatial `03`).

## Consequences

Users can help verify features by sending logs; the UI may show "last chosen" rather than the real mode when
the earbuds do not report it.
