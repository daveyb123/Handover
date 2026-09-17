---
owner: <owner slug>
updated: <yyyy-mm-dd>
last_reviewed_against:
scope: tendering
---

# Pipeline — bids

Template. Every stage: what enters, what leaves, who owns it, what usually
goes wrong, what the assistant produces. The interview replaces the
placeholders with this business's reality; delete stages that don't exist
here and add the ones that do.

## 1. Intake
- **Enters:** an opportunity (portal alert, invitation, relationship, tender notice).
- **Leaves:** a job folder with `brief.md` started: who, what, when due, source.
- **Owner:** <who watches the sources>
- **Goes wrong:** deadline misread; documents not all downloaded; nobody told.
- **Assistant:** creates the job, captures the deadline as `due:`.

## 2. Bid / no-bid
- **Enters:** the brief and the documents.
- **Leaves:** a scored decision, logged in `decisions.md` with the reasoning.
- **Owner:** <bid owner>
- **Goes wrong:** bidding on hope; scoring what's easy to score instead of what wins.
- **Assistant:** bid/no-bid assessment; interviews the bid owner where the score is weak.

## 3. Evidence-gap interview
- **Enters:** a go decision.
- **Leaves:** a list of claims we'll need to prove and who holds the proof.
- **Owner:** <bid owner>
- **Assistant:** runs the interview; writes gaps to the question plan.

## 4. Customer evaluation analysis
- **Leaves:** evaluation-criteria map, published or inferred with confidence levels.

## 5. Why analysis
- **Leaves:** why the buyer is buying, in their words, logged in `brief.md`.

## 6. Win strategy
- **Leaves:** win strategy document in `outputs/`.
- **Goes wrong:** written once, never revisited when the buyer clarifies.

## 7. Respondent persona
- **Leaves:** who we're writing as, tone, what they'd never say.

## 8. Question planning
- **Leaves:** question plan: per question, owner, SME, evidence, target score. Tasks delegated from here.

## 9. SME interviews
- **Leaves:** raw material per question in the job folder.
- **Goes wrong:** SMEs asked to write instead of talk.

## 10. Response generation
- **Leaves:** draft sections in `outputs/`, level 3 or 4 disclosure, unreviewed.
- **Boundary:** the respondent owns the words they'll defend.

## 11. Review
- **Leaves:** reviewed sections, reviewer named in each footer.

## 12. Final competitive review
- **Leaves:** a "would this win against the likely field" note in `decisions.md`.

## 13. Submission
- **Leaves:** what was submitted, when, by whom, portal confirmation reference.
- **Goes wrong:** portal timeouts; file-size limits found at 16:55.

## 14. Award / debrief
- **Leaves:** result and buyer feedback in `decisions.md`; lessons into the evidence library.
- **Assistant:** end-of-job review runs here.
