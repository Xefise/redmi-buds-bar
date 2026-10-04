# Protocol

Reverse-engineered Xiaomi earbuds control protocol, as implemented in `Sources/BudsProtocol`. Sources:
Gadgetbridge's REDMI Buds support, captures from a REDMI Buds 8 (fixtures) and from a REDMI Buds 8 Pro (logs),
and third-party clients where noted. "Unverified" means no capture from this project confirms it.

## Transport

Bluetooth Classic RFCOMM. The control service is advertised via SDP as `miwear` (newer firmware: `MIWEAR`)
with the custom UUID `df21fe2c-2515-4fdb-8886-f12c4d67927c`. Fallback channel: 28.

On Buds 8 Pro the custom UUID belongs to a different record (`RFCOMM COM`, channel 17) that never answers,
so the lookup matches the service **name** first. See [models/buds-8-pro.md](models/buds-8-pro.md).

## Frame format

```
FE DC BA | type | opcode | length (2 bytes, BE) | [status] | seq | payload… | EF
```

- `length` counts the optional status byte, the sequence byte and the payload.
- `status` is present only in responses (`04`); `00` means success.
- Requests and notifications have bit `0x40` set in `type` and carry no status byte. (BudsLink uses bit
  `0x80` for the same test; both give the same result for the four known types.)

| type | Meaning |
| --- | --- |
| `C4` | Request from the host (phone / Mac) |
| `04` | Response (either direction) |
| `C0` | Request from the earbuds |
| `C7` | Notification from the earbuds |

`FrameDecoder` is a streaming parser: several frames per read, frames split across reads, stray bytes
(resynchronises on the next `FE DC BA`), bodies over 4096 bytes treated as corrupt.

## Acknowledgements

The earbuds resend requests and notifications that are not confirmed (observed on Buds 8 Pro: every `C7 07`
three times, 2 s apart). The host confirms **every** request or notification with an empty response:

```
FE DC BA 04 <opcode> 00 02 00 <seq> EF
```

The handshake opcodes reply with their own payloads instead ([ADR 0006](decisions/0006-acknowledge-every-earbuds-request.md)).

## Opcodes

| Opcode | Name | Notes |
| --- | --- | --- |
| `02` | GET_DEVICE_INFO | Request payload `FF FF FF FF`. TLV response, see below. |
| `07` | (unnamed) | Buds 8 Pro notification, payload `00`/`01`, meaning unknown. Called "heartbeat" by a third-party client. |
| `08` | ANC | `02 04 <mode>` noise mode; `02 06 <flag>` wearing detection (`00` = enabled on Buds 8, unverified on 8 Pro). |
| `09` | GET_DEVICE_RUN_INFO | Request payload `FF FF FF FF`. TLV response. |
| `0E` | REPORT_STATUS | Notification, TLV: `00` battery (L, R, case), `04` noise mode. |
| `50` | AUTH_CHALLENGE | `01` + 16-byte challenge / answer. |
| `51` | AUTH_CONFIRM | Host sends `01 00`; earbuds send a request answered with `01`. |
| `F2` | SET_CONFIG | `len 00 <code> <data…>` |
| `F3` | GET_CONFIG | Request `00 <code>`, one code per frame. Response entries `len 00 <code> <data…>`. |
| `F4` | NOTIFY_CONFIG | Same entry format as GET_CONFIG responses. |

## Handshake (models with `requiresAuthentication`)

1. Host → `C4 50`: `01` + random 16-byte challenge.
2. Earbuds → `04 50` answer (not verified, same as Gadgetbridge). Host → `C4 51` `01 00`.
3. Earbuds → `C0 50` with their challenge. Host answers `04 50` `01` + `Authentication.computeResponse`.
4. Earbuds → `C0 51`. Host answers `04 51` `01`, then requests device info, run info and the initial configs.

Models without authentication (Buds 8 Pro) skip straight to step 4's requests.

## TLV payloads

`len | index | data…`, where `len` counts the index byte and the data.

GET_DEVICE_INFO indices: `00` name (may be NUL padded), `01` firmware (4 nibble pairs), `03` VID/PID,
`07` battery (L, R, case; bit 7 = charging, `FF` = unknown).

GET_DEVICE_RUN_INFO indices: `09` noise mode, `0A` wearing detection (inverted: `00` = enabled).

## Config codes

| Code | Name | Data | Status |
| --- | --- | --- | --- |
| `02` | Gestures | triples `tap left right` | Gadgetbridge |
| `03` | Auto-answer | `00`/`01` | Gadgetbridge |
| `04` | Dual connection | `00`/`01` | Gadgetbridge, confirmed on 8 Pro |
| `06` | Ear detection | `00` = enabled | Gadgetbridge |
| `07` | Equalizer preset | preset code | Gadgetbridge |
| `09` | Find earbuds | `<start> <target>` | Gadgetbridge |
| `0A` | Long-press noise cycle | `left right` | Gadgetbridge |
| `0B` | Effect strength | `01 <nc>` / `02 <transparency>`; notification: `<mode> <strength>` | Gadgetbridge; 8 Pro reports `01 13`, see model notes |
| `0C` | Earbuds position | bit flags worn L/R, in case L/R | Inferred |
| `1D` | Spatial audio | `03` off, `0A` Dolby, `0B` Immersive | Third-party 8 Pro client; 8 Pro acknowledges, GET always returns `00` |
| `25` | Adaptive noise cancelling | `00`/`01` | Gadgetbridge; a third-party 8 Pro client treats it as in-ear detection |
| `29` | Adaptive sound | `00`/`01` | Gadgetbridge |
| `36` | Scene rendering (8 Pro) | `01 <scene>` | Third-party, not implemented |
| `37` | Custom equalizer curve | see `EqualizerCurve` | Gadgetbridge; 8 Pro uses a different layout |
| `66`, `67` | Unknown / immersive commute (8 Pro) | | Seen in 8 Pro notifications, not implemented |
| `68` | Head tracking (8 Pro) | | Third-party, not implemented |
