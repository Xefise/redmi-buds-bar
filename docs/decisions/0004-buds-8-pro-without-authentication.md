# 0004. Buds 8 Pro: MIWEAR channel without authentication

- Status: Accepted
- Date: 2026-10-05

## Context

On Buds 8 Pro the app hung in "Connecting...". Logs showed: the custom miwear UUID matched `RFCOMM COM`
(channel 17), which never answers; the service named `MIWEAR` is channel 28 (the name comparison was
case-sensitive). On channel 28 the earbuds ignore our auth challenge but answer requests sent without it, as
a working third-party Linux client does.

## Decision

- SDP lookup matches the service name `miwear` case-insensitively first, the custom UUID second, channel 28
  as fallback.
- `BudsModel.requiresAuthentication` (default `true`); Buds 8 Pro set it to `false`, and
  `BudsSession.begin(authenticate: false)` sends the initial requests immediately. The first device info
  response marks the link connected.
- Every connection attempt times out after 12 s so a silent channel cannot hang the app.

## Consequences

- Other models keep the Gadgetbridge handshake unchanged.
- If future firmware requires a different handshake, it is a new value of the model's connection settings,
  not a special case in the transport.
- An intermediate version used a Serial Port UUID lookup that only worked by accident; it was removed.
