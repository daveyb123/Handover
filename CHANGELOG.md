# Changelog

All notable changes to this template are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.3.6] - 2026-09-17

### Changed

- Step five of setup opens with "what's your inbox today?" and wires in the
  habit the person already has before suggesting anything new.

## [0.3.5] - 2026-09-17

### Changed

- Ways in are chosen by a short interview about where the person's day
  happens (email, chat, car, meetings, desk), each with an example, using
  what setup already learned about their tools; not a device menu.

## [0.3.4] - 2026-09-17

### Changed

- Email capture is one tap: a contact called Handover, backed by an IFTTT
  trigger address (no connector, any mail) or the user's own `+handover`
  address with a filter, rule or the Mac Mail rule behind it. Setup leads
  with it. (0.3.3 shipped the adapter half of this; 0.3.4 completes it.)

## [0.3.3] - 2026-09-17

Partial: adapter and Mail-rule half of the one-tap email capture. Superseded
by 0.3.4.

## [0.3.2] - 2026-09-17

### Changed

- Capture is platform-agnostic: the contract is a synced folder (iCloud,
  Google Drive, OneDrive, Dropbox) with a `capture.txt` where one line is
  one thought; recipes per platform for iPhone, Android, Windows, Gmail,
  Outlook, Apple Mail and Reminders. `sync.sh drop --suggest` finds synced
  folders on the machine; clearing `capture.txt` empties it in place.

## [0.3.1] - 2026-09-17

### Added

- Setup ends by explaining the inbox and switching on at least one way in
  (Reminders, share sheet, mail rule). `sync.sh sources` reports which are
  live; the digest data says `SOURCES NONE` until one is.

### Fixed

- Upgrade preview restores the tree correctly when the release adds engine
  files the clone never had.

## [0.3.0] - 2026-09-17

### Added

- Issue forms for feedback, bugs and scope-pack proposals; the "feedback:"
  link prefills the feedback form.
- CI: shellcheck and `tests/sync-test.sh` on every push and pull request,
  on the template repository only.
- README opens with a recording of the welcome screen (`docs/welcome.gif`).
- Email capture with no account: `sync.sh mail-rule` installs an Apple
  Mail rule script; forward to yourself with `capture:` in the subject and
  it lands in the drop folder. Mailbox connectors documented as the upgrade.
- Ways in from the phone with no accounts: an opt-in Apple Reminders list
  ("Handover", Siri-friendly) read on every open, and a local drop folder
  for text files (WhatsApp exports, saved emails, transcripts). Email and
  WhatsApp habits documented in `.agent/adapters.md`.
- `docs/extending.md`: the three extension points (scope packs, adapters,
  identity in front of the adapters) and what stays out.
- GitHub Sponsors: `FUNDING.yml`, a README badge and section, and one
  sentence in the one-time ask, read from the funding file.

## [0.2.0] - 2026-09-17

### Added

- Session start shows a ready line on screen ("Handover is ready. Type:
  set me up"), so a fresh clone is never blank.
- Every reply ends with one `Next:` line; `go` runs it.
- Joyride: an optional practice run on a pretend company before
  onboarding, using the real sync script in a gitignored sandbox.
- First-run welcome screen with a GTD workflow drawing.
- `#someday` tag; inbox processing follows the GTD clarify sequence.
- `sync.sh doctor`: health checks on every open, safe repairs; installs
  only with `--install` after a yes.
- `sync.sh upgrade`: preview, then `--apply`, the latest tagged engine
  release from the template; business context untouched. `.agent/VERSION`
  records the engine release.
- `sync.sh friction` and `sync.sh feedback`: a log of guesses and
  corrections read by the divergence report, and a sanitised, prefilled
  template issue link. One-time star ask after real use.
- `sync.sh remote <url>`: set a business's own remote; refuses the template.
- Adding people: agent instructions and a README section.
- Disclosure footer is one line: the level linked to the AI Contribution
  Scale (with attribution in the link title) and "By Handover". README
  states the repository's own level (AI-4).
- README: origins (GTD, career-ops, Taskwarrior), GTD-to-files table, what
  runs on your machine, an example digest and capture; SECURITY.md
  describes hooks, network and trust; `.claude/settings.json` pre-allows
  the engine scripts so first-run captures need no permission prompt.

### Fixed

- The sync script never pushes to the public template (`.agent/template-origin`).
- Only markdown and engine files are ever committed; other files dropped
  into the folder are reported, not pushed. `.claude/settings.local.json`,
  `CLAUDE.local.md` and `.env*` are ignored.
- `sync.sh save` accepts `--private` in any position.
- Hand edits are absorbed before pulling, so a rebase never runs over
  uncommitted files; background pulls skip while a write is in progress.
- Private repo's first push sets the upstream; `sync.sh remote` checks
  before changing anything.
- Joyride dates are computed from today; the sandbox doctor stays quiet.
- Portable date handling on Linux; ripgrep install knows apt, dnf and
  winget as well as Homebrew.

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

[Unreleased]: https://github.com/daveyb123/Handover/compare/v0.3.6...HEAD
[0.3.6]: https://github.com/daveyb123/Handover/releases/tag/v0.3.6
[0.3.5]: https://github.com/daveyb123/Handover/releases/tag/v0.3.5
[0.3.4]: https://github.com/daveyb123/Handover/releases/tag/v0.3.4
[0.3.3]: https://github.com/daveyb123/Handover/releases/tag/v0.3.3
[0.3.3]: https://github.com/daveyb123/Handover/releases/tag/v0.3.3
[0.3.2]: https://github.com/daveyb123/Handover/releases/tag/v0.3.2
[0.3.1]: https://github.com/daveyb123/Handover/releases/tag/v0.3.1
[0.3.0]: https://github.com/daveyb123/Handover/releases/tag/v0.3.0
[0.2.0]: https://github.com/daveyb123/Handover/releases/tag/v0.2.0
[0.1.0]: https://github.com/daveyb123/Handover/releases/tag/v0.1.0
