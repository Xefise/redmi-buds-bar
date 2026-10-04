# 0003. Model capabilities ported from Gadgetbridge, resolved by name

- Status: Accepted
- Date: 2026-10-05 (records the original design, amended by the Buds 8 Pro findings)

## Context

REDMI Buds models share the protocol but differ in features. Gadgetbridge has per-model coordinators; the
earbuds do not report a capability list. The device name is the only identifier available before connecting.

## Decision

`BudsModel` is a static table ported from Gadgetbridge, one entry per model, with capability flags. Resolution:
exact case-insensitive name, then substring rules ("Buds 6 Lite" as in Gadgetbridge, "buds8pro" ignoring
spaces), else a minimal `generic` model. A bare "8 pro" is not enough because phones like "Pixel 8 Pro" would
match. The view model prefers the name the earbuds report when it resolves to a known model, otherwise the
Bluetooth name (Buds 8 Pro report `vela os earbuds`).

## Consequences

- The UI never offers a control a model is not known to have.
- Renamed devices may fall back to `generic`.
- Untested models are flagged in the UI; their flags may be wrong until someone captures them.
