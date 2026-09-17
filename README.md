# Handover

[![Licence: MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-0.1.0-lightgrey.svg)](CHANGELOG.md)

Shared tasks and shared context for a small team, kept as plain text in git
and run entirely through an assistant you talk to. Nobody needs to learn git.
Nobody needs to learn a new app.

## Start here

1. Click **Use this template** at the top of this page and give your copy a
   name (your business name is fine). Keep it private.
2. Open your assistant CLI in the folder you cloned it to.
3. Say: **"set me up"**.

That's it. The assistant will interview you about how your business runs and
build the rest.

## Where are you starting from?

**Already using an assistant CLI** (Claude Code, Codex, Gemini CLI or similar)?
Skip to "How to use it day to day".

**Using a chat assistant in a browser or desktop app, but no CLI?** Copy the
block below, paste it into that chat, and it will walk you through the rest.
It will install what's needed for you and check each step.

> I want to set up a tool called Handover. It's a git repository that I need
> to copy from a template on GitHub, clone to my computer, and then open in
> an assistant CLI such as Claude Code. I've never used a terminal or git.
> Please walk me through it one step at a time, checking each step worked
> before moving on: (1) create a GitHub account if I don't have one,
> (2) create my own private copy from the template at https://github.com/daveyb123/handover,
> (3) install git and the CLI on my computer, (4) clone my copy to a sensible
> folder, (5) open the CLI in that folder. When I'm in the CLI, tell me to say
> "set me up" and stop. Don't explain what git is unless I ask.

## Why it works like this

Your tasks and your team's context are text files in a git repository because
that gives you history, attribution and offline access for free, and because
the assistant needs to read exactly the same files you do. A separate app
would be a second place for things to drift.

The assistant is the only thing that writes to the shared record. Every
change it makes is a small commit with the reasoning in it, so anyone can see
what changed and why, and anything can be undone.

It solves two things project-management tools don't:

- **Context travels with the task.** Every task and every decision carries
  its reasoning. Someone covering for a colleague gets the *why*, not just
  the *what*.
- **Getting the process out of the owner's head.** The assistant interviews
  you about real jobs. You never sit down to "write the documentation".

## Where it came from

This started as one person's Getting Things Done system. It lived in Notion
for years and, however elegant the setup, it stayed cumbersome: too many
clicks between having a thought and having it filed. Two things changed
that. [career-ops](https://github.com/santifer/career-ops) showed that a
serious workflow could run as plain markdown inside an AI coding CLI, with
the agent doing the filing. And [Taskwarrior](https://taskwarrior.org) had
already done the hard work of making a text-based task list fast enough to
trust.

The bet behind Handover is that for systems like GTD, the future interface
is the original one: text. A file you can read, search and version beats a
UI you have to learn, especially once an assistant does the typing.

GTD maps onto the files like this:

| GTD | Here |
|---|---|
| Capture / in-basket | `people/<you>/inbox.md`, via "capture:" |
| Clarify | "let's do my inbox", one item at a time |
| Next actions, by context | `tasks.md` lines tagged `#email #call #site …` |
| Waiting for | `#waiting` |
| Someday / maybe | `#someday` |
| Projects | `jobs/<id>/` |
| Reference | `context/` |
| Review | the digest on open, and the end-of-job review |

*Getting Things Done* and *GTD* are registered trademarks of the David Allen
Company. This project is not affiliated with it.

## How to use it day to day

Open the CLI in the repo folder. The first time, you get a welcome screen,
an optional two-minute practice run on a pretend company (say "joyride" any
time to do it again), and two short interviews. After that, the first thing you see is your digest:
what changed since you were last here, filtered to you. Then talk.

- **Capture anything:** "capture: ring the venue about parking". It lands in
  your inbox. No confirmation, no ceremony.
- **Delegate:** "give this to Sam". The assistant reads how Sam likes work
  handed over, drafts it that way, shows you, and files it on your yes.
- **Ask about a job:** "where's the Northgate bid up to?" It reads the job
  folder and tells you.
- **Log a decision:** "we're going with the two-camera setup because the
  client wants cutaways". Filed in the job's decision log with the why.
- **Mark something private:** say "that's private", or put `#private` on it.
  It goes to your own personal repo, not the shared one.
- **Process your inbox:** "let's do my inbox". One item at a time.
- **Finish a job:** when a job is delivered, the assistant asks one question:
  *what didn't match the process file?* Your answer keeps the context true.

**The assistant will always ask before:** giving a task to someone else,
marking someone else's task done, changing a file about how the business
runs, filing anything it picked up from chat or email, or acting on anything
it inferred rather than was told.

**Personal tasks stay personal.** Your own to-do list (Taskwarrior, paper,
whatever you use) is yours. This system holds what people owe each other.
Blurring those two is what kills most team systems.

## Adding someone

Say "add Sam to the team". Being in the repository *is* the clearance, so
this is your decision, and it's a GitHub invitation: the assistant does it
if it can, or tells you the two clicks. Then send Sam the repository link
and one sentence: *open your CLI in it and say "set me up"*. Sam gets the
welcome, the practice run and a short profile interview, and appears in
everyone's digests from then on.

## It gets better as you use it

Nothing here needs a maintenance day.

- **Every finished job asks one question:** what didn't match the process
  file? The answer updates the file, citing the job.
- **A monthly divergence report** points at the file that most needs work:
  stale process files, dead tasks, proposals that were rejected, moments the
  assistant had to guess.
- **The assistant keeps a friction log** of its own guesses and your
  corrections, and offers the recurring ones back as template improvements.
- **It checks its own health** on every open and fixes what it safely can:
  a stuck sync, a missing search tool, an unpushed backlog. Anything needing
  a decision, it asks.
- **Upgrades come from the template.** Say "upgrade" and the engine files
  update in place, leaving your context, people and jobs untouched.

## Feedback, and one small ask

Say "feedback:" followed by anything, any time. The assistant records it
and gives you a prefilled link to send it to the template, with your
business details stripped. That is how the engine improves for everyone.

Once, after you've used it for a few days, the assistant will ask you for a
star on GitHub if it's earning its keep. Once. It won't ask again.

## Privacy

Everyone in this repository has the same clearance. Everything in it is
readable by the whole team. Anything that genuinely needs tighter handling
than that stays out of the system entirely.

One word marks something private and routes it to your own personal
repository instead. The assistant also watches for things that look private
(a named person plus performance language, pay, health, legal matters) and
asks before filing. That is a safety net, not a guarantee.

## What it won't do

Coordination and memory, not production. It tracks that the edit is due and
who's on it; it doesn't touch the timeline. It tracks that a response section
is drafted and by whom; the respondent owns the words they'll defend in the
room. Generated documents are plain markdown in the job's `outputs/` folder,
each with an AI disclosure footer using the AI Contribution Scale by Blair Enns (AI-0 to AI-5). You take them into Word, your design tool,
or wherever you like.

## Connectors (optional, later)

The assistant can read your team chat (Slack, Teams, Discord, Google Chat)
and your own mailbox, spot commitments, and *propose* inbox items. Chat stays
chat; nobody changes how they message. Nothing is ever filed silently.

Connecting Microsoft 365 or Google Workspace needs an admin and a consent
screen. Treat it as an upgrade once the basics are working, requested as
narrowly as possible: read-only, one mailbox, never the whole organisation.
The system is fully usable with no connectors at all.

## Model recommendation (September 2026)

The assistant uses two tiers. A fast, cheap model for routine reads, digests
and inbox triage; the strongest available for interviews, drafting and
strategy. In Claude Code today that means **Haiku 4.5** for routine and
**Fable 5.1** (or **Opus 5**) for drafting. Other CLIs: use their equivalent
small and large tiers. This paragraph is the only place model names appear;
update it when they change.

## Prerequisites

git, an LLM subscription, and one assistant CLI. Everything else the repo
brings, and the assistant installs (`ripgrep` for search; Taskwarrior only if
you want it).

## Contributing

Issues and pull requests are welcome. See `CONTRIBUTING.md` for the
conventions, and `CHANGELOG.md` for what has changed.

## Licence

MIT. See `LICENSE`. Third-party notices in `LICENSES/`. Expertise files
(someone's personal methodology) are theirs, sent to you directly, and never
part of this template.
