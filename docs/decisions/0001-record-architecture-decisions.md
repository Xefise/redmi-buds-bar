# 0001. Record architecture decisions

- Status: Accepted
- Date: 2026-10-05

## Context

Much of this project rests on reverse-engineered behaviour: why a channel is chosen, why a value is ignored,
why a handshake is skipped. Without a record, the next change (by a person or an agent) re-litigates it or
undoes it.

## Decision

Significant decisions are written as short ADRs in `docs/decisions/`, numbered, using `0000-template.md`, and
listed in `docs/nav.md`. Superseded ADRs stay with a pointer to their successor. Current status of the project
goes to `docs/state.md`, not to ADRs.

## Consequences

Small overhead per decision; reasons for protocol quirks survive refactors.
