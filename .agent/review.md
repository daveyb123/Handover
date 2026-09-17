# End-of-job review and divergence report

The main defence against context rot. Not expiry dates (ignored) and not
usage stats (measure the wrong thing). Ask people at the moment they
actually remember.

## End-of-job review

Trigger: a job's `status.md` stage changes to the final stage in
`pipeline.md` (delivered, archived, awarded, debriefed — whatever the pipeline
calls it).

Ask one question:

> Job <id> is done. What didn't match the process file?

Then listen. Follow up at most twice: "Where in the pipeline did that
happen?" and "Would you want it done that way next time, or was this one a
special case?"

From the answer, propose edits to the relevant `context/operation/` file.
Show the diff in prose ("In the shoot-day stage I'd add: confirm parking with
the venue the day before. Citing job 2026-014."). Each proposed edit cites
the job as evidence in the file:

```
<!-- evidence: 2026-014, 2026-09-17 -->
```

Confirm with the file's owner (frontmatter). If the user isn't the owner,
write the proposal to the owner's `inbox.md` as a capture with
`source:review` and tell the user. Save with a message that names the job
and the file.

Also update `last_reviewed_against:` in the file's frontmatter, whether or
not anything changed. "Reviewed, nothing changed" is a real signal.

If the answer is "it all matched": say thanks, update
`last_reviewed_against`, move on. Don't push.

## Divergence report

For the owner. Monthly, or when asked. Optional. Not usage stats.

Produce, as prose with a short list per section, from `git log` and `rg`:

1. **Proposed context updates.** Since last report: how many end-of-job
   reviews ran, how many proposed edits were confirmed, how many rejected,
   which files. Rejected proposals are interesting: either the file is
   wrong in a way the owner disagrees with, or the job was a one-off.
2. **Stale operation files.** Any `context/operation/*.md` whose `updated:`
   or `last_reviewed_against:` is older than 90 days. Point at the file.
   Suggest which recent job to review it against.
3. **Stale tasks.** Open tasks with `due:` more than 14 days in the past,
   grouped by owner. Not as a score. As "these might be dead or might be
   stuck; worth a look".
4. **Jobs without a review.** Delivered in the period, no
   `last_reviewed_against` pointing at them anywhere.
5. **Friction.** Entries in `context/friction.md` since last report,
   grouped: context that was missing or wrong (fix the file), instructions
   that didn't fit (offer to draft a template issue), user habits worth a
   glossary or profile line. Clear entries that were acted on.

End with one line: which single file most needs work, and why.

Write it to `jobs/../outputs/`? No. It's not a job document. Write it to
`people/<owner>/inbox.md`? No, too long. Print it in the conversation
and offer to save it as `context/operation/.reviews/<yyyy-mm>.md` if they
want a record. Default: don't save.
