# jobs/

One folder per job: `<yyyy>-<nnn>-<slug>/`, e.g. `2026-014-northgate-tender/`.
Numbers run per year and never reuse. Scope packs may call these "bids" or
"productions" in conversation; the folder is always `jobs/`.

Each job folder holds:

- `brief.md` — what the client asked for and why we took it on. Starts at the
  opportunity, not the contract.
- `status.md` — current stage, key dates, who's on it.
- `decisions.md` — dated log, each entry with reasoning.
- `outputs/` — documents the agent generated for this job, markdown only,
  each with the AI disclosure footer.

Start a job by telling the agent "new job: <what it is>". It copies
`.template/`, numbers it, and fills what it knows.

Find everything on a job across everyone: `rg "job:2026-014"`.
