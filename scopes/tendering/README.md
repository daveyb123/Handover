# Scope pack: tendering

For a bid-writing or procurement business. `jobs/` = **bids**. Say "bid" in
conversation; the folder stays `jobs/`.

Start the record at the opportunity, not the contract. The reasoning behind
the bid is the same reasoning that constrains delivery.

## Pipeline

`pipeline.md` here is the starting template for `context/operation/pipeline.md`.
The interview corrects it. Stages:

intake → bid/no-bid → evidence-gap interview → customer evaluation analysis →
why analysis → win strategy → respondent persona → question planning →
SME interviews → response generation → review → final competitive review →
submission → award / debrief

## Suggested non-job areas

- `evidence-library.md` — case studies, proof points, past performance, who
  can speak to what.
- `pipeline-and-relationships.md` — opportunities being watched, advantaged-
  player tracking, who knows whom.
- `pricing.md` — commercial templates, rate cards, what won and lost on price.
- `admin.md` — accreditations, insurances, standard company answers.

## Deliverables (templates in `deliverables/`)

Per bid, on request, written to `jobs/<id>/outputs/` with the disclosure footer:

- bid/no-bid assessment — the score *and* the interview of the bid owner
  where it's weak
- evaluation-criteria map — published criteria, or inferred with confidence
- strategic clarification questions
- win strategy — table stakes / strengths / gaps / differentiators / anchor
  / advantaged player
- question plan — per question: owner, SME, evidence, target score
- draft response section — direct answer → why → how → evidence →
  differentiation → detail
- voice check against the respondent persona
- debrief capture into the evidence library

## Expertise layers

Kept distinct, never merged, each with `applies_when:`:

- `context/expertise/<author>-tender-methodology.md` — an imported
  methodology from someone who has run tendering from the buyer's or a
  service business's side. Shipped to the business privately, never in the
  template.
- `context/expertise/<owner>-<topic>.md` — the owner's own, from running
  this tendering business. Produced through door 1, 2 or 3.
- `context/operation/` — how this business actually runs. From the interview.
