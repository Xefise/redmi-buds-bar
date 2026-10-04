# Architecture

## Modules

```
RedmiBudsBar (app target, Swift 5 language mode)
├── RedmiBudsBarApp      MenuBarExtra, menu bar label (lowest earbud battery)
├── PanelView / cards    SwiftUI, shows only what BudsModel says the model supports
├── BudsViewModel        @MainActor connection state machine, user actions, low battery notifications
├── RFCOMMTransport      IOBluetooth: SDP lookup, RFCOMM channel, raw bytes in/out
└── L10n / Titles        runtime language switch (en, es), display names for protocol enums
        │
        ▼
BudsProtocol (library, no Foundation / IOBluetooth)
├── FrameDecoder / Message   streaming frame codec
├── Authentication           SAFER+ variant challenge/response
├── BudsSession              handshake + dispatch: bytes in → frames out + BudsEvents
├── CommandBuilder           Command → frames, owns the sequence counter
├── Parsers                  DeviceInfo, RunInfo, StatusUpdate, ConfigUpdate (TLV)
├── DeviceState              UI-facing state folded from events
├── BudsModel                per-model capability table, name resolution
└── LowBatteryMonitor, EqualizerCurve, Models (enums)
```

Everything that can be tested without hardware is in `BudsProtocol` ([ADR 0002](decisions/0002-platform-free-protocol-library.md)).

## Connection lifecycle (`BudsViewModel`)

States: `deviceNotFound` → `disconnected` → `connecting` → `connected`.

1. `attemptConnection` lists paired devices whose Bluetooth name passes `BudsModel.isRedmiBuds`, picks one
   (`DeviceSelection`: saved choice, then connected, then first) and, if it is connected (or the user forced a
   reconnect), resolves its `BudsModel` and starts the transport.
2. `RFCOMMTransport.connect` runs an SDP query (8 s timeout) and picks the record named `miwear`
   (case-insensitive), else the one with the custom miwear UUID, else channel 28.
3. When the channel opens, `BudsSession.begin(authenticate:)` either sends the auth challenge or, for models
   with `requiresAuthentication == false`, the initial info requests directly.
4. The link counts as connected on `.authenticated` or on the first device info response
   (`markConnected`). Model-specific config (for example spatial audio) is requested then.
5. A 12 s timeout drops attempts that never get there; a 15 s retry timer starts new attempts while the
   earbuds stay connected. IOBluetooth connect/disconnect notifications also trigger attempts.

## Data flow

```
RFCOMM bytes → BudsSession.receive → FrameDecoder → Message
            → handle(): parse payload, build replies/ACKs
            → SessionOutput { outgoing frames, [BudsEvent] }
outgoing → RFCOMMTransport.write
events   → BudsViewModel.apply → DeviceState.apply → SwiftUI
```

User actions update `DeviceState` optimistically and send a `Command`; the earbuds confirm with a response
and usually a `NOTIFY_CONFIG`.

## Model resolution

`BudsModel.resolve(name:)`: exact case-insensitive name, then substring rules (`Buds 6 Lite`, `Buds 8 Pro`
ignoring spaces), else `generic`. The view model prefers the name reported by the earbuds when it resolves to a
known model, otherwise the Bluetooth name. Buds 8 Pro report `vela os earbuds`, so for them the Bluetooth name
decides ([ADR 0003](decisions/0003-model-capabilities-from-gadgetbridge.md)).
