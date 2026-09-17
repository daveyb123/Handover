#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# .agent/sync.sh — the only way the agent touches git. Portable: any CLI can
# call it. Claude Code calls it from hooks (see .claude/settings.json).
#
#   sync.sh open [--hook]         pull, absorb hand edits, print digest data
#                                 (--hook: JSON for Claude Code, with a ready line)
#   sync.sh doctor [--fix]        check the clone; fix what is safe to fix
#   sync.sh upgrade               pull the latest engine files from the template
#   sync.sh friction "<note>"     log a guess or correction for later review
#   sync.sh feedback "<text>"     record feedback and print a prefilled issue link
#   sync.sh nudged                remember that the one-time star/feedback ask was made
#   sync.sh pull [--throttle N] [--quiet]
#                                 pull --rebase; skip if pulled < N seconds ago
#   sync.sh save "<reasoning>" [--private]
#                                 stage everything, commit, push (background)
#   sync.sh stop                  commit anything left unrecorded, push
#   sync.sh push                  push if ahead (background)
#   sync.sh remote <url>          set this repo's own remote and push to it
#   sync.sh seen                  mark HEAD as shown to this user
#   sync.sh digest                print digest data only (no pull)
#   sync.sh whoami                print this user's slug
#   sync.sh me <slug>             set this user's slug (first run)
#   sync.sh private-init [remote-url]
#                                 create ../<me>-private with the same layout
#   sync.sh status                one-line state
#
# Never blocks on the network for longer than a few seconds. Never prints a
# conflict marker at the user. Exit 0 in every case that isn't a bug.

set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$here/.." && pwd)"
LS="$ROOT/.last-seen"
mkdir -p "$LS"
NET_OPTS=(-c http.lowSpeedLimit=1000 -c http.lowSpeedTime=10)
TODAY="$(date +%F)"
NOW="$(date +%H:%M)"

cmd="${1:-help}"; [ $# -gt 0 ] && shift

# ---------- helpers ----------------------------------------------------------

g() { git -C "$ROOT" "$@"; }

slugify() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'; }

me() {
  if [ -s "$LS/me" ]; then cat "$LS/me"; return; fi
  local n; n="$(g config user.name 2>/dev/null || true)"
  [ -n "$n" ] && slugify "${n%% *}"
}

private_dir() { local m; m="$(me)"; [ -n "$m" ] && printf '%s/../%s-private' "$ROOT" "$m"; }

has_remote() { g remote get-url origin >/dev/null 2>&1; }

json_escape() { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' | awk '{printf "%s\\n", $0}'; }

template_web() {
  local f="$here/template-origin" line
  [ -f "$f" ] || return 1
  line="$(grep -v '^#' "$f" | sed '/^[[:space:]]*$/d' | head -1)"
  [ -n "$line" ] && printf 'https://%s' "$line"
}

urlenc() { sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/&/%26/g' -e 's/#/%23/g' -e 's/+/%2B/g' -e 's/"/%22/g' | awk 'NR>1{printf "%%0A"} {printf "%s", $0}'; }

nudge_check() {
  # Once, after real use: 5+ sessions over 3+ days and 10+ writes by this
  # user, and never before. Prints a NUDGE line when it's time.
  local m first now sessions days writes
  m="$(me)"; [ -n "$m" ] || return 0
  [ -f "$LS/nudged" ] && return 0
  now="$(date +%s)"
  [ -s "$LS/first-open" ] || echo "$now" > "$LS/first-open"
  first="$(cat "$LS/first-open")"
  sessions="$(( $(cat "$LS/sessions" 2>/dev/null || echo 0) + 1 ))"; echo "$sessions" > "$LS/sessions"
  days="$(( (now - first) / 86400 ))"
  writes="$(g log --since="@$first" --format=%h -- people jobs context 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$sessions" -ge 5 ] && [ "$days" -ge 3 ] && [ "$writes" -ge 10 ]; then
    echo "NUDGE sessions=$sessions days=$days writes=$writes star=$(template_web) issues=$(template_web)/issues/new"
  fi
}

template_url() {
  local f="$here/template-origin" line
  [ -f "$f" ] || return 1
  line="$(grep -v '^#' "$f" | sed '/^[[:space:]]*$/d' | head -1)"
  [ -n "$line" ] && printf 'https://%s.git' "$line"
}

ENGINE_PATHS=(AGENTS.md CLAUDE.md GEMINI.md README.md GOVERNANCE.md CONTRIBUTING.md CHANGELOG.md SECURITY.md .editorconfig .gitattributes .agent .claude/settings.json scopes)

run_doctor() {
  # Prints DOCTOR lines for anything wrong. With fix=1, repairs what is safe.
  local fix="${1:-0}" m n=0
  m="$(me)"
  if [ -d "$ROOT/.git/rebase-merge" ] || [ -d "$ROOT/.git/rebase-apply" ]; then
    if [ "$fix" = 1 ]; then g rebase --abort >/dev/null 2>&1 && echo "DOCTOR fixed: aborted a stuck rebase"; else echo "DOCTOR stuck rebase in progress (doctor --fix aborts it)"; fi; n=$((n+1))
  fi
  if [ -f "$ROOT/.git/MERGE_HEAD" ]; then
    if [ "$fix" = 1 ]; then g merge --abort >/dev/null 2>&1 && echo "DOCTOR fixed: aborted a stuck merge"; else echo "DOCTOR stuck merge in progress (doctor --fix aborts it)"; fi; n=$((n+1))
  fi
  if ! has_remote; then echo "DOCTOR no remote: nothing is backed up (sync.sh remote <url>)"; n=$((n+1))
  elif is_template_origin; then echo "DOCTOR origin is the public template: nothing will be pushed (sync.sh remote <url>)"; n=$((n+1)); fi
  if ! command -v rg >/dev/null 2>&1; then
    if [ "$fix" = 1 ] && command -v brew >/dev/null 2>&1; then brew install -q ripgrep >/dev/null 2>&1 && echo "DOCTOR fixed: installed ripgrep" || echo "DOCTOR ripgrep missing and install failed"
    else echo "DOCTOR ripgrep not installed: search falls back to grep (doctor --fix installs it with Homebrew)"; fi; n=$((n+1))
  fi
  [ -s "$LS/me" ] || { echo "DOCTOR identity not set (ask, then sync.sh me <slug>)"; n=$((n+1)); }
  if [ -n "$m" ] && [ -s "$LS/me" ] && [ ! -d "$ROOT/people/$m" ]; then
    if [ "$fix" = 1 ]; then
      mkdir -p "$ROOT/people/$m"
      for t in tasks inbox; do [ -f "$ROOT/people/$m/$t.md" ] || sed "s/<Name>/$m/g" "$ROOT/people/.template/$t.md" > "$ROOT/people/$m/$t.md"; done
      echo "DOCTOR fixed: created people/$m/ (profile interview still needed)"
    else echo "DOCTOR people/$m/ missing (doctor --fix creates it)"; fi; n=$((n+1))
  fi
  [ -f "$ROOT/.claude/settings.json" ] || { echo "DOCTOR .claude/settings.json missing: hooks will not run (sync.sh upgrade restores it)"; n=$((n+1)); }
  [ -f "$ROOT/.gitattributes" ] || { echo "DOCTOR .gitattributes missing: concurrent edits will conflict more (sync.sh upgrade restores it)"; n=$((n+1)); }
  local pd; pd="$(private_dir)"
  if [ -n "$pd" ] && [ -d "$pd/.git" ] && ! git -C "$pd" remote get-url origin >/dev/null 2>&1; then echo "DOCTOR private repo has no remote: not backed up"; n=$((n+1)); fi
  if has_remote && ! is_template_origin; then
    local ahead; ahead="$(g rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)"
    if [ "${ahead:-0}" -gt 3 ]; then
      if [ "$fix" = 1 ]; then bg_push "$ROOT"; echo "DOCTOR fixed: pushing $ahead unpushed commits"; else echo "DOCTOR $ahead commits not pushed (doctor --fix pushes)"; fi; n=$((n+1))
    fi
  fi
  [ "$n" -eq 0 ] && [ "$fix" = 1 ] && echo "DOCTOR ok"
  return 0
}

norm_url() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's#^[a-z]+://##; s#^git@##; s#^[^/]*@##; s#:#/#; s#\.git/?$##; s#/+$##'; }

is_template_origin() {
  # True when origin is the public template. We never push there.
  local url f="$here/template-origin"
  url="$(g remote get-url origin 2>/dev/null)" || return 1
  [ -f "$f" ] || return 1
  url="$(norm_url "$url")"
  grep -v '^#' "$f" | sed '/^[[:space:]]*$/d' | while read -r line; do
    [ "$(norm_url "$line")" = "$url" ] && echo match
  done | grep -q match
}

bg_push() {
  # Push in the background so the conversation never waits on the network.
  local dir="$1"
  has_remote || return 0
  if [ "$dir" = "$ROOT" ] && is_template_origin; then return 0; fi
  ( cd "$dir" && nohup git "${NET_OPTS[@]}" push --quiet >/dev/null 2>&1 & ) >/dev/null 2>&1
}

resolve_union() {
  # Rebase stopped on a conflict. For markdown, keep both sides (line-level
  # union) and continue. Anything else: abort and report.
  local f ok=1
  for f in $(g diff --name-only --diff-filter=U); do
    case "$f" in
      *.md)
        local base ours theirs
        base="$(mktemp)"; ours="$(mktemp)"; theirs="$(mktemp)"
        g show ":1:$f" > "$base" 2>/dev/null || : > "$base"
        g show ":2:$f" > "$ours" 2>/dev/null || : > "$ours"
        g show ":3:$f" > "$theirs" 2>/dev/null || : > "$theirs"
        git merge-file -p --union "$ours" "$base" "$theirs" > "$ROOT/$f" 2>/dev/null
        rm -f "$base" "$ours" "$theirs"
        g add -- "$f"
        ;;
      *) ok=0 ;;
    esac
  done
  if [ $ok -eq 1 ]; then
    GIT_EDITOR=true g rebase --continue >/dev/null 2>&1 && return 0
  fi
  g rebase --abort >/dev/null 2>&1
  return 1
}

do_pull() {
  # Prints one word: ok | offline | no-remote | conflict-resolved | conflict
  # followed by the number of new commits.
  has_remote || { echo "no-remote 0"; return; }
  local before after
  before="$(g rev-parse HEAD 2>/dev/null || echo none)"
  if ! g "${NET_OPTS[@]}" fetch --quiet origin 2>/dev/null; then
    echo "offline 0"; return
  fi
  local branch; branch="$(g rev-parse --abbrev-ref HEAD)"
  if ! g rev-parse --verify --quiet "origin/$branch" >/dev/null; then
    echo "ok 0"; return   # remote has no such branch yet (first push pending)
  fi
  local status="ok"
  if ! g rebase --autostash --quiet "origin/$branch" >/dev/null 2>&1; then
    if resolve_union; then status="conflict-resolved"; else echo "conflict 0"; return; fi
  fi
  after="$(g rev-parse HEAD)"
  local n=0
  [ "$before" != "none" ] && n="$(g rev-list --count "$before..$after" 2>/dev/null || echo 0)"
  date +%s > "$LS/last-pull"
  echo "$status $n"
}

absorb_hand_edits() {
  # Anything uncommitted at open was edited outside the agent. Keep it,
  # label it, move on. Prints the file count.
  local n
  n="$(g status --porcelain --untracked-files=all | grep -vc '^?? .last-seen/' || true)"
  if [ "${n:-0}" -gt 0 ]; then
    g add -A >/dev/null 2>&1
    g commit --quiet -m "[unattributed hand edit] $n file(s) changed outside the agent, absorbed on open $TODAY $NOW" >/dev/null 2>&1
  fi
  echo "${n:-0}"
}

last_commit_for() { g log -1 --format="%h %as %an %s" "$1" -- "$2" 2>/dev/null; }

job_ids_for_me() {
  # Plain grep on purpose: sync.sh must work before ripgrep is installed.
  local m="$1"
  {
    # jobs whose status.md lists me
    grep -lE "^people:.*[^a-z0-9-]$m([^a-z0-9-]|$)" "$ROOT"/jobs/*/status.md 2>/dev/null \
      | sed -E 's#.*/jobs/([^/]+)/status.md#\1#'
    # jobs referenced in my tasks
    grep -oE 'job:[0-9]{4}-[0-9]{3}' "$ROOT/people/$m/tasks.md" 2>/dev/null \
      | sed 's/^job://' | sort -u | while read -r id; do
          for d in "$ROOT/jobs/$id-"*/; do [ -d "$d" ] && basename "$d"; done
        done
  } | sort -u
}

print_digest() {
  # $1, $2: optional PULL and HANDEDIT lines to print after the header.
  local m since range
  m="$(me)"
  since="none"; [ -n "$m" ] && [ -s "$LS/$m" ] && since="$(cat "$LS/$m")"
  echo "DIGEST me=${m:-unknown} since=$since now=$NOW"
  [ -s "$LS/me" ] || echo "IDENTITY unconfirmed guess=${m:-none} (ask the user, then: sync.sh me <slug>)"
  [ -n "${1:-}" ] && echo "$1"
  [ -n "${2:-}" ] && echo "$2"
  [ -n "$m" ] || { echo "END"; return; }
  if [ "$since" != "none" ] && g rev-parse --verify --quiet "$since" >/dev/null; then
    range="$since..HEAD"
  else
    range="--since=7.days"
  fi

  g log "$range" --format="MINE %h %as %an %s" -- "people/$m/" 2>/dev/null || true

  local id
  for id in $(job_ids_for_me "$m"); do
    g log "$range" --format="JOB ${id%%-[a-z]*} %h %as %an %s" -- "jobs/$id/" 2>/dev/null | head -5
  done

  local f
  for f in $(g log "$range" --name-only --format="" -- context/operation/ 2>/dev/null | grep -v '\.gitkeep$' | sort -u); do
    echo "OPS $f $(last_commit_for "$range" "$f")"
  done
  for f in $(g log "$range" --name-only --format="" -- 'people/*/profile.md' 2>/dev/null | grep -v '/\.template/' | sort -u); do
    echo "PEOPLE $(basename "$(dirname "$f")") $(last_commit_for "$range" "$f")"
  done

  # waiting-for and overdue, from my open tasks
  local tf="$ROOT/people/$m/tasks.md"
  if [ -f "$tf" ]; then
    local w oldest
    w="$(grep -cE '^- \[ \].*#waiting' "$tf" 2>/dev/null)"; w="${w:-0}"
    oldest=""
    if [ "${w:-0}" -gt 0 ]; then
      oldest="$(g blame --line-porcelain -- "people/$m/tasks.md" 2>/dev/null \
        | awk '/^author-time /{t=$2} /^\t- \[ \].*#waiting/{print t}' | sort -n | head -1)"
      [ -n "$oldest" ] && oldest="$(date -r "$oldest" +%F 2>/dev/null || date -d "@$oldest" +%F 2>/dev/null)"
    fi
    echo "WAITING ${w:-0} items, oldest ${oldest:-n/a}"
    local od
    od="$(grep -E '^- \[ \].*due:[0-9]{4}-[0-9]{2}-[0-9]{2}' "$tf" 2>/dev/null | sed -E 's/.*due:([0-9-]{10}).*/\1/' | awk -v t="$TODAY" '$0 < t' | wc -l | tr -d ' ')"
    echo "OVERDUE ${od:-0} items"
  fi

  local pd; pd="$(private_dir)"
  if [ -n "$pd" ] && [ -d "$pd/.git" ]; then
    if git -C "$pd" remote get-url origin >/dev/null 2>&1; then echo "PRIVATE ok"; else echo "PRIVATE no-remote"; fi
  else
    echo "PRIVATE absent"
  fi
  echo "END"
}

# ---------- commands ---------------------------------------------------------

case "$cmd" in
  whoami) me ;;

  me)
    [ -n "${1:-}" ] || { echo "me: slug required" >&2; exit 1; }
    slugify "$1" > "$LS/me"; echo "IDENTITY set to $(cat "$LS/me")"
    ;;

  open)
    hook=0; [ "${1:-}" = "--hook" ] && hook=1
    read -r pstat pn <<<"$(do_pull)"
    hn="$(absorb_hand_edits)"
    # private sibling: pull it too, quietly
    pd="$(private_dir)"
    if [ -n "$pd" ] && [ -d "$pd/.git" ] && git -C "$pd" remote get-url origin >/dev/null 2>&1; then
      git -C "$pd" "${NET_OPTS[@]}" pull --rebase --autostash --quiet >/dev/null 2>&1 || true
    fi
    data="$(print_digest "PULL $pstat $pn new commits" \
      "HANDEDIT $([ "$hn" -gt 0 ] && echo "$hn files committed as unattributed hand edit" || echo none)"
      is_template_origin && echo "REMOTE template-origin (pushes disabled: this clone still points at the public template; set your own remote with sync.sh remote <url>)"
      run_doctor 0 | grep -v 'identity not set'
      nudge_check)"
    if [ "$hook" -eq 0 ]; then printf '%s\n' "$data"; exit 0; fi
    # Claude Code hook: a line the user sees, plus the data as context.
    if ! [ -s "$LS/me" ]; then ready="Handover is ready. First time here? Type:  set me up"
    elif [ ! -f "$ROOT/context/operation/pipeline.md" ]; then ready="Handover is ready. Setup isn't finished. Type:  set me up"
    else ready="Handover is current as of $NOW. Type anything to see your digest, e.g.:  digest"; fi
    is_template_origin && ready="$ready  ·  This clone points at the public template: nothing is pushed until you set your own remote."
    printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
      "$(printf '%s' "$ready" | json_escape | sed 's/\\n$//')" "$(printf '%s\n' "$data" | json_escape)"
    ;;

  doctor)
    fix=0; [ "${1:-}" = "--fix" ] && fix=1
    run_doctor "$fix"
    ;;

  upgrade)
    turl="$(template_url)" || { echo "UPGRADE no template-origin configured" >&2; exit 1; }
    if is_template_origin; then echo "UPGRADE this clone is the template itself; nothing to do"; exit 0; fi
    if ! g "${NET_OPTS[@]}" fetch --quiet "$turl" main 2>/dev/null; then echo "UPGRADE offline or template unreachable"; exit 0; fi
    new="$(g rev-parse --short FETCH_HEAD)"
    g checkout --quiet FETCH_HEAD -- "${ENGINE_PATHS[@]}" 2>/dev/null
    if g diff --cached --quiet; then echo "UPGRADE already current (template $new)"; exit 0; fi
    changed="$(g diff --cached --name-only | wc -l | tr -d ' ')"
    g commit --quiet -m "Upgraded the Handover engine to template $new: $changed engine files updated, business context untouched"
    bg_push "$ROOT"
    echo "UPGRADE done: $changed files from template $new (see CHANGELOG.md)"
    ;;

  feedback)
    text="${1:-}"; [ -n "$text" ] || { echo "feedback: text required" >&2; exit 1; }
    f="$ROOT/context/feedback.md"
    [ -f "$f" ] || printf '# Feedback\n\nWhat people here said about Handover, and whether it was passed on to the template.\n\n' > "$f"
    printf -- '- %s %s: %s\n' "$TODAY" "$(me)" "$text" >> "$f"
    web="$(template_web)" || { echo "FEEDBACK logged (no template configured)"; exit 0; }
    echo "FEEDBACK logged"
    echo "ISSUE $web/issues/new?title=$(printf '%s' "Feedback: ${text:0:60}" | urlenc)&body=$(printf '%s\n\n(sent from a Handover business repo, business details removed)' "$text" | urlenc)"
    echo "STAR $web"
    ;;

  nudged) date +%s > "$LS/nudged"; echo "NUDGED" ;;

  friction)
    note="${1:-}"; [ -n "$note" ] || { echo "friction: note required" >&2; exit 1; }
    f="$ROOT/context/friction.md"
    [ -f "$f" ] || printf '# Friction log\n\nMoments the assistant had to guess, or was corrected. Reviewed in the divergence report; the best ones become template improvements.\n\n' > "$f"
    printf -- '- %s %s: %s\n' "$TODAY" "$(me)" "$note" >> "$f"
    echo "FRICTION logged"
    ;;

  pull)
    throttle=0; quiet=0
    while [ $# -gt 0 ]; do
      case "$1" in --throttle) throttle="$2"; shift 2 ;; --quiet) quiet=1; shift ;; *) shift ;; esac
    done
    if [ "$throttle" -gt 0 ] && [ -s "$LS/last-pull" ]; then
      last="$(cat "$LS/last-pull")"; now="$(date +%s)"
      if [ $((now - last)) -lt "$throttle" ]; then [ $quiet -eq 1 ] || echo "PULL skipped (pulled $((now - last))s ago)"; exit 0; fi
    fi
    r="$(do_pull)"
    [ $quiet -eq 1 ] || echo "PULL $r new commits, current as of $NOW"
    ;;

  save)
    msg="${1:-}"; [ $# -gt 0 ] && shift
    target="$ROOT"
    [ "${1:-}" = "--private" ] && target="$(private_dir)"
    [ -n "$msg" ] || { echo "save: a reasoning message is required" >&2; exit 1; }
    [ -d "$target/.git" ] || { echo "save: no repo at $target (run private-init?)" >&2; exit 1; }
    git -C "$target" add -A >/dev/null 2>&1
    if git -C "$target" diff --cached --quiet; then echo "SAVE nothing to commit"; exit 0; fi
    git -C "$target" commit --quiet -m "$msg" && echo "SAVE committed: $msg"
    if [ "$target" = "$ROOT" ] && is_template_origin; then echo "SAVE not pushed: origin is the public template"; fi
    bg_push "$target"
    ;;

  stop)
    # Safety net at end of turn: anything the agent wrote but didn't save.
    g add -A >/dev/null 2>&1
    if ! g diff --cached --quiet; then
      g commit --quiet -m "[agent write, no reasoning recorded] committed at end of turn $TODAY $NOW"
    fi
    bg_push "$ROOT"
    pd="$(private_dir)"
    if [ -n "$pd" ] && [ -d "$pd/.git" ]; then
      git -C "$pd" add -A >/dev/null 2>&1
      git -C "$pd" diff --cached --quiet || git -C "$pd" commit --quiet -m "[agent write, no reasoning recorded] $TODAY $NOW"
      bg_push "$pd"
    fi
    ;;

  push)
    if is_template_origin; then echo "PUSH refused: origin is the public template (sync.sh remote <url>)"; else bg_push "$ROOT"; echo "PUSH started"; fi
    ;;

  remote)
    url="${1:-}"; [ -n "$url" ] || { echo "remote: url required" >&2; exit 1; }
    if has_remote; then g remote set-url origin "$url"; else g remote add origin "$url"; fi
    if is_template_origin; then echo "REMOTE refused: that is the public template"; exit 1; fi
    b="$(g rev-parse --abbrev-ref HEAD)"
    if g "${NET_OPTS[@]}" push --quiet -u origin "$b" >/dev/null 2>&1; then echo "REMOTE set to $url and pushed"; else echo "REMOTE set to $url; first push failed (check the URL and access)"; fi
    ;;

  seen)
    m="$(me)"; [ -n "$m" ] || exit 0
    g rev-parse HEAD > "$LS/$m" 2>/dev/null; echo "SEEN $(cat "$LS/$m" | cut -c1-7)"
    ;;

  digest) print_digest ;;

  private-init)
    m="$(me)"; [ -n "$m" ] || { echo "private-init: no identity yet" >&2; exit 1; }
    pd="$(private_dir)"
    if [ -d "$pd/.git" ]; then echo "PRIVATE exists at $pd"; exit 0; fi
    mkdir -p "$pd/people/$m" "$pd/jobs" "$pd/context/operation"
    cp "$ROOT/.gitignore" "$pd/.gitignore"; cp "$ROOT/.gitattributes" "$pd/.gitattributes"
    printf '# %s — private\n\nPersonal repo. Same layout as the shared one. Only %s reads this.\n' "$m" "$m" > "$pd/README.md"
    if [ -f "$ROOT/people/.template/tasks.md" ]; then
      sed "s/<Name>/$m/g" "$ROOT/people/.template/tasks.md" > "$pd/people/$m/tasks.md"
      sed "s/<Name>/$m/g" "$ROOT/people/.template/inbox.md" > "$pd/people/$m/inbox.md"
    else
      printf '# Tasks — %s (private)\n' "$m" > "$pd/people/$m/tasks.md"
      printf '# Inbox — %s (private)\n' "$m" > "$pd/people/$m/inbox.md"
    fi
    git -C "$pd" init -q -b main && git -C "$pd" add -A && git -C "$pd" commit -q -m "Private repo for $m, created by the agent"
    if [ -n "${1:-}" ]; then git -C "$pd" remote add origin "$1" && bg_push "$pd"; echo "PRIVATE created at $pd with remote"; else echo "PRIVATE created at $pd, no remote yet (not backed up)"; fi
    ;;

  status)
    b="$(g rev-parse --abbrev-ref HEAD 2>/dev/null)"
    ahead="$(g rev-list --count "origin/$b..HEAD" 2>/dev/null || echo '?')"
    dirty="$(g status --porcelain | wc -l | tr -d ' ')"
    echo "STATUS branch=$b ahead=$ahead uncommitted=$dirty me=$(me) last-pull=$([ -s "$LS/last-pull" ] && date -r "$(cat "$LS/last-pull")" +%H:%M || echo never)$(is_template_origin && echo ' remote=TEMPLATE(no push)')"
    ;;

  help|*)
    sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'
    ;;
esac
exit 0
