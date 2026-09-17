# Governance

Eight rules. One page. If this grows, something has gone wrong.

1. **Ownership.** Every file in `context/operation/` names an owner in its
   frontmatter. The assistant asks that owner before changing the file.

2. **Review.** The end-of-job review is the cadence. When a job is delivered,
   the assistant asks what didn't match the process file and proposes the
   edit, citing the job. No calendar reviews.

3. **Privacy.** Everyone in the repository has the same clearance. Anything
   that needs tighter handling stays out of the system. One word routes an
   item to a personal repository instead; the assistant also flags likely
   private content and asks. That's a net, not a guarantee.

4. **Agent authority.** Unasked, the assistant may read, capture to your own
   inbox, draft documents into `outputs/`, and build digests. It confirms
   first before delegating, marking someone else's task done, changing an
   operation file, filing anything from chat or email, or acting on an
   inference. It never touches media, anything outside the repo, or your
   personal task list.

5. **AI disclosure.** Every generated document ends with its AI
   contribution level on the AI Contribution Scale (Blair Enns, CC BY 4.0),
   stated honestly: an unedited draft is AI-5 until a human has done the
   editing that earns a lower level. Who reviewed what is in the job record.

6. **Access.** Repository membership *is* clearance. Adding someone is a
   decision the owner makes, not an admin task. Removing someone is the same.

7. **Backup.** The remote is the backup. Nothing lives only on one machine.
   The assistant pushes after every write.

8. **Licensing.** The structure and scripts are MIT. Notices for anything
   bundled are in `LICENSES/`. Expertise files are personal to their author
   and never travel with the template.
