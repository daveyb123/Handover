# Contributing

Thanks for looking. This is a template that businesses copy, so changes here
reach every copy made after them. Keep that in mind: small, well-explained
changes beat big ones.

## What belongs here

- Improvements to the engine: agent instructions, the sync script, the
  interview, the recipes under `.agent/`.
- New or improved scope packs under `scopes/`, and adapters or identity
  plugins as described in `docs/extending.md`.
- Documentation fixes.

What does not belong here: any business's actual context, people, jobs or
expertise files. Those live in each business's own private copy.

## Conventions

- **Commits from humans** use [Conventional Commits](https://www.conventionalcommits.org/):
  `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`. One change per commit.
- **Commits from the agent inside a business repo** are plain-English
  reasoning messages by design. That convention is for those repos, not this
  one.
- **Shell** is POSIX-leaning bash, checked with `shellcheck`. The sync script
  must not depend on anything beyond git, bash and coreutils.
- **Markdown** wraps at about 80 columns, uses `-` for lists, and has one
  H1 per file.
- **Versioning** follows semver. Update `CHANGELOG.md` under *Unreleased* in
  the same pull request as the change. A release bumps `.agent/VERSION`,
  the README badge and the changelog, and is tagged `vX.Y.Z`; business
  repos upgrade from tags, never from `main`.
- **Verify before shipping** anything that names an external tool's
  behaviour (hook names, instruction-file conventions, model names). They
  move. Say in the pull request what you checked and when.

## Testing

- `tests/sync-test.sh` runs the engine end to end in a temporary
  directory: two clones, concurrent appends, a same-line conflict, hand
  edits, non-text files, private saves, the template guard, the joyride.
  CI runs it with shellcheck on every push and pull request; run it locally
  before opening one.
- Interview: run it on a made-up business and apply the checks at the end
  of `.agent/interview.md`.

## Reporting problems

Open an issue with what you did, what you expected, and what happened. If
it's a privacy or security concern, see `SECURITY.md`.
