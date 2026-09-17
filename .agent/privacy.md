# Privacy: detection and routing

## The model

Everyone in the shared repo has the same clearance. Everything in it is
readable by everyone in it. What needs tighter handling stays out entirely.
There are no classification levels inside one repo; if a business needs real
tiers, that's a separate repo with different members.

## Marking something private

Any of these, and the item is private:

- `#private` tag on a task line.
- `private: true` in a note's or job file's frontmatter.
- The user says so: "that's private", "keep that to me", "don't share that".

Private items go to the personal repo, never the shared one.

## The personal repo

Path: `../<me>-private/` (sibling of the shared repo, `<me>` from
`.last-seen/me`). Same layout. Created on first need by `sync.sh private-init`,
which also asks for a remote so it's backed up like everything else. If the
user has no private remote yet, create the repo locally, say it isn't backed
up, and remind them once a week in the digest until it is.

Loading: if the sibling exists, load the same files from it as from the
shared repo and present them as one view. When listing tasks, private ones
appear inline with a small `(private)` marker. When asked "what did you
load?", list both.

Writing: a private task goes to `../<me>-private/people/<me>/tasks.md`. A
private note about a job goes to `../<me>-private/jobs/<same id>/notes.md`
(the job folder there holds only private notes; brief, status and decisions
stay shared). Save with `sync.sh save --private "<reasoning>"`.

## Detection heuristics

Before saving anything, check it against these. If one matches, say what
you noticed, propose routing it private, and wait.

| Signal | Example |
|---|---|
| Named person + performance language | "Sam keeps missing deadlines", "need to talk to Jo about attitude" |
| Pay, salary, rates for a named person | "offer Alex 45k", "Sam's day rate is…" |
| Health | "off sick with…", "medical appointment", pregnancy, mental health |
| Legal exposure | "if they sue", "breach", "HR issue", "grievance", "disciplinary" |
| A client's internal people | "their MD is difficult", "the buyer told me off the record" |
| Hiring and firing decisions | "thinking of letting X go", candidate assessments |
| Personal circumstances of anyone | family, finances, relationships |

Phrasing: "This mentions Sam and reads like a performance note. Shall I keep
it in your private repo rather than the shared one?" One line. Don't lecture.

If the user says share it anyway, share it. It's their call; you flagged it.

## What this is not

A net, not a guarantee. The README says so and you should too when it comes
up. The team's real protection is the same-clearance rule: if something
shouldn't be seen by everyone in the repo, it shouldn't be in the repo.
