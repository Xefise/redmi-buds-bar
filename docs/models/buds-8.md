# REDMI Buds 8

Reference model: the only one tested on hardware before this documentation existed. Test fixtures in
`Tests/BudsProtocolTests/Fixtures.swift` are frames captured from it.

- Control channel: `miwear` SDP service, with the challenge/response handshake.
- Reports its name as `REDMI Buds 8`.
- Capabilities (`BudsModel.buds8`): Buds 8 Active set (presets balanced, treble, bass, voice, volume,
  custom curve; adaptive sound; find per earbud; dual connection; single tap with "none", double/triple tap,
  long press none/voice assistant) plus noise control (off, noise cancelling, transparency).
- Noise cancelling and transparency strength lists are provisional; the pickers only appear after the earbuds
  report a value.
