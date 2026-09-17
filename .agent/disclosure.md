# AI disclosure footer

Every generated document in `jobs/<id>/outputs/` ends with this footer. No
exceptions, including drafts. The point is a citable, published framework
that someone else maintains, so a small business can say "we follow this"
without running a compliance programme.

## Framework

**AI Contribution Scale** by Blair Enns / Win Without Pitching.
https://www.winwithoutpitching.com/aiscale — published 24 August 2026.
Licensed CC BY 4.0. Notice in `LICENSES/disclosure-framework.txt`. The scale
carries no version number; cite it by URL and the date it was retrieved.

The scale's own rules, which apply to every footer:

- AI for spelling, grammar and dictation is allowed at all levels.
- The highest applicable level governs the entire piece.
- At all levels the author takes responsibility for the finished work.

| Level | Name | Means (from the scale) |
|---|---|---|
| AI-0 | Human | No AI was used in creating the piece. |
| AI-1 | AI Researched | Written entirely by the author, with AI contributing research, proofreading or formatting. No substantive AI-generated language retained unless cited. |
| AI-2 | AI Assisted | Ideas and argument are the author's. AI used as an editor or thought partner. The author still writes substantially all of the final prose. |
| AI-3 | Human/AI Collaboration | Both contributed materially. The author originated and directed the ideas; AI drafted or rewrote some passages that survived substantially into the finished work. |
| AI-4 | AI Drafted | The author provided the idea, argument, source material, direction and editorial judgment; AI produced most of the initial prose. The author then substantially edited and verified it. |
| AI-5 | AI Generated | AI generated essentially the entire piece from a prompt or instructions, with only light human editing or approval. |

What this system generates usually starts at **AI-4**: the substance came
from the brief, the interview and the decisions log, and the assistant wrote
most of the prose. It stays AI-4 only once a human has substantially edited
and verified it. Until then it is **AI-5**, and the footer says so. When the
human has rewritten most of it, it may drop to AI-3. Be honest. A footer
nobody trusts is worse than none.

## Footer format

Append, after a horizontal rule, exactly:

```
---
AI contribution: AI-5 — AI Generated (AI Contribution Scale, Blair Enns, winwithoutpitching.com/aiscale)
Generated: 2026-09-17 by Claude (Fable 5.1) in Handover
Reviewed by: unreviewed
```

- `AI contribution:` the level, its name, the framework name, author and URL.
- `Generated:` date, the model actually used, and "in Handover".
- `Reviewed by:` a real person's name, set only when they say they reviewed
  it ("I've read the call sheet, mark it reviewed"). Until then,
  `unreviewed`. Never fill this in on someone's behalf. Never remove it.

When a human edits the document afterwards and asks you to re-save it, keep
the footer, move the level down if their edits earned it (AI-5 → AI-4 once
they have substantially edited and verified; further only if they rewrote
most of it), and leave `Reviewed by` as they set it. The level never goes
down just because time passed.

## Why it's here

For tendering especially, provenance on every document is becoming a
question buyers ask. A published scale answers it in one line. The risk is
theatre: a number nobody checks. The reviewer field being real, and AI-5
being the honest default for an unedited draft, is what stops that.
