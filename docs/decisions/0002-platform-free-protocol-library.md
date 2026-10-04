# 0002. Platform-free protocol library

- Status: Accepted
- Date: 2026-10-05 (records the original design)

## Context

The protocol logic (framing, handshake crypto, TLV parsing, state) is where bugs hide, and it must be tested
without earbuds. IOBluetooth and SwiftUI only run on macOS with hardware and are hard to test.

## Decision

`Sources/BudsProtocol` is pure Swift: no Foundation, no IOBluetooth. It exposes a byte-in / frames-and-events-out
state machine (`BudsSession`). The app target owns I/O, threading and UI.

## Consequences

- Protocol behaviour is covered by XCTest with captured frames.
- Some conveniences (e.g. `trimmingCharacters`) must be written by hand in the library.
- New features need a protocol part (testable) and an app part (thin).
