# 0006. Acknowledge every request from the earbuds

- Status: Accepted
- Date: 2026-10-05

## Context

The session only acknowledged `REPORT_STATUS` and `NOTIFY_CONFIG`. Buds 8 Pro send `C7 07` notifications
and resent each one three times at 2 s intervals, which points to missing acknowledgements, and coincided
with odd behaviour with two connected devices.

## Decision

`BudsSession` answers every incoming request or notification (type with bit `0x40`) with an empty response
`04 <opcode> 00 02 00 <seq>`, including opcodes it does not interpret. The handshake opcodes (`50`, `51`)
keep their own replies.

## Consequences

Unknown notifications stop being retried. If some opcode ever needs a non-empty reply, it gets an explicit
case in the session.
