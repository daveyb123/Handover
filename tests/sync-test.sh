#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# shellcheck disable=SC2034  # variables are read inside eval strings in check()
# End-to-end tests for .agent/sync.sh and .agent/joyride.sh, run against a
# checkout of this repository. Portable: Linux and macOS. No network.
#
#   tests/sync-test.sh            run everything; non-zero exit on failure
set -u
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.invalid GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.invalid
export HANDOVER_PUSH_FOREGROUND=1
fails=0
ok()   { printf 'ok   %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; fails=$((fails+1)); }
check() { if eval "$2"; then ok "$1"; else fail "$1"; fi; }

# --- fixtures: a bare remote and two clones with the working-tree engine ---
# The seed is built from the working tree, not a clone: on CI the checkout
# is a detached HEAD and cloning it gives an empty tree.
git init -q --bare -b main "$T/remote.git"
git init -q --bare -b main "$T/priv.git"
mkdir -p "$T/seed"
( cd "$REPO" && git ls-files -z | tar --null -T - -cf - ) | ( cd "$T/seed" && tar -xf - )
cp -R "$REPO/.agent/." "$T/seed/.agent/"   # working-tree engine, even if uncommitted
rm -rf "$T/seed/.last-seen"; mkdir -p "$T/seed/.last-seen"
( cd "$T/seed" && git init -q -b main && git add -A && git commit -q -m "seed" && git remote add origin "$T/remote.git" && git push -q -u origin main )
git clone -q "$T/remote.git" "$T/a"; git clone -q "$T/remote.git" "$T/b"
A="$T/a/.agent/sync.sh"; B="$T/b/.agent/sync.sh"
(cd "$T/a" && $A me alex >/dev/null); (cd "$T/b" && $B me sam >/dev/null)
mkdir -p "$T/a/people/alex" "$T/a/jobs/2026-001-test"
printf '# Tasks — alex\n\n- [ ] Waiting on client  job:2026-001  from:alex  #waiting\n- [ ] Overdue thing  job:2026-001  from:alex  due:2000-01-01  #call\n' > "$T/a/people/alex/tasks.md"
printf -- '---\njob: 2026-001\nstage: edit\npeople: [alex, sam]\n---\n# Status\nStage: edit\n' > "$T/a/jobs/2026-001-test/status.md"
(cd "$T/a" && $A save "alex set up" >/dev/null)

# --- 1. digest data: JOB, WAITING, OVERDUE, valid hook JSON ---
(cd "$T/b" && $B open >/dev/null)
out="$(cd "$T/a" && $A open)"
check "digest lists the job"            "grep -q '^JOB 2026-001' <<<\"\$out\""
check "digest counts waiting"           "grep -q '^WAITING 1 ' <<<\"\$out\""
check "digest counts overdue"           "grep -q '^OVERDUE 1 ' <<<\"\$out\""
hook="$(cd "$T/a" && $A open --hook)"
check "hook output is valid JSON"       "python3 -c 'import json,sys; d=json.loads(sys.argv[1]); assert \"systemMessage\" in d and \"additionalContext\" in d[\"hookSpecificOutput\"]' \"\$hook\""

# --- 2. concurrent appends to one tasks file: union merge, both kept ---
printf -- '- [ ] From alex  job:2026-001  from:alex  #call\n' >> "$T/a/people/alex/tasks.md"
(cd "$T/a" && $A save "alex appended" >/dev/null)
printf -- '- [ ] From sam  job:2026-001  from:sam  #email\n' >> "$T/b/people/alex/tasks.md"
(cd "$T/b" && $B save "sam appended" >/dev/null)
out="$(cd "$T/b" && $B open)"
check "concurrent appends pull cleanly" "grep -qE '^PULL (ok|conflict-resolved)' <<<\"\$out\""
check "both appended lines survive"     "grep -q 'From alex' \"$T/b/people/alex/tasks.md\" && grep -q 'From sam' \"$T/b/people/alex/tasks.md\""
(cd "$T/b" && $B push >/dev/null)

# --- 3. same-line conflict in a non-union file: resolved, both kept ---
(cd "$T/a" && $A pull >/dev/null)
python3 - "$T/a/jobs/2026-001-test/status.md" <<'PY'
import sys; p=sys.argv[1]; s=open(p).read().replace('Stage: edit','Stage: review 1'); open(p,'w').write(s)
PY
(cd "$T/a" && $A save "review 1" >/dev/null)
python3 - "$T/b/jobs/2026-001-test/status.md" <<'PY'
import sys; p=sys.argv[1]; s=open(p).read().replace('Stage: edit','Stage: review 2'); open(p,'w').write(s)
PY
(cd "$T/b" && $B save "review 2" >/dev/null)
out="$(cd "$T/b" && $B open)"
check "same-line conflict is resolved"  "grep -q '^PULL conflict-resolved' <<<\"\$out\""
check "both conflicting lines kept"     "grep -q 'review 1' \"$T/b/jobs/2026-001-test/status.md\" && grep -q 'review 2' \"$T/b/jobs/2026-001-test/status.md\""
check "no conflict markers left"        "! grep -q '^<<<<<<<' \"$T/b/jobs/2026-001-test/status.md\""

# --- 4. hand edits absorbed; non-text never committed ---
printf -- '- hand note\n' >> "$T/a/people/alex/tasks.md"
printf 'PDF' > "$T/a/jobs/contract.pdf"; printf 'SECRET=1\n' > "$T/a/.env"
out="$(cd "$T/a" && $A open)"
check "hand edit absorbed on open"      "grep -q '^HANDEDIT 1 ' <<<\"\$out\""
check "non-text reported, not absorbed" "grep -q 'contract.pdf' <<<\"\$out\""
check "non-text never tracked"          "! (cd \"$T/a\" && git ls-files | grep -qE 'contract.pdf|\\.env$')"
rm -f "$T/a/jobs/contract.pdf" "$T/a/.env"

# --- 5. private repo: both argument orders, never in the shared log ---
(cd "$T/a" && $A private-init "$T/priv.git" >/dev/null)
printf -- '- [ ] secret A  #private\n' >> "$T/alex-private/people/alex/tasks.md"
(cd "$T/a" && $A save --private "secret A" >/dev/null)
printf -- '- [ ] secret B  #private\n' >> "$T/alex-private/people/alex/tasks.md"
(cd "$T/a" && $A save "secret B" --private >/dev/null)
check "private saves land in private repo"   "[ \"\$(git -C \"$T/alex-private\" log --oneline | grep -c secret)\" = 2 ]"
check "private saves absent from shared log" "[ \"\$(git -C \"$T/a\" log --all --oneline | grep -c secret)\" = 0 ]"
check "private first push set upstream"      "git -C \"$T/alex-private\" rev-parse --verify -q origin/main >/dev/null"

# --- 6. pull skips during a write; stop commits stragglers ---
printf -- 'x\n' >> "$T/a/people/alex/tasks.md"
check "pull skips while tree is dirty"  "(cd \"$T/a\" && $A pull) | grep -q 'skipped'"
(cd "$T/a" && $A stop)
check "stop commits unrecorded writes"  "[ -z \"\$(cd \"$T/a\" && git status --porcelain)\" ]"

# --- 7. template guard ---
(cd "$T/b" && git remote set-url origin https://github.com/daveyb123/Handover.git)
printf -- '- probe\n' >> "$T/b/people/alex/tasks.md"
out="$(cd "$T/b" && $B save "probe")"
check "save refuses to push to template" "grep -q 'not pushed' <<<\"\$out\""
check "open reports template origin"     "(cd \"$T/b\" && $B open) | grep -q '^REMOTE template-origin'"
check "remote refuses the template URL"  "(cd \"$T/b\" && $B remote https://github.com/daveyb123/handover) | grep -q refused"
check "upgrade is a no-op on the template" "(cd \"$T/b\" && $B upgrade) | grep -q 'template itself'"

# --- 8. drop folder and reminders switch ---
(cd "$T/a" && $A drop >/dev/null); printf 'Sam: deck by Friday\n' > "$T/a/.last-seen/drop/chat.txt"
check "drop file listed on open"        "(cd \"$T/a\" && $A open) | grep -q '^DROP chat.txt'"
check "drop --clear archives the file"  "(cd \"$T/a\" && $A drop --clear chat.txt) | grep -q cleared && [ ! -f \"$T/a/.last-seen/drop/chat.txt\" ] && ls \"$T/a/.last-seen/drop/.done\" | grep -q chat.txt"
check "reminders off by default"        "(cd \"$T/a\" && $A reminders) | grep -q 'REMINDERS off'"
(cd "$T/a" && $A drop --path "$T/synced" >/dev/null); printf 'shared from phone\n' > "$T/synced/capture-1.txt"
check "drop --path relocates the folder" "(cd \"$T/a\" && $A open) | grep -q '^DROP capture-1.txt'"

# --- 9. joyride sandbox ---
(cd "$T/a" && .agent/joyride.sh start alex >/dev/null)
SB="$T/a/.last-seen/joyride"
due="$(grep -o 'due:[0-9-]*' "$SB/people/sam/tasks.md" | head -1 | cut -d: -f2)"
dow="$(date -j -f %F "$due" +%u 2>/dev/null || date -d "$due" +%u)"
check "joyride due date is Mon–Thu"     "[ \"$dow\" -ge 1 ] && [ \"$dow\" -le 4 ]"
check "joyride sandbox doctor is quiet" "! (cd \"$SB\" && .agent/sync.sh open | grep -q '^DOCTOR')"
check "joyride digest covers practice"  "(cd \"$SB\" && printf -- '- x\n' >> people/alex/inbox.md && .agent/sync.sh save practice >/dev/null && .agent/sync.sh open | grep -q '^MINE')"
(cd "$T/a" && .agent/joyride.sh clean >/dev/null)
check "joyride clean removes sandbox"   "[ ! -d \"$SB\" ]"

echo; if [ "$fails" -eq 0 ]; then echo "all tests passed"; else
  echo "$fails test(s) failed"; echo "--- environment"; uname -a; git --version; bash --version | head -1
  echo "--- clone a"; find "$T/a" -maxdepth 1 -mindepth 1 2>/dev/null | sed "s#.*/##" | tr "\\n" " "; echo; git -C "$T/a" log --oneline 2>/dev/null | head -5
  exit 1; fi
