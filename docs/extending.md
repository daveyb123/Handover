# Extending Handover

The core is deliberately small and deliberately agnostic: markdown, git,
one instruction file, no roles, no classification, no enterprise ecosystem.
That is what lets a three-person studio and a tendering firm run the same
engine. Everything else is an extension, and there are three places one
can plug in without forking.

## 1. Scope packs (`scopes/<name>/`)

A kind of business: a pipeline template, non-job areas, deliverable
templates, a README alias for `jobs/`. Propose one with the scope-pack
issue form, or open a pull request. The interview reads whichever pack
fits and the owner's words override it.

## 2. Adapters (`.agent/adapters.md`)

Signal sources: chat, email, voice, forwarded messages. The rule is fixed
(read-only, narrow scope, propose in the CLI, nothing filed silently); the
connector is whatever your CLI can reach. An adapter contribution is a
markdown file describing one source: what to read, what counts as a
commitment or drift there, and the narrowest access it needs.

## 3. Identity and access, in front of the adapters

Handover's own access model is one line: repository membership is
clearance. It has no roles on purpose. If a business needs its assistant
to reach a CRM, ERP or project system with real per-user permissions, that
belongs in a layer in front of the adapters, not in the core:

- an identity provider (Microsoft Entra, Google Workspace, whatever the
  business already runs) that the person signs in to;
- a policy layer that decides what that person's assistant may call, and
  with what scope;
- adapters that read through that layer, so every request the assistant
  makes carries the user's own authorisation.

The core stays unchanged: what comes back is still proposed as an inbox
item or a context update, confirmed in the CLI, and written as markdown
with the reasoning in the commit. A business that wants this ships it as a
plugin: a folder of adapter files plus whatever setup the identity layer
needs, and a paragraph in `context/operation/glossary.md` under Tools.

## What stays out

Production work. The assistant coordinates and remembers; it does not cut
the film, price the bid, or write the words someone will defend in the
room. An extension that crosses that line is a different product, and
should be.

## Sending it back

If you build any of the three, the useful thing is a pull request to the
template with the pack or adapter file, so every business gets it on their
next upgrade. Forks are welcome too; they just don't come back.
