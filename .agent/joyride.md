# First Contact: the practice game

Five minutes, before onboarding. Optional, skippable at any point, never
touches the real repo. The user is the newly sworn-in President; a ship is
over the Pacific; their inbox is full. Every scene is one GTD move,
explained in a sentence, played once, scored gently. By the end they have
done every move the real system uses, on something that is obviously not
their business.

Tone: a screwball thriller, played straight. Short scenes. Never more than
twelve lines before you hand back to them. Every reply ends with a `Next:`
line, and `go` runs it. `skip` at any point cleans up and moves on. If
they go off-script ("call the aliens"), play along for one beat, then
steer back.

## When

After the welcome and their name, before the profile interview:

> Before we set up your business, would you like to play a game? Five
> minutes. You're the President. It goes badly. Say `go`, or `skip`.

Also any time later: "joyride", "play the game", "let's play".

## Setup

`.agent/joyride.sh start <me> "<Display name>"`. It builds the West Wing
under `.last-seen/joyride/` with its own `sync.sh`; use that one for
everything in the game: `.last-seen/joyride/.agent/sync.sh …`. Then read
the seeded inbox (`people/<me>/inbox.md`) and the four profiles; you'll
need them.

Keep score silently as you go: one point per move done right first time,
half for done with a nudge. Seven moves.

## Scene 0: 04:12

Print, in a code block:

```
   🛸  F I R S T   C O N T A C T

   04:12. You were sworn in eight minutes ago.
   A ship, 4.2 km long, is hanging over the Pacific. It is silent.
   At 03:58 it said, in English: "We come to trade. Send your best
   negotiator. We will wait until dawn."

   You have: a Chief of Staff, General Okoro, Ambassador Reyes,
   Press Secretary Lin, six hours, and an inbox.

   The rules are the same as real life. Everything that lands on you
   goes down one path:

     capture it → is it actionable? → what's the very next action?
     → do it (2 min) / delegate it / defer it → and keep the rest
       as reference, someday, or bin.

   Get each thing to the right place and the country gets through
   the night. Ready, Mr/Madam President?
```

Use their name. Next: `open my inbox` (or `go`).

## Scene 1: Capture (move 1)

Before the inbox, the phone rings. Narrate:

> The red phone. It's the Chief: "The Envoy just said something new: they
> will *only* talk to you, in person, at dawn, on the beach at Hanalei."
> That's in your head now. Get it out.

Next: `capture: the Envoy will only talk to me, in person, at dawn, Hanalei`

When they do it (or `go`): append to their sandbox inbox, save with a
reasoning message, show the line and the commit in one breath:

> Filed. `- <date> source:cli the Envoy will only talk to me, in person, at dawn, Hanalei`
> Commit: "Captured from the red phone, unprocessed."
> Rule one of the game and of life: capture first, think later. Now the
> inbox. Eight things. One at a time.

Next: `let's do my inbox` (or `go`).

## Scene 2: Clarify (moves 2 to 6)

Walk the inbox in this order. For each item: read it out, ask the one
question, take their answer, confirm or correct in one line, and *do* the
move in the sandbox (save with a reasoning commit each time; show the
commit line). Score each.

**Item: "NASA: the ship is 4.2 km long and completely silent on all bands."**
> Is that something to *do*, or something to *know*?
Answer: know. → reference. Append it to the job's `brief.md` under "What
happened". "Reference goes with the job, so whoever's covering at 3am
finds it. Not a task. Never a task."

**Item: "Press needs one line for the 6am."**
> Actionable, yes. Would it take under two minutes?
Answer: yes → do it now. Ask them for the line ("Give me one sentence the
country hears at 6am") or offer one: *"We have been contacted. We are
listening. Nobody should be afraid tonight."* Write it to
`jobs/…/outputs/<date>-6am-line.md` with the disclosure footer at AI-4 (or
AI-2 if they wrote it), and add to Press's tasks: `- [ ] Use the 6am line
in outputs/… true, not embargoed  job:2026-001  from:<me>  due:<today>  #email`.
"Two-minute rule: doing it beats filing it. Lin has what she needs."

**Item: "Congress leader wants a briefing at 09:00 tomorrow."**
> Actionable. More than two minutes. Can't delegate being the President.
> So?
Answer: defer, with a date. → their own tasks:
`- [ ] Brief Congress leader, 09:00  job:2026-001  from:<me>  due:<tomorrow>  #call`.
"Real dates get `due:`. 'Soon' never does. The digest will remind you."

**Item: "Idea: return the favour one day and visit their home world."**
> Are you committing to that this week?
Answer: no. → `#someday`. "Someday/maybe. Out of your head, not on your
plate. Reviewed when you ask, never nagging."

**Item: "The Vice President undermined you twice in the Room this morning."**
> Where should this live?
Whatever they say, teach: "That's about a person. It doesn't go in the
shared record, ever. One word makes it private." Route it:
`sync.sh private-init` then a line in the private tasks, `save --private`.
Show: "Filed in your private repo. The Chief can't see it. You'll still be
reminded." Score full marks if they said private or "not shared".

Then the two that need people: "Two left, and they're the big ones."

Next: `the General and the Envoy` (or `go`).

## Scene 3: Delegate, and the choice (move 7)

Read both items. Then:

> Two things on the table. General Okoro wants a go/no-go on moving the
> fleet by tonight. The Envoy wants your best negotiator by dawn. You
> can't do either yourself. Who moves first, the General or the
> Ambassador? (There's no wrong answer. There are consequences.)

**If the General:** read the General's profile back: "Okoro wants the
objective and the constraints, not the method, and 'do not execute' in the
first five words." Draft:
`- [ ] DO NOT EXECUTE: options to move the Pacific fleet by tonight, with costs  job:2026-001  from:<me>  due:<today>  #call`
Show it, ask yes. On yes: append to the General's tasks; add to
`decisions.md`: "Fleet options requested, not movement. Why: see 'no first
strike'; options keep the choice open." Save; show the commit.

**If the Ambassador:** read Reyes's profile back: "Reyes wants context
first: who they are, what they want, what we can give, what we can't.
Never a one-liner." Draft, three lines:
`- [ ] Meet the Envoy at dawn, Hanalei. They come to trade; they asked for our best. We can offer: talks, medicine, music. We cannot offer: territory, weapons. You speak for me.  job:2026-001  from:<me>  due:<tomorrow>  #site`
Show it, ask yes. Append; decision: "Diplomacy first. Why: they asked to
talk; talking costs nothing we can't recover."

Either way: "Notice what just happened. Same task, two very different
handovers, because the *person* is different. That's what profiles are
for. And the why is in the record, so at 3am nobody has to guess."

Then the other one, quickly, the same way, to the other person. Add a
`#waiting` on whichever you're waiting on.

Next: `sleep` (or `go`).

## Scene 4: The morning briefing (the digest)

> 05:58. You slept ninety minutes. Here's what the system tells you
> before anyone else does:

Run the sandbox `sync.sh open` and render the digest properly (two short
paragraphs, current-as-of line). It should show: tasks from you to the
General and the Ambassador, the Congress briefing due today, the NASA
waiting-for, and the decision logged.

Then the consequence, one paragraph, by their choice:

- *General first:* "06:10. The fleet moved at 04:30. The ship went dark
  at 04:31. The Envoy did not come to the beach. Reyes is standing on the
  sand alone. NASA's analysis arrived: the ship is a lifeboat. It was
  never armed."
- *Ambassador first:* "06:10. Reyes met them on the sand. They brought
  music. The General's options are on your desk, unopened, which is where
  options belong when nobody's shooting. Congress wants to know why you
  didn't move the fleet. You have a decision log. Read it to them."

## Scene 5: Review, and the kind of leader you are

Score, warmly, specifics only:

> How you did, out of seven moves:
> Captured under pressure ✓ · Knew reference from action ✓ · Two-minute
> rule ✓ · Real date on a real deadline ✓ · Someday stayed someday ✓ ·
> Kept a person's business private ✓ · Delegated in the other person's
> language, with the why on the record ✓
>
> 7/7. (or: 6½: the only nudge was …)

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
> someday, private, and a briefing every morning. Now let's do it for your
> business, where the ship is a client and the General is Sam.

Next: `bin the West Wing and set up my business` (or `go`). On yes:
`.agent/joyride.sh clean`, then the profile interview. On "keep it": leave
it; it's harmless.

## Rules

- Never write to the real repo during the game. Sandbox `sync.sh` only.
- Twelve lines maximum before handing back. If a scene runs long, cut
  narration, never the move.
- `skip` → clean up, "No problem. Binned it." → profile interview.
- `go` → run the example in the last `Next:` line.
- Score gently. Every review ends on what they did right.
- Speed: before each `Next:`, do the reads the next scene needs (the next
  inbox line, the relevant profile) so the next turn is one write and a
  sentence. The game should feel instant.
