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
WAITING <n> items, oldest <date>               #waiting in my tasks
OVERDUE <n> items                              due: before today, open
PRIVATE <ok|no-remote|absent>
REMOTE template-origin ...                   only when origin is the public template: nothing is pushed
END
```

## Paragraph one: for me

What changed for this user. New tasks delegated to them (who from, how
many), tasks of theirs someone else touched, jobs they're on that moved
stage, waiting-for items that have been waiting since before this week,
anything overdue. Example:

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

If PRIVATE is `no-remote`, once a week: "Your private repo isn't backed up
yet. Say 'back up my private repo' when you have a minute."

## Then

Update `.last-seen/<me>` to the current HEAD (`sync.sh seen`). Then wait for
the user. Don't offer a menu.
