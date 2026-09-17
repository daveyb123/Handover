# Changelog

All notable changes to this template are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Session start shows a ready line on screen ("Handover is ready. Type:
  set me up") via the hook's user-facing message, so a fresh clone is never
  blank.
- Every onboarding reply ends with a `Next:` block; `go` runs it.
- `sync.sh doctor [--fix]`: health checks on every open, safe repairs.
- `sync.sh upgrade`: pull the latest engine files from the template
  without touching business context.
- `sync.sh friction`: a log of guesses and corrections, read by the
  divergence report and offered back as template issues.
- Adding people: agent instructions and a README section.

### Fixed

- The sync script never pushes to the public template: `.agent/template-origin`
  lists template remotes, pushes to them are refused, `open` reports
  `REMOTE template-origin`, and `sync.sh remote <url>` sets a business's own
  remote. A plain clone of the template previously pushed business content
  back to it.
- Joyride: the seeded pipeline now disagrees with the inbox item so the
  update is real; the payoff digest covers the practice run; the delegation
  date is worked out from today.

### Added

- Joyride: an optional practice run on a pretend company before
  onboarding, using the real sync script in a gitignored sandbox
  (`.agent/joyride.md`, `.agent/joyride.sh`).
- First-run welcome screen with a GTD workflow drawing (`.agent/welcome.md`,
  `.agent/welcome.sh --slow` for a line-by-line reveal).
- `#someday` tag for someday/maybe items; inbox processing follows the GTD
  clarify sequence.
- README section on origins (GTD, career-ops, Taskwarrior) and the GTD to
  file mapping.

## [0.1.0] - 2026-09-17

### Added

- Repository layout: `context/`, `people/`, `jobs/`, `scopes/`, `.agent/`.
- Canonical agent instructions in `AGENTS.md`, with `CLAUDE.md` and
  `GEMINI.md` import pointers.
- Bootstrap interview with three doors, profile interview, and a test
  procedure (`.agent/interview.md`).
- Portable sync script (`.agent/sync.sh`): pull with rebase, reasoning
  commits, background push, hand-edit absorption, identity, digest data,
  private sibling repo.
- Claude Code hooks for session start, prompt submit and stop
  (`.claude/settings.json`).
- Digest, privacy, retrieval, review and adapter recipes under `.agent/`.
- AI disclosure footer on the AI Contribution Scale (Blair Enns, CC BY 4.0).
- Scope packs for tendering and video production with deliverable templates.
- `GOVERNANCE.md`, MIT `LICENSE`, third-party notices in `LICENSES/`.

[Unreleased]: https://github.com/daveyb123/handover/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/daveyb123/handover/releases/tag/v0.1.0
