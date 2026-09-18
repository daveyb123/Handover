#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Builds the practice game "First Contact" under .last-seen/joyride/
# (gitignored, never shared): the user is the newly sworn-in President, a
# ship is over the Pacific, and their inbox is full. Uses the real sync.sh,
# so what they practise is what they'll get.
#
#   joyride.sh start <me-slug> [display-name]   build the game (idempotent)
#   joyride.sh path                             print the sandbox path
#   joyride.sh clean                            remove it, and its private sibling
set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$here/.." && pwd)"
SB="$ROOT/.last-seen/joyride"
TODAY="$(date +%F)"

case "${1:-}" in
  path) echo "$SB"; exit 0 ;;
  clean)
    rm -rf "$SB"
    find "$ROOT/.last-seen" -maxdepth 1 -type d -name '*-private' -exec rm -rf {} + 2>/dev/null
    echo "JOYRIDE cleaned"; exit 0 ;;
  start) ;;
  *) sed -n '3,/^set -u/p' "$0" | grep '^#' | sed 's/^# \{0,1\}//'; exit 0 ;;
esac

shift_date() { local n="$1"; date -v"${n}d" +%F 2>/dev/null || date -d "$TODAY $n days" +%F 2>/dev/null; }
me="${2:-}"; [ -n "$me" ] || { echo "joyride: me-slug required" >&2; exit 1; }
NAME="${3:-$me}"
if [ -d "$SB/.git" ]; then echo "JOYRIDE exists at $SB"; exit 0; fi
TOMORROW="$(shift_date +1)"; YESTERDAY="$(shift_date -1)"

mkdir -p "$SB/.agent" "$SB/.last-seen" "$SB/people/$me" "$SB/people/chief" "$SB/people/general" "$SB/people/ambassador" "$SB/people/press" \
         "$SB/jobs/2026-001-first-contact/outputs" "$SB/context/operation" "$SB/context/expertise"
cp "$here/sync.sh" "$SB/.agent/sync.sh"
cp "$ROOT/.gitattributes" "$SB/.gitattributes"
cp -R "$ROOT/people/.template" "$SB/people/.template"
printf '.last-seen/*\n!.last-seen/README.md\n' > "$SB/.gitignore"
echo "$me" > "$SB/.last-seen/me"

cat > "$SB/README.md" <<'EOR'
# The West Wing (practice game)

Not a real business. A game to learn the moves. Deleted when you're done.
EOR

cat > "$SB/context/operation/pipeline.md" <<EOR
---
owner: chief
updated: $YESTERDAY
last_reviewed_against:
---

# Pipeline — crises

## 1. Assessment
- **Enters:** something has happened. **Leaves:** what we know, what we don't, who's on it.
- **Owner:** chief. **Goes wrong:** acting before anyone has asked "what do we actually know?"

## 2. Options
- **Leaves:** two or three real choices with costs, from the people who'd carry them out.

## 3. Decision
- **Leaves:** one line in decisions.md with the why. **Owner:** the President.

## 4. Execution
- **Leaves:** tasks on the right people's lists, phrased their way; waiting-fors tracked.

## 5. Debrief
- **Leaves:** what didn't match this playbook, written into it.
EOR

cat > "$SB/context/operation/glossary.md" <<EOR
---
owner: chief
updated: $YESTERDAY
---

# Glossary

- **the ship** — 4.2 km long, silent, over the Pacific since 03:40.
- **the Envoy** — whoever is talking to us from the ship. Speaks English. Polite.
- **the Room** — the Situation Room.
- **the 6am** — the morning press briefing. Press needs the line by 05:30.

## People
- chief — Chief of Staff, runs the building.
- general — General Okoro, Joint Chiefs.
- ambassador — Ambassador Reyes, State.
- press — Press Secretary Lin.
EOR

cat > "$SB/people/chief/profile.md" <<'EOR'
---
name: Chief of Staff
role: runs the building
owns: [assessment, the President's time]
availability: always
---

# Chief of Staff

## How I like work handed to me
One line and a deadline. No padding. I'll work out the rest.
EOR
cat > "$SB/people/general/profile.md" <<'EOR'
---
name: General Okoro
role: Joint Chiefs
owns: [options, execution]
availability: always
---

# General Okoro

## How I like work handed to me
Give me the objective and the constraints, not the method. I don't read
long emails. If it's "do not execute", say so in the first five words.
EOR
cat > "$SB/people/ambassador/profile.md" <<'EOR'
---
name: Ambassador Reyes
role: State
owns: [talks, the Envoy]
availability: always
---

# Ambassador Reyes

## How I like work handed to me
Context first: who they are, what they want, what we can give, what we
can't. Then I'll draft the words. Never send me a one-liner.
EOR
cat > "$SB/people/press/profile.md" <<'EOR'
---
name: Press Secretary Lin
role: Press
owns: [the 6am]
availability: 04:00–22:00
---

# Press Secretary Lin

## How I like work handed to me
Tell me what's true and what's embargoed. I need it before 05:30.
EOR
for p in chief general ambassador press; do printf '# Tasks — %s\n\n' "$p" > "$SB/people/$p/tasks.md"; printf '# Inbox — %s\n\n' "$p" > "$SB/people/$p/inbox.md"; done

cat > "$SB/people/$me/profile.md" <<EOR
---
name: $NAME
role: President
owns: [decisions]
availability: 24 hours a day, apparently
---

# $NAME

Sworn in at 04:12. Practice profile.
EOR
printf '# Tasks — %s\n\n- [ ] NASA spectrum analysis of the ship  job:2026-001  from:%s  #waiting\n' "$NAME" "$me" > "$SB/people/$me/tasks.md"
cat > "$SB/people/$me/inbox.md" <<EOR
# Inbox — $NAME

- $TODAY source:cli General Okoro wants a go/no-go on moving the Pacific fleet by tonight
- $TODAY source:cli The Envoy: "We come to trade. Send your best negotiator. We will wait until dawn."
- $TODAY source:cli Congress leader wants a briefing at 09:00 tomorrow
- $TODAY source:cli Press needs one line for the 6am
- $TODAY source:cli NASA: the ship is 4.2 km long and completely silent on all bands
- $TODAY source:cli Idea: return the favour one day and visit their home world
- $TODAY source:cli The Vice President undermined you twice in the Room this morning
EOR

J="$SB/jobs/2026-001-first-contact"
cat > "$J/brief.md" <<EOR
---
job: 2026-001
client: the country
stage: assessment
opened: $TODAY
---

# First Contact

## What happened
A ship appeared over the Pacific at 03:40. At 03:58 it spoke, in English:
"We come to trade." It has asked for our best negotiator and said it will
wait until dawn.

## Why it matters
Nobody knows what it can do. Everybody is watching what you do first.

## Constraints
Dawn is in about six hours. Congress wants a briefing at 09:00. The 6am
needs a line by 05:30.
EOR
cat > "$J/status.md" <<EOR
---
job: 2026-001
stage: assessment
updated: $TODAY
people: [$me, chief, general, ambassador, press]
---

# Status — First Contact

**Stage:** assessment
**Key dates:** dawn ($TOMORROW, ~06:10); Congress 09:00 $TOMORROW
**Who's on it:** everyone

## Right now
Waiting on NASA's spectrum analysis. Nothing has been decided.
EOR
cat > "$J/decisions.md" <<EOR
# Decisions — First Contact

## $TODAY — No first strike without provocation

**Who:** $NAME
**Why:** We know nothing about their capability. Whatever we do first sets
the tone for everything after. The Chief's words: "you can always escalate;
you can't un-escalate."
**Affects:** every option the General brings.
EOR

( cd "$SB" && git init -q -b main && git add -A \
  && git -c user.name="The West Wing" -c user.email="practice@example.invalid" commit -q -m "First Contact: the President is sworn in, the ship is waiting, the inbox is full" \
  && git rev-parse HEAD > ".last-seen/$me" )
echo "JOYRIDE ready at $SB"
