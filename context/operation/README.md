# context/operation/

How THIS business actually runs. Written by the agent from the owner's
interview, corrected by the owner, and updated every time a job diverges from
what the file said.

- `pipeline.md` — the job spine, stage by stage. What enters a stage, what
  leaves it, who owns it, what usually goes wrong.
- `<area>.md` — non-job areas: kit, marketing, hiring, invoicing, whatever
  the business has.
- `glossary.md` — names, acronyms, client shorthand. Also `## People`
  (name, slug, role) and `## Tools` (email, chat, storage) sections.

Every file here names an owner in frontmatter. The agent asks that owner
before changing the file.

Frontmatter template:

```
---
owner: <slug>
updated: <yyyy-mm-dd>
last_reviewed_against: <job id, or blank>
---
```

Starting empty is normal. The interview (`.agent/interview.md`) fills this in.
