# context/expertise/

How to do the craft well. Imported from a person, kept distinct from how this
business runs (which lives in `../operation/`).

Rules:

- One file per author per topic: `<author>-<topic>.md`.
- Never merge expertise files. Each carries a frontmatter `applies_when:` line
  so the agent knows which lens to use and when.
- Expertise files are personal. They are sent to the recipient directly and
  dropped in here. The public template ships none and ignores them by default
  (see `.gitignore`). A business may choose to commit them to its own private
  repo by removing that ignore line.
- Where a file addresses a specific tool by name ("Codex", "Claude", "the
  assistant"), the agent reads that name as "you". Authors never need to
  rewrite for a different tool.

Frontmatter template:

```
---
author: alex
topic: tender-methodology
applies_when: any bid, from bid/no-bid through submission and debrief
version: 2026-09
---
```
