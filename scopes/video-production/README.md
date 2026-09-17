# Scope pack: video production

For a production company. `jobs/` = **productions**. Say "production" or
"shoot" in conversation; the folder stays `jobs/`.

Start at the pitch. The brief written to win the job is the document that
constrains the shoot and the edit; if the record starts at contract, that
reasoning is lost and the crew rediscovers it.

## Pipeline

`pipeline.md` here is the starting template for `context/operation/pipeline.md`.

pitch / quote → brief → pre-production → shoot day(s) → ingest and triage →
edit → client review rounds → delivery → archive and invoice

## Suggested non-job areas

- `kit.md` — what we own, what we hire, maintenance, who's responsible.
- `marketing.md` — showreel, socials, where work comes from.
- `crew.md` — regular freelancers, rates, who's good at what, availability.
- `invoicing.md` — terms, deposits, what triggers an invoice, cashflow notes.

## Deliverables (templates in `deliverables/`)

- treatment
- shot list
- call sheet
- crew assignments (from profiles)
- client-facing recap after each review round
- delivery note
- archive checklist

## Boundary

Coordination and memory, not production. Tracks that the edit is due, who's
on it, which review round, what the client asked for. Does not touch the
timeline, grade or mix. Tracks that the master went out and the invoice was
raised; the transfer is someone else's tool.

## Handoff to an editing agent

If the business runs an editing-assistant agent where the footage lives,
that is a separate repo and a separate agent. This system hands over two
files at the ingest stage: the job's `brief.md` and the shot list from
`outputs/`. The editing agent does footage triage and a rough assembly
against the shot list: a stringout the editor shapes, not a cut. Nothing
else is shared between the two.

## Chat

If the team already uses a chat assistant, it fits as the chat adapter
(`.agent/adapters.md`): a signal source, not a second interface.
