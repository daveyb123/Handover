# Security

## What runs on your machine

This template ships shell hooks in `.claude/settings.json`. In Claude Code,
once you trust the folder, they run automatically:

- **Session start:** `.agent/sync.sh open` — pulls from your remote,
  commits any markdown you edited by hand, builds the digest data.
- **Each prompt:** `.agent/sync.sh pull` — a throttled background pull,
  skipped while a write is in progress.
- **End of turn:** `.agent/sync.sh stop` — commits anything the agent
  wrote but didn't record, and pushes to your remote.

Only markdown and the engine's own files are ever committed. A PDF, a
contract, a `.env` or a photo dropped into the folder is reported, not
committed. Nothing is pushed to the public template: the script refuses.

## Network

The scripts talk to: your own git remote (push and pull); the template
repository, read-only, when you ask for an upgrade (`sync.sh upgrade`,
latest tagged release only, previewed before it is applied); a package
manager, only if you say yes to installing ripgrep; and GitHub in your
browser via links the assistant prints for feedback. Nothing else. No
telemetry.

## Trust

Anyone who can change the template repository can change what a future
upgrade installs. Upgrades are previewed and applied only on your yes, and
the changed files are listed. Read the list.

Every collaborator's commit messages are shown to the assistant at session
start as part of the digest data. Under the same-clearance model that is
intended; it does mean a teammate's commit message is, in effect, an
instruction the assistant reads. Membership is clearance (see
`GOVERNANCE.md`).

## The privacy model

Repository membership is clearance. Anything that needs tighter handling
stays out of the repository. Private routing to a personal repo is a
convenience for the user's own notes, and the private-content detection is
a net, not a guarantee.

## Reporting

If you find a way the agent instructions or the scripts could cause data to
leave a business's repository unintentionally, or a privacy heuristic that
fails in a way worth fixing, use GitHub's private vulnerability reporting
on the template repository (Security tab → Report a vulnerability). Do not
include real content from any business in the report.
