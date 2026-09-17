# Inbox adapters: chat and email

Optional. Last. The system is fully usable without any of these. Chat and
email are **signal sources, not interfaces**: nobody changes how they
message, and nothing is filed silently.

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
