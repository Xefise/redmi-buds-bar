# Navigation

Start here. Code conventions for agents and contributors are in [`../CLAUDE.md`](../CLAUDE.md).

## Orientation

| Document | Read when |
| --- | --- |
| [goal.md](goal.md) | You need to know what the project is for and what is out of scope. |
| [state.md](state.md) | You start a task: what works, per-model status, known issues, open questions. |
| [decisions/](decisions/) | You wonder why something is the way it is, or make a decision worth recording. |

## Reference

| Document | Contents |
| --- | --- |
| [architecture.md](architecture.md) | Modules, connection state machine, data flow from bytes to UI. |
| [protocol.md](protocol.md) | Frame format, handshake, opcodes, config codes, acknowledgements. |
| [models/buds-8.md](models/buds-8.md) | REDMI Buds 8: the hardware-tested reference model. |
| [models/buds-8-pro.md](models/buds-8-pro.md) | REDMI Buds 8 Pro: findings from captures, value conflicts. |
| [release.md](release.md) | Versioning, CI, tagging and publishing a release. |

## Decisions

| # | Title | Status |
| --- | --- | --- |
| [0001](decisions/0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](decisions/0002-platform-free-protocol-library.md) | Platform-free protocol library | Accepted |
| [0003](decisions/0003-model-capabilities-from-gadgetbridge.md) | Model capabilities ported from Gadgetbridge, resolved by name | Accepted |
| [0004](decisions/0004-buds-8-pro-without-authentication.md) | Buds 8 Pro: MIWEAR channel without authentication | Accepted |
| [0005](decisions/0005-unverified-features-are-experimental.md) | Unverified protocol values are experimental and kept raw | Accepted |
| [0006](decisions/0006-acknowledge-every-earbuds-request.md) | Acknowledge every request from the earbuds | Accepted |
| [0007](decisions/0007-least-privilege-ci.md) | Least-privilege CI and tag-gated releases | Accepted |

New decision: copy [decisions/0000-template.md](decisions/0000-template.md) to the next free number, add a row
here. Superseded decisions stay, with status `Superseded by NNNN`.
