#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# .agent/sync.sh — the only way the agent touches git. Portable: any CLI can
# call it. Claude Code calls it from hooks (see .claude/settings.json).
#
#   sync.sh open [--hook]         pull, absorb hand edits, print digest data
#                                 (--hook: JSON for Claude Code, with a ready line)
#   sync.sh doctor [--fix] [--install]
#                                 check the clone; --fix repairs what is safe;
#                                 --install also installs ripgrep (ask first)
#   sync.sh upgrade [--apply]     preview (default) or apply the latest tagged
#                                 engine release from the template
#   sync.sh reminders [on|off|--done <id>]
#                                 Apple Reminders list "Handover" as captures
#                                 (macOS, opt-in); --done marks one complete
#   sync.sh drop [--clear <file>] [--path <dir>] [--suggest]
#                                 list text files in the drop folder; --path
#                                 points it at a synced folder; --suggest
#                                 lists synced folders found on this machine
#   sync.sh sources               which ways in are set up (reminders, drop
#                                 folder, mail rule); NONE if nothing is
#   sync.sh mail-rule             install the Apple Mail rule script that saves
#                                 "capture:" emails into the drop folder (macOS)
#   sync.sh progress              this person's counts this week (done, cleared, moved)
#   sync.sh friction "<note>"     log a guess or correction for later review
#   sync.sh feedback "<text>"     record feedback and print a prefilled issue link
#   sync.sh nudged                remember that the one-time star/feedback ask was made
#   sync.sh pull [--throttle N] [--quiet]
#                                 pull --rebase; skip if pulled < N seconds ago
#   sync.sh save "<reasoning>" [--private]
#                                 stage everything, commit, push (background)
#   sync.sh stop                  commit anything left unrecorded, push, prime
#   sync.sh prime                 write .last-seen/next.md: what the next turn
#                                 will most likely need (inbox, profiles, jobs)
#   sync.sh prompt                UserPromptSubmit hook: background pull, then
#                                 hand next.md to the model as context
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

# Git. If none works on the PATH (or macOS only has the stub that asks to
# install developer tools), use the copy GitHub Desktop bundles.
git_ok() { git --version >/dev/null 2>&1; }
if ! git_ok && [ "${HANDOVER_NO_BUNDLED_GIT:-0}" != 1 ]; then
  for cand in "/Applications/GitHub Desktop.app/Contents/Resources/app/git/bin" \
              "$HOME/Applications/GitHub Desktop.app/Contents/Resources/app/git/bin" \
              "${LOCALAPPDATA:-$HOME/AppData/Local}/GitHubDesktop/app-"*/resources/app/git/cmd; do
    if [ -x "$cand/git" ] || [ -x "$cand/git.exe" ]; then PATH="$cand:$PATH"; export PATH; break; fi
  done
fi
if ! git_ok && [ "$cmd" != "doctor" ] && [ "$cmd" != "help" ]; then
  if [ "$cmd" = "open" ] && [ "${1:-}" = "--hook" ]; then
    printf '{"systemMessage":"Handover needs Git and it is not installed yet. Type:  set me up  (the assistant installs it)","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"DIGEST me=unknown since=none now=%s\\nNOGIT git is not installed; run sync.sh doctor --install (macOS: developer tools; Windows: winget Git.Git; Linux: apt/dnf), then open again\\nEND"}}\n' "$NOW"
  else
    echo "NOGIT git is not installed; run sync.sh doctor --install (macOS: developer tools; Windows: winget Git.Git; Linux: apt/dnf), then open again"
  fi
  exit 0
fi

# A downloaded ZIP is a folder, not a repository. Say so plainly so the
# agent can fix it (doctor --fix runs git init and a first commit).
if [ ! -d "$ROOT/.git" ] && [ "$cmd" != "doctor" ] && [ "$cmd" != "help" ] && [ "$cmd" != "whoami" ] && [ "$cmd" != "me" ]; then
  if [ "$cmd" = "open" ] && [ "${1:-}" = "--hook" ]; then
    printf '{"systemMessage":"Handover is here but not set up as a repository yet (a downloaded copy). Type:  set me up","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"DIGEST me=unknown since=none now=%s\\nNOTREPO this folder is not a git repository (downloaded ZIP?); run sync.sh doctor --fix to initialise it, then ask for a private remote\\nEND"}}\n' "$NOW"
  else
    echo "NOTREPO this folder is not a git repository (downloaded ZIP?); run sync.sh doctor --fix to initialise it, then ask for a private remote"
  fi
  exit 0
fi

# ---------- helpers ----------------------------------------------------------

g() { git -C "$ROOT" "$@"; }

slugify() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'; }

me() {
  if [ -s "$LS/me" ]; then cat "$LS/me"; return; fi
  local n; n="$(g config user.name 2>/dev/null || true)"
  [ -n "$n" ] && slugify "${n%% *}"
}

private_dir() { local m; m="$(me)"; [ -n "$m" ] && printf '%s/../%s-private' "$ROOT" "$m"; }

has_remote() { git -C "${1:-$ROOT}" remote get-url origin >/dev/null 2>&1; }

stage_text() {
  # Stage markdown and engine files only. Anything else a human dropped in
  # (a PDF, a contract, a .env) is never committed; it is listed instead.
  local dir="${1:-$ROOT}" p specs=(':(glob)**/*.md')
  for p in .agent .claude/settings.json .gitattributes .gitignore .editorconfig LICENSE LICENSES scopes; do [ -e "$dir/$p" ] && specs+=("$p"); done
  git -C "$dir" add -A -- "${specs[@]}" >/dev/null 2>&1
  git -C "$dir" status --porcelain --untracked-files=all | grep '^??' | sed 's/^?? //' | grep -v '^\.last-seen/' || true
}

json_escape() { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' | awk '{printf "%s\\n", $0}'; }

template_web() {
  local f="$here/template-origin" line
  [ -f "$f" ] || return 1
  line="$(grep -v '^#' "$f" | sed '/^[[:space:]]*$/d' | head -1)"
  [ -n "$line" ] && printf 'https://%s' "$line"
}

urlenc() { sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/&/%26/g' -e 's/#/%23/g' -e 's/+/%2B/g' -e 's/"/%22/g' | awk 'NR>1{printf "%%0A"} {printf "%s", $0}'; }

read_reminders() {
  # Uncompleted items in the Reminders list "Handover", one per line:
  # REMINDER <id><tab><text>. macOS only, and only if the user turned it on.
  [ -f "$LS/reminders" ] || return 0
  command -v osascript >/dev/null 2>&1 || { echo "REMINDERS unavailable (not macOS)"; return 0; }
  local out
  out="$(osascript -e 'tell application "Reminders"
    if not (exists list "Handover") then return "NOLIST"
    set o to ""
    repeat with r in (reminders in list "Handover" whose completed is false)
      set o to o & (id of r) & tab & (name of r) & linefeed
    end repeat
    return o
  end tell' 2>&1)" || { echo "REMINDERS unavailable (${out:0:80})"; return 0; }
  case "$out" in
    NOLIST) echo "REMINDERS no list called Handover yet" ;;
    "") echo "REMINDERS 0" ;;
    *) printf '%s\n' "$out" | sed '/^$/d' | sed 's/^/REMINDER /' ;;
  esac
}

drop_dir() { if [ -s "$LS/drop-path" ]; then cat "$LS/drop-path"; else printf '%s/drop' "$LS"; fi; }

list_drop() {
  # Text files dropped into the drop folder by the user, a Shortcut, a
  # mail rule, an export. Listed for the agent to read and propose.
  local d f n=0
  d="$(drop_dir)"
  [ -d "$d" ] || return 0
  for f in "$d"/*; do
    [ -f "$f" ] || continue
    [ -s "$f" ] || continue   # an emptied capture.txt is not news
    n=$((n+1)); echo "DROP $(basename "$f") $(wc -c < "$f" | tr -d ' ') bytes"
  done
  return 0
}

progress_check() {
  # Personal, never comparative: what this person moved this week.
  local m monday base ndone cleared moved
  m="$(me)"; [ -n "$m" ] || return 0
  monday="$(date -v-mon +%F 2>/dev/null || date -d 'last monday' +%F 2>/dev/null)"; [ -n "$monday" ] || return 0
  base="$(g rev-list -1 --before="$monday 00:00" HEAD 2>/dev/null)"
  [ -n "$base" ] || base="$(g rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
  [ -n "$base" ] || return 0
  ndone="$(g diff "$base"..HEAD -- "people/$m/tasks.md" 2>/dev/null | grep -c '^+- \[x\]')"
  cleared="$(g diff "$base"..HEAD -- "people/$m/inbox.md" 2>/dev/null | grep -c '^-- ')"
  moved="$(g log "$base"..HEAD --format=%h -- 'jobs/*/status.md' 2>/dev/null | wc -l | tr -d ' ')"
  [ $((ndone+cleared+moved)) -gt 0 ] && echo "PROGRESS week=$monday done=$ndone cleared=$cleared moved=$moved"
  return 0
}

write_prime() {
  # A snapshot of what the next turn will most likely need, assembled after
  # every reply so the model starts with the reads already done. If the
  # practice game is running, prime from the sandbox instead.
  local src="$ROOT" m out f who
  [ -d "$LS/joyride/.git" ] && src="$LS/joyride"
  m="$(me)"; [ -n "$m" ] || return 0
  [ -n "$(ls -A "$src/people" 2>/dev/null)" ] || return 0
  out="$LS/next.md"
  {
    echo "PRIMED $(date +%FT%H:%M) source=$([ "$src" = "$ROOT" ] && echo repo || echo game)"
    if [ -f "$src/people/$m/inbox.md" ]; then
      echo "## My inbox (first 6)"; grep '^- ' "$src/people/$m/inbox.md" | head -6
    fi
    if [ -f "$src/people/$m/tasks.md" ]; then
      echo "## My open tasks (first 10)"; grep '^- \[ \]' "$src/people/$m/tasks.md" | head -10
    fi
    for f in "$src"/people/*/profile.md; do
      [ -f "$f" ] || continue
      who="$(basename "$(dirname "$f")")"; [ "$who" = "$m" ] && continue; [ "$who" = ".template" ] && continue
      echo "## $who: how they like work handed over"
      awk '/^## How I like work handed to me/{f=1;next} /^## /{f=0} f&&NF' "$f" | head -4
    done
    for f in "$src"/jobs/*/status.md; do
      [ -f "$f" ] || continue
      grep -q "people:.*[^a-z0-9-]$m\([^a-z0-9-]\|$\)" "$f" 2>/dev/null || continue
      echo "## $(basename "$(dirname "$f")")"; grep -E '^\*\*(Stage|Key dates)' "$f"; awk '/^## Right now/{f=1;next} f&&NF' "$f" | head -3
    done
  } | head -120 > "$out"
  return 0
}

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
    local sponsor; sponsor="$(sed -n 's/^github:[[:space:]]*//p' "$ROOT/.github/FUNDING.yml" 2>/dev/null | head -1)"
    echo "NUDGE sessions=$sessions days=$days writes=$writes star=$(template_web) issues=$(template_web)/issues/new${sponsor:+ sponsor=https://github.com/sponsors/$sponsor}"
  fi
}

template_url() {
  local f="$here/template-origin" line
  [ -f "$f" ] || return 1
  line="$(grep -v '^#' "$f" | sed '/^[[:space:]]*$/d' | head -1)"
  [ -n "$line" ] && printf 'https://%s.git' "$line"
}

ENGINE_PATHS=(AGENTS.md CLAUDE.md GEMINI.md README.md GOVERNANCE.md CONTRIBUTING.md CHANGELOG.md SECURITY.md .editorconfig .gitattributes .agent .claude/settings.json scopes tests .github docs)
# .agent/VERSION says which engine release this clone runs; upgrade compares it.

run_doctor() {
  # Prints DOCTOR lines for anything wrong. fix=1 repairs what is safe;
  # install=1 also installs ripgrep (the agent asks before that).
  local fix="${1:-0}" install="${2:-0}" m n=0
  [ -f "$here/template-origin" ] || return 0   # practice sandbox: stay quiet
  if ! git_ok; then
    if [ "$install" = 1 ]; then
      if [ "$(uname)" = "Darwin" ]; then xcode-select --install >/dev/null 2>&1; echo "DOCTOR macOS is asking to install its developer tools (that includes Git): click Install, wait for it to finish, then open again"
      elif command -v winget >/dev/null 2>&1; then winget install -e --id Git.Git >/dev/null 2>&1 && echo "DOCTOR fixed: installed Git (open a new window so it is found)" || echo "DOCTOR could not install Git with winget; https://git-scm.com/download/win"
      elif command -v apt-get >/dev/null 2>&1; then sudo apt-get install -y -q git >/dev/null 2>&1 && echo "DOCTOR fixed: installed Git" || echo "DOCTOR could not install Git"
      elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y -q git >/dev/null 2>&1 && echo "DOCTOR fixed: installed Git" || echo "DOCTOR could not install Git"
      else echo "DOCTOR Git is not installed and no installer was found: https://git-scm.com/downloads"; fi
    else echo "DOCTOR Git is not installed (doctor --install; ask first). GitHub Desktop's own copy is used automatically if that app is installed."; fi
    return 0
  fi
  if [ ! -d "$ROOT/.git" ]; then
    if [ "$fix" = 1 ]; then
      ( cd "$ROOT" && git init -q -b main && git add -A -- ':(glob)**/*.md' .agent .claude .gitattributes .gitignore .editorconfig LICENSE LICENSES scopes tests .github docs 2>/dev/null; git commit -q -m "Handover: initialised from a downloaded copy" ) \
        && echo "DOCTOR fixed: initialised the repository (no remote yet; sync.sh remote <url> when you have one)" \
        || echo "DOCTOR could not initialise the repository (is git installed?)"
    else echo "DOCTOR not a git repository (downloaded ZIP?): doctor --fix initialises it"; fi
    return 0
  fi
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
    if [ "$install" = 1 ]; then
      if command -v brew >/dev/null 2>&1; then brew install -q ripgrep >/dev/null 2>&1
      elif command -v apt-get >/dev/null 2>&1; then sudo apt-get install -y -q ripgrep >/dev/null 2>&1
      elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y -q ripgrep >/dev/null 2>&1
      elif command -v winget >/dev/null 2>&1; then winget install -e --id BurntSushi.ripgrep.MSVC >/dev/null 2>&1; fi
      command -v rg >/dev/null 2>&1 && echo "DOCTOR fixed: installed ripgrep" || echo "DOCTOR ripgrep missing and no package manager could install it (https://github.com/BurntSushi/ripgrep#installation)"
    else echo "DOCTOR ripgrep not installed: search falls back to grep (doctor --install installs it; ask first)"; fi; n=$((n+1))
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
  local dir="$1" b
  has_remote "$dir" || return 0
  if [ "$dir" = "$ROOT" ] && is_template_origin; then return 0; fi
  b="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [ "${HANDOVER_PUSH_FOREGROUND:-0}" = 1 ]; then  # tests only
    git -C "$dir" "${NET_OPTS[@]}" push --quiet -u origin "$b" >/dev/null 2>&1; return 0
  fi
  ( cd "$dir" && nohup git "${NET_OPTS[@]}" push --quiet -u origin "$b" >/dev/null 2>&1 & ) >/dev/null 2>&1
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
  # Text edited outside the agent is kept and labelled. Non-text files are
  # never committed; they are reported. Prints "<count> <skipped...>".
  local skipped n
  skipped="$(stage_text "$ROOT" | tr '\n' ' ')"
  n="$(g diff --cached --name-only | wc -l | tr -d ' ')"
  if [ "${n:-0}" -gt 0 ]; then
    g commit --quiet -m "[unattributed hand edit] $n file(s) changed outside the agent, absorbed on open $TODAY $NOW" >/dev/null 2>&1
  fi
  echo "${n:-0} $skipped"
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
  [ -n "$m" ] || return 0
  local range_base
  if [ "$since" != "none" ] && g rev-parse --verify --quiet "$since" >/dev/null; then
    range="$since..HEAD"; range_base="$since"
  else
    range="--since=7.days"; range_base="$(g rev-list -1 --before='7 days ago' HEAD 2>/dev/null)"
    [ -n "$range_base" ] || range_base="$(g rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
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

  # tasks I handed to others in this range, and what's due today
  local f who n
  for f in "$ROOT"/people/*/tasks.md; do
    who="$(basename "$(dirname "$f")")"; [ "$who" = "$m" ] && continue; [ "$who" = ".template" ] && continue
    n="$(g diff "$range_base" -- "people/$who/tasks.md" 2>/dev/null | grep -c "^+- \[ \].*from:$m\b")"
    [ "${n:-0}" -gt 0 ] && echo "DELEGATED $who $n"
  done
  if [ -f "$tf" ]; then
    n="$(grep -cE "^- \[ \].*due:$TODAY\b" "$tf" 2>/dev/null)"; [ "${n:-0}" -gt 0 ] && echo "DUETODAY $n items"
  fi
  local pd; pd="$(private_dir)"
  if [ -n "$pd" ] && [ -d "$pd/.git" ]; then
    if git -C "$pd" remote get-url origin >/dev/null 2>&1; then echo "PRIVATE ok"; else echo "PRIVATE no-remote"; fi
  else
    echo "PRIVATE absent"
  fi
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
    read -r hn hskip <<<"$(absorb_hand_edits)"
    read -r pstat pn <<<"$(do_pull)"
    # private sibling: pull it too, quietly
    pd="$(private_dir)"
    if [ -n "$pd" ] && [ -d "$pd/.git" ] && git -C "$pd" remote get-url origin >/dev/null 2>&1; then
      git -C "$pd" "${NET_OPTS[@]}" pull --rebase --autostash --quiet >/dev/null 2>&1 || true
    fi
    data="$(print_digest "PULL $pstat $pn new commits" \
      "HANDEDIT $([ "$hn" -gt 0 ] && echo "$hn files committed as unattributed hand edit" || echo none)$([ -n "${hskip:-}" ] && echo "; not committed (not text): $hskip")"
      is_template_origin && echo "REMOTE template-origin (pushes disabled: this clone still points at the public template; set your own remote with sync.sh remote <url>)"
      run_doctor 0 | grep -v 'identity not set'
      read_reminders
      list_drop
      progress_check
      [ -f "$ROOT/context/operation/pipeline.md" ] && [ "$("$0" sources | grep -c '^SOURCE ')" -eq 0 ] && echo "SOURCES NONE"
      nudge_check
      echo END)"
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
    fix=0; install=0
    for a in "$@"; do case "$a" in --fix) fix=1 ;; --install) fix=1; install=1 ;; esac; done
    run_doctor "$fix" "$install"
    ;;

  upgrade)
    apply=0; [ "${1:-}" = "--apply" ] && apply=1
    turl="$(template_url)" || { echo "UPGRADE no template-origin configured" >&2; exit 1; }
    if is_template_origin; then echo "UPGRADE this clone is the template itself; nothing to do"; exit 0; fi
    if [ -n "$(g status --porcelain)" ]; then echo "UPGRADE refused: uncommitted changes; save first"; exit 1; fi
    # Latest tagged release only, never whatever is on main.
    tag="$(g "${NET_OPTS[@]}" ls-remote --tags --refs "$turl" 'v*' 2>/dev/null | sed 's#.*/##' | sort -V | tail -1)"
    [ -n "$tag" ] || { echo "UPGRADE offline, or the template has no release tags"; exit 0; }
    have="$(cat "$here/VERSION" 2>/dev/null || echo 0.0.0)"
    if [ "$(printf '%s\n%s\n' "$have" "${tag#v}" | sort -V | tail -1)" = "$have" ]; then echo "UPGRADE already current (engine $have, latest release $tag)"; exit 0; fi
    if ! g "${NET_OPTS[@]}" fetch --quiet "$turl" "refs/tags/$tag" 2>/dev/null; then echo "UPGRADE offline or template unreachable"; exit 0; fi
    g checkout --quiet FETCH_HEAD -- "${ENGINE_PATHS[@]}" 2>/dev/null
    if g diff --cached --quiet; then echo "UPGRADE already current ($tag)"; exit 0; fi
    changed="$(g diff --cached --name-only | wc -l | tr -d ' ')"
    if [ "$apply" -eq 0 ]; then
      # Gather the report, restore the tree, then print: a closed pipe
      # must never leave the working tree half-upgraded.
      stat="$(g diff --cached --stat | sed 's/^/  /')"
      lines="$(g diff --cached -- CHANGELOG.md | grep '^+[^+]' | sed 's/^+/    /' | head -40)"
      # Restore only paths HEAD knows (git aborts the whole command on an
      # unmatched pathspec), then remove what the preview created.
      known=()
      for ep in "${ENGINE_PATHS[@]}"; do g cat-file -e "HEAD:$ep" 2>/dev/null && known+=("$ep"); done
      g reset --quiet HEAD -- "${ENGINE_PATHS[@]}" 2>/dev/null
      [ "${#known[@]}" -gt 0 ] && g checkout --quiet -- "${known[@]}" 2>/dev/null
      g clean --quiet -fd -- "${ENGINE_PATHS[@]}" 2>/dev/null
      echo "UPGRADE preview: $tag would change $changed engine files (business context untouched):"
      printf '%s\n  Changelog lines added:\n%s\n' "$stat" "$lines"
      echo "UPGRADE run 'sync.sh upgrade --apply' to apply"
      exit 0
    fi
    g commit --quiet -m "Upgraded the Handover engine to $tag: $changed engine files updated, business context untouched"
    bg_push "$ROOT"
    echo "UPGRADE done: $changed files from $tag (see CHANGELOG.md)"
    ;;

  feedback)
    text="${1:-}"; [ -n "$text" ] || { echo "feedback: text required" >&2; exit 1; }
    f="$ROOT/context/feedback.md"
    [ -f "$f" ] || printf '# Feedback\n\nWhat people here said about Handover, and whether it was passed on to the template.\n\n' > "$f"
    printf -- '- %s %s: %s\n' "$TODAY" "$(me)" "$text" >> "$f"
    web="$(template_web)" || { echo "FEEDBACK logged (no template configured)"; exit 0; }
    echo "FEEDBACK logged"
    echo "ISSUE $web/issues/new?template=feedback.yml&title=$(printf '%s' "Feedback: ${text:0:60}" | urlenc)&feedback=$(printf '%s' "$text" | urlenc)"
    echo "STAR $web"
    ;;

  nudged) date +%s > "$LS/nudged"; echo "NUDGED" ;;

  reminders)
    case "${1:-}" in
      on)  mkdir -p "$LS"; date +%s > "$LS/reminders"; echo "REMINDERS on (list \"Handover\" is read on every open)" ;;
      off) rm -f "$LS/reminders"; echo "REMINDERS off" ;;
      --done)
        [ -n "${2:-}" ] || { echo "reminders --done <id>" >&2; exit 1; }
        osascript -e "tell application \"Reminders\" to set completed of (first reminder whose id is \"$2\") to true" >/dev/null 2>&1 && echo "REMINDER done $2" || echo "REMINDER could not mark $2"
        ;;
      *) if [ -f "$LS/reminders" ]; then read_reminders; else echo "REMINDERS off (sync.sh reminders on)"; fi ;;
    esac
    ;;

  drop)
    d="$(drop_dir)"
    case "${1:-}" in
      --clear)
        [ -n "${2:-}" ] || { echo "drop --clear <file>" >&2; exit 1; }
        mkdir -p "$d/.done"
        if [ "$2" = "capture.txt" ]; then
          # The one-line-per-thought file stays in place (phones append to
          # it); archive a copy and empty it.
          cp -f "$d/$2" "$d/.done/$(date +%Y%m%d-%H%M%S)-$2" 2>/dev/null && : > "$d/$2" && echo "DROP cleared $2 (emptied, copy kept)" || echo "DROP no such file $2"
        else
          mv -f "$d/$2" "$d/.done/$(date +%Y%m%d-%H%M%S)-$2" 2>/dev/null && echo "DROP cleared $2" || echo "DROP no such file $2"
        fi
        ;;
      --suggest)
        # Synced folders that exist on this machine, any platform.
        for c in "$HOME/Library/Mobile Documents/com~apple~CloudDocs" "$HOME/OneDrive" "$HOME/OneDrive - "* "$HOME/Google Drive/My Drive" "$HOME/Library/CloudStorage/GoogleDrive-"*/"My Drive" "$HOME/Library/CloudStorage/OneDrive-"* "$HOME/Dropbox" "$HOME/Library/CloudStorage/Dropbox" "$HOME/Nextcloud" "$HOME/Sync"; do
          [ -d "$c" ] && echo "SYNCED $c"
        done
        echo "SUGGEST pick one and run: sync.sh drop --path \"<folder>/Handover\""
        ;;
      --path)
        [ -n "${2:-}" ] || { echo "drop --path <dir>" >&2; exit 1; }
        nd="${2/#\~/$HOME}"; mkdir -p "$nd" 2>/dev/null || { echo "DROP cannot create $nd" >&2; exit 1; }
        printf '%s' "$nd" > "$LS/drop-path"; echo "DROP folder is now $nd"
        ;;
      *) mkdir -p "$d"; list_drop; echo "DROP folder: $d" ;;
    esac
    ;;

  sources)
    n=0
    [ -f "$LS/reminders" ] && { echo "SOURCE reminders on (Reminders list \"Handover\")"; n=$((n+1)); }
    if [ -s "$LS/drop-path" ]; then echo "SOURCE drop folder $(cat "$LS/drop-path") (phone share sheet reaches it)"; n=$((n+1));
    elif [ -d "$LS/drop" ]; then echo "SOURCE drop folder $LS/drop (local only)"; n=$((n+1)); fi
    [ -f "$HOME/Library/Application Scripts/com.apple.mail/Handover Capture.scpt" ] && { echo "SOURCE mail rule installed (forward to yourself with capture:)"; n=$((n+1)); }
    [ "$n" -eq 0 ] && echo "SOURCES NONE (only typing capture: at the CLI)"
    ;;

  mail-rule)
    command -v osacompile >/dev/null 2>&1 || { echo "MAIL-RULE needs macOS Mail"; exit 0; }
    d="$(drop_dir)"; mkdir -p "$d"
    sd="$HOME/Library/Application Scripts/com.apple.mail"; mkdir -p "$sd"
    tmp="$(mktemp).applescript"
    sed "s#DROP_PATH#$d#" "$here/mail-capture.applescript" > "$tmp"
    if osacompile -o "$sd/Handover Capture.scpt" "$tmp" 2>/dev/null; then
      echo "MAIL-RULE installed: $sd/Handover Capture.scpt (saves to $d)"
      echo "MAIL-RULE now in Mail: Settings → Rules → Add Rule: if Any Recipient contains '+handover' (or Subject begins with 'capture:') → Perform 'Run AppleScript' → Handover Capture"
    else echo "MAIL-RULE could not compile the script"; fi
    rm -f "$tmp"
    ;;

  progress) progress_check || true; [ -z "$(progress_check)" ] && echo "PROGRESS nothing recorded yet this week" ;;

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
    if [ -f "$ROOT/.git/index.lock" ] || [ -n "$(g status --porcelain 2>/dev/null)" ]; then
      [ $quiet -eq 1 ] || echo "PULL skipped (a write is in progress)"; exit 0
    fi
    r="$(do_pull)"
    [ $quiet -eq 1 ] || echo "PULL $r new commits, current as of $NOW"
    ;;

  save)
    msg=""; target="$ROOT"
    for a in "$@"; do case "$a" in --private) target="$(private_dir)" ;; *) [ -z "$msg" ] && msg="$a" ;; esac; done
    [ -n "$msg" ] || { echo "save: a reasoning message is required" >&2; exit 1; }
    [ -d "$target/.git" ] || { echo "save: no repo at $target (run private-init?)" >&2; exit 1; }
    skipped="$(stage_text "$target" | tr '\n' ' ')"
    [ -n "$skipped" ] && echo "SAVE not committed (not text): $skipped"
    if git -C "$target" diff --cached --quiet; then echo "SAVE nothing to commit"; exit 0; fi
    git -C "$target" commit --quiet -m "$msg" && echo "SAVE committed: $msg$([ "$target" != "$ROOT" ] && echo ' (private)')"
    if [ "$target" = "$ROOT" ] && is_template_origin; then echo "SAVE not pushed: origin is the public template"; fi
    bg_push "$target"
    ;;

  stop)
    # Safety net at end of turn: anything the agent wrote but didn't save.
    stage_text "$ROOT" >/dev/null
    if ! g diff --cached --quiet; then
      g commit --quiet -m "[agent write, no reasoning recorded] committed at end of turn $TODAY $NOW"
    fi
    bg_push "$ROOT"
    write_prime
    pd="$(private_dir)"
    if [ -n "$pd" ] && [ -d "$pd/.git" ]; then
      stage_text "$pd" >/dev/null
      git -C "$pd" diff --cached --quiet || git -C "$pd" commit --quiet -m "[agent write, no reasoning recorded] $TODAY $NOW"
      bg_push "$pd"
    fi
    ;;

  prime) write_prime && echo "PRIMED $LS/next.md" ;;

  prompt)
    # Runs on every user prompt. Pull in the background (throttled), then
    # hand the primed snapshot to the model if it is fresh.
    ( "$0" pull --throttle 180 --quiet >/dev/null 2>&1 & ) >/dev/null 2>&1
    if [ -s "$LS/next.md" ]; then
      # date -r FILE +%s works on both BSD and GNU date; stat flags do not.
      mtime="$(date -r "$LS/next.md" +%s 2>/dev/null || echo 0)"
      age=$(( $(date +%s) - mtime ))
      if [ "$age" -lt 1800 ]; then
        printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$(json_escape < "$LS/next.md")"
      fi
    fi
    ;;

  push)
    if is_template_origin; then echo "PUSH refused: origin is the public template (sync.sh remote <url>)"; else bg_push "$ROOT"; echo "PUSH started"; fi
    ;;

  remote)
    url="${1:-}"; [ -n "$url" ] || { echo "remote: url required" >&2; exit 1; }
    nu="$(norm_url "$url")"
    if [ -f "$here/template-origin" ] && grep -v '^#' "$here/template-origin" | sed '/^[[:space:]]*$/d' | while read -r l; do [ "$(norm_url "$l")" = "$nu" ] && echo match; done | grep -q match; then
      echo "REMOTE refused: that is the public template"; exit 1
    fi
    if has_remote; then g remote set-url origin "$url"; else g remote add origin "$url"; fi
    b="$(g rev-parse --abbrev-ref HEAD)"
    if g "${NET_OPTS[@]}" push --quiet -u origin "$b" >/dev/null 2>&1; then echo "REMOTE set to $url and pushed"; else echo "REMOTE set to $url; first push failed (check the URL and access)"; fi
    ;;

  seen)
    m="$(me)"; [ -n "$m" ] || exit 0
    g rev-parse HEAD > "$LS/$m" 2>/dev/null; echo "SEEN $(cat "$LS/$m" | cut -c1-7)"
    ;;

  digest) print_digest; echo END ;;

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
    if [ -n "${1:-}" ]; then
      git -C "$pd" remote add origin "$1"
      if git -C "$pd" "${NET_OPTS[@]}" push --quiet -u origin main >/dev/null 2>&1; then echo "PRIVATE created at $pd and pushed"; else echo "PRIVATE created at $pd; first push failed (check the URL and access)"; fi
    else echo "PRIVATE created at $pd, no remote yet (not backed up)"; fi
    ;;

  status)
    b="$(g rev-parse --abbrev-ref HEAD 2>/dev/null)"
    ahead="$(g rev-list --count "origin/$b..HEAD" 2>/dev/null || echo '?')"
    dirty="$(g status --porcelain | wc -l | tr -d ' ')"
    lp="never"
    if [ -s "$LS/last-pull" ]; then lp="$(date -r "$(cat "$LS/last-pull")" +%H:%M 2>/dev/null || date -d "@$(cat "$LS/last-pull")" +%H:%M 2>/dev/null || echo unknown)"; fi
    echo "STATUS branch=$b ahead=$ahead uncommitted=$dirty me=$(me) last-pull=$lp$(is_template_origin && echo ' remote=TEMPLATE(no push)')"
    ;;

  help|*)
    sed -n '3,/^set -u/p' "$0" | grep '^#' | sed 's/^# \{0,1\}//'
    ;;
esac
exit 0
