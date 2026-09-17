# Retrieval

No vector store, no embeddings. `rg` over markdown, with file boundaries
doing the work: one file per job, per person, per process area.

## What to load, by situation

| Situation | Load |
|---|---|
| Session open | `people/<me>/tasks.md`, `people/<me>/inbox.md`, digest data |
| A job is named or implied | that job's `brief.md`, `status.md`, `decisions.md` |
| A stage is in play | the matching section of `context/operation/pipeline.md` |
| A non-job area comes up | `context/operation/<area>.md` |
| Drafting or judging craft | each `context/expertise/*.md` whose `applies_when:` matches |
| Delegating to someone | `people/<them>/profile.md` |
| A term you don't know | `context/operation/glossary.md` |
| Sibling private repo exists | the same files from `../<me>-private/` |

Nothing else by default. If it's not in the table, search for it.

## Search conventions

```
rg "job:2026-014"                     everything on a job, across everyone
rg "^- \[ \]" people/*/tasks.md       every open task
rg "#waiting" people/<me>/tasks.md    what I'm waiting on
rg "from:alex" people/*/tasks.md      everything alex delegated
rg "due:2026-09" people/*/tasks.md    due this month
rg -l "applies_when:" context/expertise/   which expertise files exist
rg "^## " jobs/2026-014-*/decisions.md     decision headlines on a job
rg -i "northgate" --glob "*.md"       a client, anywhere
```

Use `--glob '!outputs/**'` unless the user is asking about a generated
document; outputs are large and rarely the answer.

## `applies_when:`

Every expertise file has one line in frontmatter. Read it as a condition,
not a keyword: "any bid, from bid/no-bid through submission" matches a
question about a question plan; it does not match a question about invoicing.
When unsure, load it and say you did. When two files apply, use both and say
which lens you're using where they differ. Never merge them.

## "What did you load?"

Answer with the list of file paths, nothing else. People ask this to check
you're not making things up. Make it easy.

## Degradation

Three years in, the repo will have hundreds of jobs. Search still works.
Loading everything never did. Keep the default load small and the search
specific.
