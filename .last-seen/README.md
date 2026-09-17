# .last-seen/

Local, per-machine state. Everything here except this file is ignored by git.

- `me` — the slug of the person using this clone (e.g. `alex`). Written on first run.
- `<name>` — the commit hash this person was last shown a digest for.
- `last-pull` — timestamp of the last background pull, used for throttling.
- `first-open`, `sessions`, `nudged` — when this person first opened the
  repo, how many sessions since, and whether the one-time star ask was made.
- `reminders` — present when the Apple Reminders source is switched on.
- `drop/` — text files to be read as captures; `drop/.done/` keeps what was processed.
- `joyride/` — the practice company, if one is running. Safe to delete.

Nothing in here is shared. If you clone the repo on a second machine, the agent
asks who you are again and rebuilds these.
