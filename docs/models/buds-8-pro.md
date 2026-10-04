# REDMI Buds 8 Pro

Status: connects and is usable; several value tables are not verified. Not in Gadgetbridge.

Sources: logs from a user's earbuds (2026-10-04/05) and the source of a third-party Linux client
([T0F1Q2007/Redmi-buds-8-pro-linux-software](https://github.com/T0F1Q2007/Redmi-buds-8-pro-linux-software),
no license, so only facts are used, no code).

## Connection

SDP records (channel in parentheses): `MIWEAR` (28), `RFCOMM COM` (17), AVRCP, Advanced Audio, unnamed.
The custom miwear UUID matches `RFCOMM COM` (17), which accepts the connection but never answers. `MIWEAR`
(28) answers without any handshake; our auth challenge gets no reply. Hence `requiresAuthentication = false`
and name-first SDP lookup ([ADR 0004](../decisions/0004-buds-8-pro-without-authentication.md)).

GET_DEVICE_INFO reports the name `vela os earbuds` (Xiaomi Vela OS), so the model is resolved from the
Bluetooth name, matched as "buds 8 pro" ignoring case and spaces.

## Captured responses (initial requests)

| Request | Response payload | Reading |
| --- | --- | --- |
| Device info | `10 00 "vela os earbuds"`, `05 01 32 26 32 26`, …, `04 07 2D 2D FF`, … | Name, firmware, battery 45 % / 45 % / case unknown |
| Run info | includes `02 09 01`, `02 0A 01` and a Bluetooth address (twice) | Noise mode NC, wearing detection off (inverted flag) |
| Config `0B` | `04 00 0B 01 13` | Mode NC, strength `0x13` (not in our enum) |
| Config `25` | `03 00 25 01` | Our "adaptive NC"; third-party client calls it in-ear detection |
| Config `02` | `04 08 08`, `01 01 01`, `02 03 03`, `03 06 06`, `05 0B 0B` | Gestures; tap type `05` unknown |
| Config `0A` | `04 00 0A 06 06` | Long press cycles NC / transparency |
| Config `06` | `04 00 06 00 00` | Ear detection, two data bytes |
| Config `04` / `03` / `29` / `07` | `01` / `00` / `00` / `00` | Dual connection on, auto-answer off, adaptive sound off, preset 0 |
| Config `37` | `27 00 37 01 0A 06 06 00 00 0A 00 3E …` | Curve with 10 Hz…16 kHz bands, layout differs from Gadgetbridge |
| Config `1D` | `03 00 1D 00` | Always `00`, even right after a set |

## Notifications

- `C7 07`, payload `00`/`01`, about every 2 s while unacknowledged, toggling with phone-side activity.
  Meaning unknown. Now acknowledged ([ADR 0006](../decisions/0006-acknowledge-every-earbuds-request.md)).
- `C7 0E` REPORT_STATUS battery entries, `C7 F4` NOTIFY_CONFIG for `0C` (position), `25`, `66`, `67`.

## Value conflicts with the inherited Buds 8 tables

| Setting | Our table (Gadgetbridge) | Third-party 8 Pro client |
| --- | --- | --- |
| NC strength `0B 01 xx` | `00` balanced, `01` light, `02` deep, `03` adaptive | `00` smart, `01` deep, `02` balanced, `03` light; reported `0x13` = `0x10` flag + 3 |
| Transparency `0B 02 xx` | `00` regular, `01` voice, `02` ambient | `00` voice, `01` ambient, `02` regular |
| Equalizer | presets via `07`, curve via `37` | scenes via `36 01 xx` (standard, music, video, game, audiobooks) |
| Wearing detection `ANC 02 06 xx` | `00` = enabled | `01` = on |
| Spatial audio `1D` | `03` off, `0A` Dolby, `0B` Immersive | same |

None of these is settled until a capture shows the phone app sending them; see [state.md](../state.md).

## Spatial audio by ear (2026-10-05)

With the third-party table, the user reported: "Off" (`03`) sounds spatial, like Dolby, with a slight delay;
"Dolby" (`0A`) sounds like no processing. That fits BudsLink's Buds 6 Pro table better (`02` off, `03`
spatial, `0B` spatial + head tracking), where `03` means "on". Unconfirmed: needs an A/B test with `02` or a
capture of the phone app.
