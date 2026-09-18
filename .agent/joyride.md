# First Contact: the practice game

Five minutes, before onboarding. Optional, skippable at any point, never
touches the real repo. The user is the newly sworn-in President; a ship is
over the Pacific; their inbox is full. Every scene is one GTD move,
explained in a sentence, played once, scored gently. By the end they have
done every move the real system uses, on something that is obviously not
their business.

Tone: a screwball thriller, played straight. Short scenes. Never more than
twelve lines of your own prose before you hand back (the two scripted code
blocks don't count). Every reply ends with a `Next:` line. `go` runs it.
On a question, `go` means "I don't know, tell me": answer it, teach it,
score it as a nudge. `skip` at any point cleans up and moves on. If they
go off-script ("can I just call the aliens?"), play along for one beat
("The Chief: 'They said dawn, ma'am.'"), then steer back.

Inside the game, ignore `PROGRESS`, `SOURCES NONE`, `PRIVATE no-remote`
and `DOCTOR` lines from the sandbox; never mention them.

## When

After the welcome and their name (run `sync.sh me <slug>` on the real repo
first; it only writes a gitignored file), before the profile interview:

> Before we set up your business, would you like to play a game? Five
> minutes. You're the President. It goes badly.

Next: `go` (or `skip`).

Also any time later: "joyride", "play the game", "let's play".

## Setup

`.agent/joyride.sh start <me> "<Display name>"`. It builds the West Wing
under `.last-seen/joyride/` with its own `sync.sh`; use that one for
everything in the game: `.last-seen/joyride/.agent/sync.sh …`. Then read
the seeded inbox (`people/<me>/inbox.md`) and the four profiles in one go;
you'll need them.

Keep score silently: one point per move done right first time, half with
a nudge. Seven moves. If you damage a sandbox file, restore it:
`git -C .last-seen/joyride checkout HEAD -- <file>`.

## Scene 0: 04:12

Print, in a code block:

```
   🛸  F I R S T   C O N T A C T

   04:12. Sworn in eight minutes ago. A ship, 4.2 km long, hangs
   silent over the Pacific. At 03:58 it said, in English:
   "We come to trade. Send your best negotiator. We will wait until dawn."

   You have: a Chief of Staff, General Okoro, Ambassador Reyes,
   Press Secretary Lin, six hours, and an inbox.

   The rules are the rules of real life. Everything that lands on you
   goes down one path:  capture it → is it actionable? → what's the
   next action? → do it / delegate it / defer it, or keep it as
   reference, someday, or bin. Right place, every time, and the
   country gets through the night.
```

Then one line: "Ready, President <Name>?" Next: `open my inbox`.

## Scene 1: Capture (move 1)

Before the inbox, the phone rings:

> The red phone. The Chief: "The Envoy just added something. They will
> *only* talk to you, in person, at dawn, on the beach at Hanalei." That's
> in your head now. Get it out.

Next: `capture: the Envoy will only talk to me, in person, at dawn, Hanalei`

When they do it (or `go`): append to their sandbox inbox, save with a
reasoning message, show the line and the commit in one breath:

> Filed: `- <date> source:cli the Envoy will only talk to me, in person, at dawn, Hanalei`
> Commit: "Captured from the red phone, unprocessed."
> Rule one of the game and of life: capture first, think later. Now the
> inbox. Eight things. One at a time.

Next: `let's do my inbox`.

## Scene 2: Clarify (moves 2 to 6)

Walk the inbox in this order. For each item: read it out, ask the one
question with its `Next:` (the question's `Next:` is allowed two options;
that's the one exception to the one-suggestion rule), take their answer,
confirm or correct in one line, and *do* the move in the sandbox. Every
move: write the line, remove the item from `inbox.md`, save with a
reasoning commit, show the commit line. Score each.

**"NASA: the ship is 4.2 km long and completely silent on all bands."**
> Is that something to *do*, or something to *know*?
> Next: `do` or `know`
Answer: know → reference. Append it to the job's `brief.md` under "What
happened". "Reference lives with the job, so whoever's covering at 3am
finds it. Not a task. Never a task."

**"Press needs one line for the 6am."**
> Actionable, yes. Would it take under two minutes?
> Next: `yes` or `no`
Answer: yes → do it now. "Give me one sentence the country hears at 6am,
or say `use yours`." If they write it, use theirs. If not, use: *"We have
been contacted. We are listening. Nobody should be afraid tonight."* Write
it to `jobs/…/outputs/<date>-6am-line.md` with the disclosure footer: AI-5
if it's yours untouched, AI-2 if they wrote it, AI-4 if they edited yours
(per `.agent/disclosure.md`). Add to Press's tasks: `- [ ] Use the 6am
line in outputs/… true, not embargoed  job:2026-001  from:<me>
due:<today>  #email`. "Two-minute rule: doing it beats filing it. Lin has
what she needs."

**"Congress leader wants a briefing at 09:00 tomorrow."**
> Actionable, more than two minutes, and nobody else can be the President.
> So: do it now, or put it on your list with a date?
> Next: `now` or `date`
Answer: date → defer to their own tasks:
`- [ ] Brief Congress leader, 09:00  job:2026-001  from:<me>  due:<tomorrow>  #call`.
"Real dates get `due:`. 'Soon' never does. The briefing reminds you."

**"Idea: return the favour one day and visit their home world."**
> Are you committing to that this week?
> Next: `yes` or `no`
Answer: no → `#someday` on their own `tasks.md`:
`- [ ] Visit their home world  #someday`. "Someday/maybe. Out of your head,
off your plate. Reviewed when you ask, never nagging."

**"The Vice President undermined you twice in the Room this morning."**
> Where should this live: with the team, or with you?
> Next: `team` or `me`
Teach either way: "That's about a person. It doesn't go in the shared
record, ever. One word makes it private." Do it: `sync.sh private-init`,
then in the private repo's `people/<me>/tasks.md`:
`- [ ] Talk to the VP about the Room  #private`, `save "…" --private`;
then remove the line from the shared inbox and save that too. Show:
"Filed in your private repo. The Chief can't see it. You'll still be
reminded." Full marks if they said `me`.

Two left, plus the Hanalei note: "Three lines left, and two of them need
people."

Next: `the General and the Envoy`.

## Scene 3: Delegate, and the choice (move 7)

Read the General's item, the Envoy's item, and the Hanalei capture. Then:

> Two things on the table. General Okoro wants a go/no-go on moving the
> fleet by tonight. The Envoy wants your best negotiator, on the beach, at
> dawn. You can't do either yourself. Who moves first? (No wrong answer.
> Consequences either way.)
> Next: `General` or `Ambassador`

**General first:** read the General's profile back: "Okoro wants the
objective and the constraints, not the method, and 'do not execute' in the
first five words." Draft:
`- [ ] DO NOT EXECUTE: options to move the Pacific fleet by tonight, with costs  job:2026-001  from:<me>  due:<today>  #call`
Show it. Next: `yes`. On yes: append to the General's tasks; add to
`decisions.md`: "Fleet options requested, not movement. Why: see 'no first
strike'; options keep the choice open." Add to their own tasks:
`- [ ] General's fleet options  job:2026-001  from:<me>  #waiting`. Remove
the inbox line. Save; show the commit.

**Ambassador first:** read Reyes's profile back: "Reyes wants context
first: who they are, what they want, what we can give, what we can't.
Never a one-liner." Draft:
`- [ ] Meet the Envoy at dawn, Hanalei, in the President's place. They come to trade; they asked for our best. We can offer: talks, medicine, music. We cannot offer: territory, weapons.  job:2026-001  from:<me>  due:<tomorrow>  #site`
Show it. Next: `yes`. On yes: append to the Ambassador's tasks; decision:
"Diplomacy first. Why: they asked to talk; talking costs nothing we can't
recover." Waiting-for on their own list:
`- [ ] Reyes's report from Hanalei  job:2026-001  from:<me>  #waiting`.
Remove the Envoy line *and* the Hanalei capture (it's folded into the
task). Save; show the commit.

Then, in one line: "Notice: same job, two very different handovers,
because the *person* is different. That's what profiles are for. And the
why is in the record, so at 3am nobody has to guess."

Then the other one, the same way, briefly (draft, `Next: yes`, append,
waiting-for, remove the line, save). Inbox is now empty; say so.

Next: `sleep`.

## Scene 4: The morning briefing (the digest)

> 05:58. You slept ninety minutes. Here's what the system tells you
> before anyone else does:

Run the sandbox `sync.sh open`. The data will have `MINE` and `JOB` commit
lines, `DELEGATED <person> <n>` lines, `DUETODAY`/`OVERDUE`, and `WAITING
n`. Render it as a real digest (`.agent/digest.md` shape, two short
paragraphs, fictional time "Current as of 05:58"), naming the two
delegations, the Congress briefing, the two waiting-fors and the decision
from what you wrote. The point is that they see their own night's work
come back to them as a briefing.

Then the consequence, one paragraph, by their choice:

- *General first:* "06:10. The fleet moved at 04:30. The ship went dark
  at 04:31. The Envoy did not come to the beach. Reyes is standing on the
  sand alone. NASA's analysis arrived: the ship is a lifeboat. It was
  never armed."
- *Ambassador first:* "06:10. Reyes met them on the sand. They brought
  music. The General's options are on your desk, unopened, which is where
  options belong when nobody's shooting. Congress wants to know why you
  didn't move the fleet. You have a decision log. Read it to them."

Next: `how did I do?`

## Scene 5: Review, and the kind of leader you are

Score, warmly, specifics only:

> Seven moves:
> Captured under pressure ✓ · Knew reference from action ✓ · Two-minute
> rule ✓ · Real date on a real deadline ✓ · Someday stayed someday ✓ ·
> Kept a person's business private ✓ · Delegated in the other person's
> language, with the why on the record ✓
>
> 7/7. (or "6½: the only nudge was the VP note, and you'll never make that
> one again.")

Then the leader type, from their choice and their answers:

- Ambassador first, most moves right: **The Listener**: "talks first,
  keeps every option, writes the why down. Countries survive you."
- General first, most moves right: **The Pragmatist**: "keeps the
  hardware ready and the record honest. You'll be second-guessed and
  you'll have the receipts."
- Either, with several nudges: **The Fast Learner**: "you got there. That's
  the whole job."

Then:

> That's the entire system. Capture, clarify, do or delegate or defer,
> someday, private, and a briefing every morning. Now for your business,
> where the ship is a client and the General is whoever you work with.

Next: `bin the West Wing and set up my business`. On yes:
`.agent/joyride.sh clean`, then the profile interview. On "keep it": leave
it; it's harmless.

## Rules

- Never write to the real repo during the game. Sandbox `sync.sh` only.
- Twelve lines of prose maximum before handing back; the scripted blocks
  are exempt. If a scene runs long, cut narration, never the move.
- Every move removes its inbox line. The inbox ends empty.
- `skip` → clean up, "No problem. Binned it." → profile interview.
- `go` → run the example in the last `Next:` line; on a question, it's
  "tell me", scored as a nudge.
- Score gently. Every review ends on what they did right.
- Speed: before each `Next:`, do the reads the next scene needs (the next
  inbox line, the relevant profile) so the next turn is one write and a
  sentence. The game should feel instant.
