# Inbox adapters: chat and email

Optional. Last. The system is fully usable without any of these. Chat and
email are **signal sources, not interfaces**: nobody changes how they
message, and nothing is filed silently.

## Ways in that ship today (no accounts, no admin)

Platform-agnostic on purpose. The one mechanism every platform can reach
is **a synced folder**: iCloud Drive, Google Drive, OneDrive, Dropbox,
whatever the person already has. Inside it, a folder called `Handover`
with a file called `capture.txt`: one line is one thought. Anything that
can append a line to a file, or save a text file into a folder, is a way
in. Everything below is a recipe for that, plus two Apple-specific extras.

**Setting it up (ask first, then pick recipes):** "Which phone: iPhone or
Android? Which computer: Mac or Windows? Which email: Gmail, Outlook or
Apple Mail?" Then `sync.sh drop --suggest` to find the synced folders on
this machine, `sync.sh drop --path "<one of them>/Handover"`, and give the
recipes that match. Always at least one.

| They have | Recipe |
|---|---|
| iPhone | Shortcuts app: **Receive Any input from Share Sheet → Get Text from Input → Append to Text File** `Handover/capture.txt` in iCloud Drive (or the Drive/OneDrive app's folder). Name it "Capture to Handover". Share anything to it. |
| Android | The Google Drive or OneDrive app: share → *Save to Drive* → the `Handover` folder (one file per capture, any name). Or Tasker / Automate: a "share" intent that appends to `Handover/capture.txt`. Or open `capture.txt` in any text editor that syncs and type a line. |
| Any phone, no setup | Open the synced folder in its app and drop a text file, a chat export, a voice-memo transcript. |
| Gmail (any platform) | Forward to yourself with `capture:` in the subject, plus one free IFTTT applet: *Gmail: new email matching search `subject:capture:`* → *Google Drive: append to a text file* `Handover/capture.txt`. Or a Gmail filter that stars it, and the mailbox connector below reads starred. |
| Outlook / Microsoft 365 (any platform) | A personal Power Automate flow (no admin): *When a new email arrives (V3)* with subject filter `capture:` → *Create file* in OneDrive `Handover/`. Or forward with `capture:` and let the desktop Outlook rule move it to a folder the connector reads. |
| Apple Mail (Mac) | `sync.sh mail-rule` installs a script; add the one rule (subject begins with `capture:` → Run AppleScript → Handover Capture). Forward to yourself from anywhere. |
| Apple Reminders (iPhone/Mac/Siri) | `sync.sh reminders on`; a list called **Handover**. "Hey Siri, add … to my Handover list." |
| Windows desktop | A Power Automate Desktop flow, or simply a shortcut to `Handover/capture.txt` on the desktop; one line per thought. |

On "let's do my inbox", `capture.txt` is read line by line and each line
proposed with `source:drop`; when done, `sync.sh drop --clear capture.txt`
empties it (a copy is archived). Other files are proposed whole and moved
to `.done/`.

**Apple Reminders (macOS, iPhone, Siri).** Opt-in: the user says "read my
reminders" once → `sync.sh reminders on`. They make a Reminders list called
**Handover**. From then on, anything on it ("Hey Siri, add ring the venue
to my Handover list") appears in the digest data as `REMINDER <id> <text>`
on every open. In "let's do my inbox", each one is proposed exactly like an
inbox line, with `source:reminders`. When filed or dropped, run
`sync.sh reminders --done <id>` so it disappears from the phone too. The
first read makes macOS ask the user to allow the terminal to control
Reminders; say that's expected, once.

**The drop folder, and the share sheet.** `sync.sh drop` prints the path
(default `.last-seen/drop/`, local, never shared). Any text file put there
is listed as `DROP <file>` on open. Read it, propose captures with
`source:drop`, then `sync.sh drop --clear <file>` (it moves to `.done/`,
nothing is deleted). Binary files are listed but not read; say so.

The phone reaches it through a synced folder. When the user asks to
capture from their phone, set it up with them once:

1. `sync.sh drop --path "~/Library/Mobile Documents/com~apple~CloudDocs/Handover"`
   (iCloud Drive; for Google Drive use its desktop folder instead).
2. On the iPhone, the Shortcuts app: new shortcut, **Receive Any input from
   Share Sheet**, then **Get Text from Input**, then **Append to Text File**
   with the file `Handover/capture-<Current Date>.txt` in iCloud Drive.
   Name it "Capture to Handover". Add it to the share sheet.
3. From then on: share an email, a WhatsApp message, a web page, a voice
   memo transcript, tap "Capture to Handover". It is waiting in the digest
   data on the next open.

Say these three steps in plain words; don't send them to a settings page.
Android: the same shape with Google Drive and any "share to file" app.

**Email, three ways.**

1. *Forward it to yourself, Mac Mail files it.* The user says "set up email
   capture" → `sync.sh mail-rule` installs a script for Apple Mail and
   prints the one rule to add (Settings → Rules → Add Rule: if Subject
   begins with `capture:` → Run AppleScript → Handover Capture). From then
   on, forwarding any email to themselves with `capture:` at the start of
   the subject, from any device, drops it as text into the drop folder the
   next time Mail on the Mac fetches. Say the rule steps in plain words.
2. *Share it from the phone.* Mail → share → "Capture to Handover" (the
   share-sheet shortcut above).
3. *A mailbox connector*, when the CLI has one (an MCP server for Gmail or
   Outlook). The habit is the same: forward to yourself under a label or
   folder called **Handover**. On "check my email", read only that label,
   propose each message as a capture with `source:email`, and archive it
   on yes. Read-only, one mailbox, never the organisation. This is the
   upgrade that needs a login; the first two need nothing.

**WhatsApp.** No usable API. Export the chat (WhatsApp → chat → Export,
without media) into the drop folder. The agent reads it once for
commitments and drift, proposes, and clears it.

## The pattern (same for every source)

1. Read, via whatever connector the CLI has (an MCP server for Slack, Teams,
   Discord, Google Chat, Gmail, Outlook; or an export file the user hands
   you). Read-only. One channel or one mailbox, never the org.
2. Look for two things only:
   - **Commitments.** Someone said they'd do something, or asked someone to.
     "I'll send the deck Friday." "Can you chase the venue?"
   - **Process drift.** Someone described doing a stage differently from
     `context/operation/pipeline.md`. "We skipped the recce this time."
3. Propose, in the CLI, one item at a time:
   > In #northgate yesterday Sam said he'd send the deck Friday. Add to
   > Sam's inbox as a capture? (y / n / make it a task)
4. On yes, write to the right `inbox.md` with `source:chat` or
   `source:email` and the date. On "make it a task", follow the delegation
   flow (confirm-before applies). On no, drop it and don't raise it again.
5. Process drift goes to the file owner's inbox as `source:drift`, citing
   the message, for the next end-of-job review. Never edit an operation
   file from chat.

## Scope, stated to the user before connecting

- Read-only.
- One mailbox or a named list of channels. Never "all channels".
- The assistant reads on request ("check chat") or at session open if the
  user has said "check chat every time I open". Never continuously.
- Nothing from chat or email is written anywhere without a yes in the CLI.
- Connecting Microsoft 365 or Google Workspace needs an admin and a consent
  screen. Say so, say it's optional, and say what the narrowest scope is.

## Voice notes and forwarded messages

If the user pastes or forwards text ("from Jo: …"), treat it as a capture
with `source:forwarded`. Same rule: propose, confirm, file.

## Not yet built

This file describes the behaviour. No connector configuration ships in the
template. When a business wants one, the assistant sets it up in that
business's repo and notes the scope in `context/operation/glossary.md`
under Tools.
