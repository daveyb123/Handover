# Interview

How the assistant gets a business's process out of the owner's head. This is
the product; the plumbing is everything else. Run it conversationally, one
question at a time, in plain language. Never hand the owner a form.

Triggers:

- No `context/operation/pipeline.md` → **Bootstrap** (below).
- No `people/<me>/profile.md` → **Profile interview**.
- A new scope pack is chosen → Bootstrap again, only for the gaps.

First-run order, when both apply: welcome → identity → joyride (offered,
optional, `.agent/joyride.md`) → profile interview → bootstrap → then the
digest and `sync.sh seen`. The digest is skipped until setup is
done; there is nothing to digest yet.

Drafts are shown in the conversation, not written to disk. Write and save
once the owner has read and corrected them. One save per interview section
(profile; bootstrap drafts; closing questions), each with a message that
says what was drafted and that the owner read it.

## Bootstrap

### 0. Who am I talking to

If the digest data says `IDENTITY unconfirmed`: print `.agent/welcome.md`
verbatim as your first message, then: "What should I call you? First name
or a short handle is fine." Run `.agent/sync.sh me <name>` (it
slugs it), create `people/<me>/` with all three files from
`people/.template/`, replacing `<Name>` with their display name. The
templates contain no example lines; don't add any. Then the profile
interview, briefly, before anything else.

### 1. The first question, always

> Do you already have something written down about how you work? A doc, a
> checklist, a methodology, notes in another tool? Anything counts.

Three doors:

**Door 1 — they point at a file.** Read it. Separate three things:
*operation* (how this business does it: stages, who, hand-offs, what goes
wrong), *expertise* (how to do the craft well: judgement, patterns, quality
bars), and *noise* (everything else). Draft `context/operation/pipeline.md`
and any `<area>.md` from the operation parts. Put expertise parts in
`context/expertise/<author>-<topic>.md` with an `applies_when:` line, and
tell them it's theirs and won't be shared beyond this repo. Then go to step
3 and interview only for the gaps.

**Door 2 — it's trapped in a tool.** Notion, a project-management tool, a
chat-assistant "project", a wiki. Tell them how to export it, in two lines
specific to that tool (Notion: Settings → Export → Markdown; most PM tools:
export to CSV; a chat assistant: ask it to write out everything it knows
about how the business works as one document). Then Door 1.

**Door 3 — nothing written.** Say: "Fine, that's most people. Half an hour.
Walk me through the last job you delivered, start to finish." Go to step 2.

### 2. The job walk-through (door 3, and gaps for doors 1 and 2)

For each of three or four recent jobs, in their words:

- How did it arrive? Who from, what did they ask for, why did you say yes?
- Then what happened? Keep asking "and then?" until it's delivered and paid.
- At each step: who touched it? What did they need to have in hand? What
  did they hand over, to whom?
- What went wrong, or nearly? What would you do differently?
- What's the thing you had to explain to someone that you shouldn't have
  had to?

Listen for: stages that repeat across jobs (the pipeline), hand-offs (where
context gets lost), decisions that keep coming up (candidates for a process
file), and words they use that mean something specific here (glossary).

Do not ask "what's your process". Ask about the jobs. The process falls out.

Expect private content here. Door 3 stories often involve a client's
internal people or a crew member's performance. Apply `.agent/privacy.md`:
keep the lesson in the operation file, keep the names and the judgement out,
and say you've done so. Do not create job folders for the jobs walked
through; they are evidence, not live work. If the owner wants one opened,
that's a normal "new job", confirmed as usual.

After two jobs, reflect a draft spine back: "So it sounds like every job
goes: X, then Y, then Z. Is that right, or is that just these two?" Correct
it with the third and fourth.

### 3. Draft, show, correct

Write drafts, then show them and ask for corrections. Save only after the
owner has read them.

- `context/operation/pipeline.md` — one section per stage: what enters it,
  what leaves it, who owns it, what usually goes wrong, what the assistant
  should produce here (from the scope pack if one fits). Frontmatter names
  the owner.
- `context/operation/<area>.md` — one per non-job area that came up (kit,
  marketing, hiring, invoicing, evidence library, pricing…). Only the ones
  that came up. Don't invent areas.
- `context/operation/glossary.md` — names, acronyms, client shorthand,
  with one-line meanings.

If a scope pack in `scopes/` fits, say so and start from its templates. The
owner's words override the pack everywhere they differ. Anything you kept
from the pack that the owner didn't actually say, mark with
`<!-- from pack, unconfirmed -->` so it's visible in the draft; remove the
marker when they confirm it, or the line when they don't.

Frontmatter: the fields in `context/operation/README.md`, plus `scope:` if a
pack was used. An `owner:` may name a teammate who has no `people/` folder
yet; that's fine, the folder appears when they first open the CLI.

The line between "what usually goes wrong" and craft advice: record what
happened ("the PA feed fell through at the gala; the camera operator used a
lav and a recorder"), not what to do ("always run a backup recorder"). The second is
expertise and belongs to whoever holds it.

### 4. Closing questions

Three, quick:

1. "What do you run email and chat on?" → note it in `glossary.md` under a
   `## Tools` section (the glossary also carries `## People`: name, slug,
   one-line role, so shorthand like "ask Sam" resolves). If it's Microsoft 365 or Google Workspace, say that connecting it
   is possible later, needs an admin, and isn't required.
2. "Who's on the team?" → list of names and one-line roles. Create nothing
   for them yet; each person gets their profile interview when they first
   open the CLI. Note the list in `glossary.md` under People.
3. "Where do jobs come from?" → inbox sources. Note in `pipeline.md` under
   the first stage.

### 5. Ways in: a short interview, not a menu

Before the sign-off, the inbox. Say why in two sentences, then find out
where this person's day actually happens and recommend from that. You
already know their email and chat tools from the closing questions and
their working pattern from the profile; use them, don't re-ask.

> The whole thing runs on your inbox. If getting a thought into it is
> harder than ignoring it, the system dies in a week; if it's easier, it
> takes care of itself. Typing "capture:" here always works, but you're
> not always here. Where do things land on you in a normal day: email,
> chat, phone calls, meetings, out and about, the car?

Take their top one or two and recommend, each with a one-line example of
what it looks like in use. Recipes are in `.agent/adapters.md`.

| They say | Recommend first | Example to give |
|---|---|---|
| "Email, all day" | The **Handover contact**: forward, one tap. IFTTT address if any mail; `+handover` alias if Gmail or Microsoft 365; the Mac Mail rule if Apple Mail. | "A client emails a change. You forward it to Handover. Tomorrow's inbox pass has it as a task on that job, with the email as the why." |
| "Out and about, the car, walking" | Apple: **Reminders** via Siri. Android: the Assistant into a Google Keep or Tasks note that syncs to the folder, or a share-sheet shortcut. | "Hey Siri, add ring the venue about parking to my Handover list. It's in your inbox next time you open this." |
| "Chat: WhatsApp, Teams, Slack" | The **share sheet** into the synced folder (iPhone Shortcut, Android share to Drive). Chat export for a whole thread. Connector later, optional. | "Sam says on WhatsApp he'll send the deck Friday. Long-press, share, Capture to Handover. Done." |
| "Meetings" | A **voice memo or notes app** that syncs to the folder; or two minutes of "capture:" at the desk straight after. | "Walk out of the meeting, say the three follow-ups into a voice memo, share the transcript to Handover." |
| "At my desk" | **Typing here** is already the fastest; add a desktop shortcut to `capture.txt` for when the CLI isn't open. | "Thought mid-task, alt-tab, one line, back to work." |

If they use iCloud and an iPhone, say so: "You're on iCloud, so this is
easy: Reminders for the car, and a contact for email. Two minutes."
If they're on Google or Microsoft, the synced folder is Drive or OneDrive
and the email contact is the `+handover` alias. Say it as easily.

Set up their first choice with them now, step by step, in plain words.
State the second in one sentence for later. Run `sync.sh sources` and read
it back. If they say none for now, accept it once; the digest data will
say `SOURCES NONE` and "set me up" treats it as a gap. Run `sync.sh sources` at the end and read it back: "Reminders on,
drop folder in iCloud. Say 'set up email capture' any time for the third."
If they say none for now, accept it once; the digest data will say
`SOURCES NONE` and "set me up" treats it as a gap.

Then: "That's it. You'll see a digest each time you open this. Say 'capture:'
followed by anything to get it out of your head. Say 'give this to <name>' to
delegate. Everything I write, I'll show you first."

And one more line, in this spirit, once:

> If this brings you joy, great. If it doesn't, Marie Kondo it, no hard
> feelings. And if you're ever brave enough to delete your project-management
> SaaS, the person who built this would love what you were paying it:
> https://github.com/sponsors/daveyb123

Read the sponsor handle from `.github/FUNDING.yml` (`github:`); if the file
isn't there, drop the last sentence.

Save everything with a commit message that says the business was set up
through interview, which door, and what was drafted.

Two things to say before the first save:

- If the digest data has `REMOTE template-origin`, nothing will be pushed
  until this repo has its own remote. Ask for one (a private repo they
  create; "Use this template" on GitHub does it in one click) and set it
  with `sync.sh remote <url>`. Their context must never land on the template.
- Any expertise file you created is gitignored by default, so it stays on
  this machine only. Offer to commit it in this repo (remove the
  `context/expertise/*.md` line from `.gitignore`) if the team should have
  it, or leave it personal.

## Profile interview

Short. Five questions, then write `people/<me>/profile.md` from the template
and show it. Save on their yes.

1. "What do you do here, in a line?"
2. "What are you good at that the team leans on you for?"
3. "What do you own — areas, stages, standing responsibilities?"
4. "When someone hands you work, how do you like it? One line and a date?
   All the context? Verbatim from the client?"
5. "When are you around, and when shouldn't people expect a reply?"

The profile is shared on purpose. Say so: "Everyone can read this, and
that's the point: it's how the assistant knows how to phrase things for you."

## Testing the interview

Before running it on a real business, run it on a made-up one with a
colleague playing the owner. Check: the pipeline has the stages they
described and no others; every hand-off they mentioned appears; the glossary
has the shorthand they used without explaining; nothing in `operation/` is
craft advice (that belongs in `expertise/`).
