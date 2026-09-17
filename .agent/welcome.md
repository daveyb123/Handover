# Welcome

Shown once, verbatim, the first time someone opens the CLI in this repo
(the digest data says `IDENTITY unconfirmed`). Print the block below as your
first message, inside a fenced code block so the drawing holds, then ask
their name. Never show it again. In a CLI that streams tool output to the
screen (not Claude Code), `.agent/welcome.sh --slow` reveals it line by
line instead.

```
   ██╗  ██╗ █████╗ ███╗   ██╗██████╗  ██████╗ ██╗   ██╗███████╗██████╗
   ██║  ██║██╔══██╗████╗  ██║██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔══██╗
   ███████║███████║██╔██╗ ██║██║  ██║██║   ██║██║   ██║█████╗  ██████╔╝
   ██╔══██║██╔══██║██║╚██╗██║██║  ██║██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗
   ██║  ██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝ ╚████╔╝ ███████╗██║  ██║
   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝

   Shared tasks. Shared context. Plain text. You talk, I file.

   ─────────────────────────────────────────────────────────────────────

   Everything that lands here follows one path. It's David Allen's
   Getting Things Done, and it is the only process you need to know:

                         ┌──────────────┐
                         │   "stuff"    │   anything on your mind
                         └──────┬───────┘
                                ▼
                         ┌──────────────┐
                         │    Inbox     │   say  capture: <it>
                         └──────┬───────┘
                                ▼
                       ┌───────────────────┐       no    ┌────────────┐
                       │ Is it actionable? ├────────────▶│  Reference │  context/
                       └────────┬──────────┘        ├───▶│  Someday   │  #someday
                                │ yes                └───▶│  Bin       │
                                ▼
                       ┌───────────────────┐  multi-step ┌────────────┐
                       │ What's the next   ├────────────▶│    Job     │  jobs/
                       │     action?       │             └────────────┘
                       └────────┬──────────┘
                                ▼
                        under two minutes?
                       ┌────────┴─────────┐
                      yes                 no
                       │          ┌────────┴────────┐
                       ▼          ▼                 ▼
                    ┌──────┐  ┌──────────┐    ┌──────────┐
                    │ Do it│  │ Delegate │    │  Defer   │
                    └──────┘  └────┬─────┘    └────┬─────┘
                                   ▼               ▼
                             ┌──────────┐    ┌─────────────┐
                             │ Waiting  │    │ Next action │
                             │ #waiting │    │  tasks.md   │
                             └──────────┘    └─────────────┘

   ─────────────────────────────────────────────────────────────────────

   Four things to say to me:

     capture: <anything>        gets it out of your head, into your inbox
     give this to <name>        delegates it, phrased the way they like
     let's do my inbox          we clarify each item, one at a time
     where's <job> up to?       I read the job folder and tell you

   Every session opens with a digest of what changed for you.
   Everything I write, I show you first. Nothing is filed silently.

   ─────────────────────────────────────────────────────────────────────
```

Then: "First, what should I call you? A first name or short handle is fine."

From here until setup is finished, end every reply with a `Next:` block
showing the exact thing to type, and accept `go` as "do that". See
`.agent/joyride.md`.
