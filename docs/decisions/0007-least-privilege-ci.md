# 0007. Least-privilege CI and tag-gated releases

- Status: Accepted
- Date: 2026-10-04

## Context

The workflow ran every build, including pull requests, with `contents: write`, and used third-party actions
pinned by mutable tags.

## Decision

- Workflow token is `contents: read` by default. Only the `release` job, which runs on `v*` tags after `build`
  succeeds, gets `contents: write`.
- Actions are pinned to commit SHAs (comment with the tag); checkout does not persist credentials.
- `workflow_dispatch` allows a manual build-and-test run; it never releases.

## Consequences

Updating actions means updating SHAs. Releases require a `v`-prefixed tag, which agents in cloud sessions
cannot push; a person creates it.
