# Joyride

A two-minute practice run on a pretend company, before onboarding. Optional,
skippable at any point, and it never touches the real repo. The point is
that the user sees the system file something for them, with the why in the
commit, before they've invested anything.

## When

After the welcome and the name, before the profile interview:

> Before we set up your business, want a two-minute joyride? I'll spin up a
> pretend design studio and you try the five moves. Say "skip" any time.

Also any time later: the user says "joyride" → same thing.

## Setup

Run `.agent/joyride.sh start <me>`. It builds Northlight Studio under
`.last-seen/joyride/`: one job (Harbour Cafe rebrand, in concepts), one
colleague (Sam: "one line and a date, don't pad it", not in on Fridays),
two inbox items, one waiting-for. It has its own `sync.sh`; use that one for
everything in the sandbox: `.last-seen/joyride/.agent/sync.sh save "…"`.

Say what you did in one line: "Done. Pretend studio, one job on the go, a
colleague called Sam. Nothing here is real."

## The five moves

Keep each to a few lines. Prompt, let them do it, show the result: the
exact line that landed in the file, and the commit message. That pairing is
the lesson. Don't explain more than the result shows.

**1. Capture.**
> Try: `capture: ring the venue about parking`

Append to their sandbox `inbox.md`, save with a reasoning message, then show
the line and the message:

> Filed. In your inbox: `- 2026-09-17 source:cli ring the venue about parking`
> Commit: "Captured from the CLI, unprocessed."
> No confirmation for captures. They're yours.

**2. Ask.**
> Try: `where's the Harbour Cafe job up to?`

Read `status.md`, `brief.md`, `decisions.md`. Answer in three lines and
mention the decision and its why ("continuity over relaunch, because the
regulars are the business"). Then: "That why came from the decisions log.
Whoever covers for Sam gets it too."

**3. Delegate.**
> Try: `give the parking call to Sam`

Read Sam's profile. Draft it Sam's way. Show it and ask:
> Sam likes one line and a date, no padding. I'd add this to Sam's list:
> `- [ ] Ring the venue about parking  job:2026-007  from:<me>  due:2026-09-19  #call`
> Sam's not in Fridays, so I've made it Thursday. Yes?

On yes: append to Sam's `tasks.md`, remove the inbox line, save with the why.
Show the commit message:
> Commit: "<me> delegated the venue parking call to Sam for the Harbour Cafe
> job; due Thursday because Sam isn't in on Fridays."
> Sam sees it in their next digest. You didn't have to message anyone.

**4. Inbox.**
> Try: `let's do my inbox`

Two seeded items. Walk them in GTD order:
- "Sam says the printer wants five working days" → not an action, it's
  reference. Propose updating the pipeline's Artwork stage. It's Sam's file,
  so: "That's Sam's file; normally I'd put the proposal in Sam's inbox. Here,
  want me to just change it?" Show the diff line and the commit.
- "studio dog?" → not committing. Propose `#someday`. One line, done.

**5. Private.**
> Try: `capture: Sam's pay review is due next month, that's private`

Route to the sandbox's private sibling (`sync.sh private-init` then
`save --private`). Show:
> Filed in your private repo, not the shared one. `git log` in the shared
> repo has no trace of it. Sam can't see it; you'll still get reminded.

## The payoff

Run `.last-seen/joyride/.agent/sync.sh seen`, then `… open`, and render the
digest exactly as `.agent/digest.md` says, for what they just did:

> Here's what you'd see next time you open this:
> "One task from you to Sam. Harbour Cafe: pipeline updated (printer lead
> time). One item waiting on you: client to confirm R1. Current as of 09:14."

Then:
> That's the whole system. Capture, ask, delegate, clarify, one word for
> private, and a digest when you come back. Bin the practice studio and set
> up your real one?

On yes: `.agent/joyride.sh clean`, then the profile interview. On "keep it
for now": leave it; it's gitignored and harmless. Clean it up when they next
say "joyride" or "bin the practice studio".

## Rules

- Never write to the real repo during the joyride. Everything goes through
  the sandbox's own `sync.sh`.
- "skip" at any step → clean up, one line ("No problem, binned it."), move
  on to setup.
- If they wander off-script ("what if I mark Sam's task done?"), follow
  them; the sandbox is for that. Show the confirm-before behaviour when it
  applies.
- Keep the whole thing under three minutes of reading. Delight is brevity
  plus seeing it work.
