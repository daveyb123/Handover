# Art: small pictures for big moments

An engagement tool, used sparingly. Text art drawn freehand looks broken;
these are copied **verbatim**, inside a fenced code block, at the moments
listed. Rules:

- One picture per reply, at most. Never two.
- Only at the moments below (or a scope pack's own `art.md`). Not on
  routine turns, never on a capture, never in a digest that has nothing
  new.
- Never inside a generated document in `outputs/`, never in a commit
  message, never in the shared files. Conversation only.
- If the user says "no pictures" (or similar), write `.last-seen/no-art`
  and stop for good. Check for that file before showing any.
- Keep the name substitutions (`<NAME>`, `<job>`, `<n>`) real.

## The game (First Contact)

**Scene 0, after the backstory block:**
```
         .   *      .        .     *
      .       __--"""""""--__        .
         _--""   _________   ""--_
        (      /  ◉  ◉  ◉  \      )     4.2 km. silent.
   .     ""--_\___________/_--""
              |   |  |  |   |          .
   ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  the Pacific
```

**Scene 1, the red phone:**
```
      _______
     /       \    RING.
    |    ☎    |   RING.
     \_______/    04:14
```

**Scene 2, opening the inbox (n = items left):**
```
   ┌────────────────┐
   │  INBOX   ( 8 ) │
   │  ▓▓▓▓▓▓▓▓░░░░  │
   └────────────────┘
```

**Scene 3, when they choose the General:**
```
      _____
     |★   ★|    GENERAL OKORO
     |_____|    "Objective. Constraints.
     /|===|\     Don't tell me how."
```

**Scene 3, when they choose the Ambassador:**
```
      _____
     |~   ~|    AMBASSADOR REYES
     |_____|    "Context first.
     /|◇◇◇|\     Then the words."
```

**Scene 4, the morning briefing:**
```
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          \    |    /      05:58
      -- --  ( ☀ )  -- --
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          the beach at Hanalei
```

**Scene 4, consequence, General first:**
```
         __--"""""""--__
      _--""   x  x  x   ""--_
     (        x  x  x        )    04:31. dark.
      ""--__           __--""
            ""-------""
```

**Scene 4, consequence, Ambassador first:**
```
     ♪    ♫    ♪    ♫    ♪
       they brought music
     ♫    ♪    ♫    ♪    ♫
```

**Scene 5, the review:**
```
        _____
       /     \       <n> / 7
      |  ★★★  |
       \_____/       THE <LEADER TYPE>
          |
        __|__
```

**The President, once, when you first use their name in Scene 0:**
```
       _____
      | o o |    PRESIDENT <NAME>
      |  ‿  |    sworn in at 04:12
     /|=====|\   in a corridor
```

## The real system

**Inbox reaches zero** (end of an inbox pass, only if it started non-empty):
```
   ┌────────────────┐
   │  INBOX   ( 0 ) │   ✓ clear
   │  ░░░░░░░░░░░░  │
   └────────────────┘
```

**Their first delegation ever** (first `from:<me>` line on someone else's list):
```
           __
      ____/  \_____     handed over,
     /  ______/         with the why attached.
     \_/
```

**A job reaches its final stage** (delivered / awarded / archived):
```
    _____________
    \           /    DELIVERED
     \         /     <job>
      \_______/
         | |
        _|_|_
```

**A private note is routed** (first time only):
```
      ______
     |      |
    [|  ●   |]    private repo. only you.
     |______|
```

**Something is overdue** (first digest that shows it, not every day):
```
     (( ! ))    <n> overdue.
      \___/     dead, or stuck? worth a look.
```

**Someone new joins the repo** (their first digest mentions them):
```
     \o/     <name> has joined.
      |      say hello in their language: see people/<slug>/profile.md
     / \
```

**A sync conflict was resolved** (the digest's one sentence about it):
```
    ⟷   two edits, one file. both kept.
```

**Offline** (digest shows local state):
```
      .-~~~-.
     (  x    )    offline. showing what's here.
      `-___-'
```

**End-of-job review done** (after the pipeline edit is saved):
```
     ______
    |      |    the pipeline just got truer.
    |  ==  |    citing <job>.
    |______|
```

## Scope packs

A pack may ship `scopes/<pack>/art.md` with its own moments (a
clapperboard on shoot day; a trophy on award). Same rules.
