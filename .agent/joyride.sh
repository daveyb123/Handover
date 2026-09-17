#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Creates a throwaway practice company under .last-seen/joyride/ (gitignored,
# never shared) so a new user can try the moves before onboarding. Uses the
# real sync.sh, so what they practise is what they'll get.
#
#   joyride.sh start <me-slug>   build the sandbox (idempotent)
#   joyride.sh path              print the sandbox path
#   joyride.sh clean             remove it, and its private sibling
set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$here/.." && pwd)"
SB="$ROOT/.last-seen/joyride"
TODAY="$(date +%F)"

case "${1:-}" in
  path) echo "$SB"; exit 0 ;;
  clean)
    rm -rf "$SB" "$ROOT/.last-seen/"*-private-joyride 2>/dev/null
    # the sandbox's private sibling lands beside it, inside .last-seen
    find "$ROOT/.last-seen" -maxdepth 1 -type d -name '*-private' -exec rm -rf {} + 2>/dev/null
    echo "JOYRIDE cleaned"; exit 0 ;;
  start) ;;
  *) sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
esac

me="${2:-}"; [ -n "$me" ] || { echo "joyride: me-slug required" >&2; exit 1; }
if [ -d "$SB/.git" ]; then echo "JOYRIDE exists at $SB"; exit 0; fi

mkdir -p "$SB/.agent" "$SB/.last-seen" "$SB/people/$me" "$SB/people/sam" \
         "$SB/jobs/2026-007-harbour-cafe-rebrand/outputs" "$SB/context/operation" "$SB/context/expertise"
cp "$here/sync.sh" "$SB/.agent/sync.sh"
cp "$ROOT/.gitattributes" "$SB/.gitattributes"
cp -R "$ROOT/people/.template" "$SB/people/.template"
printf '.last-seen/*\n!.last-seen/README.md\n' > "$SB/.gitignore"
echo "$me" > "$SB/.last-seen/me"

cat > "$SB/README.md" <<'EOR'
# Northlight Studio (practice company)

A pretend three-person design studio for trying Handover. Nothing here is
real. It lives outside the shared repo and is deleted when you're done.
EOR

cat > "$SB/context/operation/pipeline.md" <<'EOR'
---
owner: sam
updated: 2026-09-01
last_reviewed_against: 2026-005
---

# Pipeline — jobs

## 1. Brief
- **Enters:** an enquiry. **Leaves:** a one-page brief the client has agreed.
- **Owner:** whoever took the call. **Goes wrong:** brief lives in an email thread.

## 2. Concepts
- **Leaves:** two or three directions. **Owner:** sam.

## 3. Client review
- **Leaves:** one direction chosen, feedback in decisions.md. **Goes wrong:** feedback by phone, never written down.

## 4. Artwork
- **Leaves:** print-ready files. **Goes wrong:** printer lead time forgotten. Five working days.

## 5. Delivery
- **Leaves:** files sent, invoice raised.
EOR

cat > "$SB/context/operation/glossary.md" <<'EOR'
---
owner: sam
updated: 2026-09-01
---

# Glossary

- **R1 / R2** — client review round one, two.
- **the printer** — Harbourside Print, five working days lead time.

## People
- sam — Sam, designer, owns concepts and artwork.
EOR

cat > "$SB/people/sam/profile.md" <<'EOR'
---
name: Sam
role: designer
owns: [concepts, artwork]
availability: Mon–Thu
---

# Sam

## What I'm good at
Brand identities. Fast first concepts.

## What I own
Concepts and artwork on every job.

## How I like work handed to me
One line and a date. Don't pad it. If the client said something, give me
their exact words.

## Working pattern
Mon–Thu. Fridays I'm not here; don't expect a reply.
EOR
printf '# Tasks — Sam\n\n- [ ] Second concept direction for Harbour Cafe  job:2026-007  from:sam  due:2026-09-19  #computer\n' > "$SB/people/sam/tasks.md"
printf '# Inbox — Sam\n' > "$SB/people/sam/inbox.md"

cat > "$SB/people/$me/profile.md" <<EOR
---
name: $me
role: runs the studio
owns: [briefs, client relationships]
availability: Mon–Fri
---

# $me

Practice profile. Your real one comes from the profile interview.
EOR
printf '# Tasks — %s\n\n- [ ] Client to confirm R1 date  job:2026-007  from:%s  #waiting\n' "$me" "$me" > "$SB/people/$me/tasks.md"
printf '# Inbox — %s\n\n- %s source:cli Sam says the printer wants five working days now, not three\n- %s source:cli studio dog?\n' "$me" "$TODAY" "$TODAY" > "$SB/people/$me/inbox.md"

J="$SB/jobs/2026-007-harbour-cafe-rebrand"
cat > "$J/brief.md" <<'EOR'
---
job: 2026-007
client: Harbour Cafe
stage: concepts
opened: 2026-09-08
---

# Harbour Cafe rebrand

## What the client asked for
New logo, menu and signage. "Something that looks like it's been here
forty years, because it has."

## Why they asked, and why we said yes
New owners, same regulars. They want continuity, not a relaunch. We said
yes because it's exactly the kind of job Sam is best at.

## Constraints
Signage needs to be at the printer by 2026-10-03. Budget fixed.
EOR
cat > "$J/status.md" <<EOR
---
job: 2026-007
stage: concepts
updated: $TODAY
people: [$me, sam]
---

# Status — Harbour Cafe rebrand

**Stage:** concepts
**Key dates:** R1 with client, date not yet confirmed; signage to printer 2026-10-03
**Who's on it:** $me — client; sam — concepts and artwork

## Right now
Sam has one direction done and a second in progress. Waiting on the client
to confirm the R1 date.
EOR
cat > "$J/decisions.md" <<'EOR'
# Decisions — Harbour Cafe rebrand

## 2026-09-08 — Continuity over relaunch

**Who:** sam
**Why:** The regulars are the business. The new owners were clear they don't
want anyone to feel it changed hands. Every concept starts from the old
sign, not a blank page.
**Affects:** both concept directions.
EOR

( cd "$SB" && git init -q -b main && git add -A \
  && git -c user.name="Northlight Studio" -c user.email="practice@example.invalid" commit -q -m "Practice company: Northlight Studio, one job in concepts, two people" )
echo "JOYRIDE ready at $SB"
