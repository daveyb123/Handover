# Digest

First thing in every session. Built from `sync.sh open`, which prints the
raw data below. Turn it into two short paragraphs and a timestamp. Plain
prose, no headings, no bullet lists unless there are more than four items.

## Raw data from `sync.sh open`

```
DIGEST me=<slug> since=<hash|none> now=<HH:MM>
IDENTITY unconfirmed guess=<slug> ...       only when .last-seen/me is missing: ask first
PULL <ok|offline|conflict-resolved|conflict> <n> new commits
HANDEDIT <n files committed as unattributed hand edit | none>
MINE <hash> <date> <author> <subject>          commits touching people/<me>/
JOB <job-id> <hash> <date> <author> <subject>  commits on jobs I'm on
OPS <file> <hash> <date> <author> <subject>    context/operation/ changes
PEOPLE <name> <hash> <date> <subject>          profile changes
DELEGATED <name> <n>                           tasks I handed to <name> since last seen
DUETODAY <n> items                             my open tasks due today
WAITING <n> items, oldest <date>               #waiting in my tasks
OVERDUE <n> items                              due: before today, open
PRIVATE <ok|no-remote|absent>
REMOTE template-origin ...                   only when origin is the public template: nothing is pushed
DOCTOR <problem>                             something needs attention (see AGENTS.md §15)
REMINDER <id>\t<text>                        an Apple Reminders item to propose as a capture (opt-in)
DROP <file> <n> bytes                        a text file in .last-seen/drop/ to read and propose
SOURCES NONE                                 set up, but no way in from the phone or email yet
PROGRESS week=<monday> done=N cleared=M moved=K
                                             this person's own counts this week (see below)
NUDGE sessions=N days=D writes=W star=<url> issues=<url> sponsor=<url>
                                             once ever: time for the one small ask (AGENTS.md §15)
END

A `PRIMED` block (from `.last-seen/next.md`) may arrive with each user
prompt instead: the inbox, open tasks, teammates' hand-over preferences,
jobs. It is not digest data; use it to avoid re-reading files.
```

## Paragraph one: for me

What changed for this user. New tasks delegated to them (who from, how
many), what they handed to others (`DELEGATED`), tasks of theirs someone
else touched, jobs they're on that moved stage, what's due today,
waiting-for items that have been waiting since before this week, anything
overdue. Example:

> Two new tasks from Sam. Job 2026-014 moved to review round 2. One item
> waiting on you since Monday.

If nothing: "Nothing new for you since Tuesday."

## Paragraph two: across the business

Only what people deliberately wrote into shared files and that plausibly
touches this user's work: an operation file updated (say which and by whom),
a decision logged on a job they're on (the headline), a profile that changed.
Skip jobs they're not on unless the change is to the pipeline itself.

Never: inferred mood, activity counts as achievement, who did the most,
anything resembling a leaderboard. Task counts are a terrible proxy for
contribution and curdle fast in a small crew.

If nothing: omit the paragraph.

## Timestamp

Last line, always: `Current as of 09:12.` If PULL was `offline`, say
`Current as of 09:12 (offline, showing local state).` If a conflict was
resolved, one sentence saying what: "Sam and you both edited your tasks;
both lines kept."

If the data says `SOURCES NONE`, once a week at most, one line after the
timestamp: "Still only typing captures here. Say 'set up capture from my
phone' when you've got two minutes." Track the last time in
`.last-seen/sources-nag` (write `date +%s` there).

If there are `REMINDER` or `DROP` lines, after the digest say how many are
waiting ("Three things from your phone.") and put `let's do my inbox` in
the `Next:` line; process them there per `.agent/adapters.md`. Don't
list them in the digest itself.

If there are `DOCTOR` lines, add one sentence after the timestamp saying
what's wrong and what you'll do ("Ripgrep isn't installed; I'll install it
now." / "Nothing's backed up yet; give me a repo URL when you have one.").
Fix what `doctor --fix` fixes without asking; ask before installing
anything (`doctor --install`) and for anything that needs a URL or a
decision.

If there is a `PROGRESS` line and this is the first open of the week
(track it in `.last-seen/progress-week`: write the `week=` value there
after saying it), add one sentence after the timestamp, specific and warm,
never a score, never compared to anyone: "Since Monday: eleven things
cleared from your inbox, four tasks done, one job moved to review. Keep
going." Otherwise say nothing about it.

If there is a `NUDGE` line, this is the one time you ask. After the
timestamp, two sentences, warm, no pressure, with the numbers:

> That's five sessions and 23 things filed since Monday. If this is
> bringing you joy, great; a star helps the next small team find it:
> <star url>. If it isn't, Marie Kondo it, no hard feelings. And if you're
> brave enough to delete your project-management SaaS, send what you were
> paying it to the battle instead: <sponsor url>. Anything that's annoyed
> you, say "feedback:" and I'll pass it on.

Keep the tone light and the length to four sentences. If there is no
`sponsor=` in the data, drop the SaaS sentence.

Then run `sync.sh nudged`. Never ask again, whatever they say.

If PRIVATE is `no-remote`, once a week: "Your private repo isn't backed up
yet. Say 'back up my private repo' when you have a minute."

## Then

Update `.last-seen/<me>` to the current HEAD (`sync.sh seen`). Then wait for
the user. Don't offer a menu.
