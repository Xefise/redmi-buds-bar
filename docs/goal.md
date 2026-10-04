# Goal

Control Xiaomi REDMI Buds from a Mac the way the official Android app (Xiaomi Earbuds) does on a phone,
from the menu bar, without a phone.

This repository is a personal fork of
[ChristianVeneko/redmi-buds-bar](https://github.com/ChristianVeneko/redmi-buds-bar), kept for the
maintainer's own REDMI Buds 8 Pro. It is not actively maintained for other users; changes are driven by what
the maintainer needs.

## Goals

- Show battery (left, right, case) at a glance in the menu bar and panel.
- Change the settings people touch daily: noise control mode and strength, equalizer, gestures, find
  earbuds, toggles such as dual connection or wearing detection.
- Support every REDMI Buds model the protocol covers, showing only the controls a model actually has.
- Be safe with hardware we have not tested: never send arbitrary bytes, mark unverified features as
  experimental, log enough to verify them from a user's capture.
- Stay small and dependency free: Swift, SwiftUI, IOBluetooth, no third-party packages.

## Non-goals

- Replacing the phone app entirely: firmware updates, account features, earbuds pairing management.
- Changing the audio codec. macOS picks SBC or AAC itself; LDAC, LHDC and MIHC are not supported by macOS.
- Head tracking or other features that need sensor data processed by a phone.
- Platforms other than macOS 14+.
- Notarized distribution (needs a paid Apple developer account); releases are ad-hoc signed.

## Success looks like

A user with supported earbuds downloads the release zip, opens the app, and within a few seconds sees the
battery and the controls for their model; every control changes what its label says.
