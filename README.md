# session-handoff

A Claude Code skill that produces a structured, **chat-only** end-of-session
summary, so you can `/clear` and have a fresh agent pick up exactly where the
last one stopped.

The audience is a future instance of the agent, not a stakeholder. It's a context
artifact, not a status report — terse and concrete, all paths absolute, shell IDs
included, no retrospective, no hype.

Run it when you're **mid-task with a full context window**.

> Its sibling, [`session-end`](https://github.com/Bgfoxx/session-end), is for the
> other moment: the work is actually done and the durable knowledge should be
> written to disk. That one writes files; this one writes nothing. They're
> independent — install either or both.

---

## Install

```sh
git clone https://github.com/Bgfoxx/session-handoff.git ~/.claude/skills/session-handoff
```

Or, for a single project (commit it to share with your team):

```sh
mkdir -p .claude/skills
git clone https://github.com/Bgfoxx/session-handoff.git .claude/skills/session-handoff
```

Or use the installer, which copies just the skill file and skips the repo
metadata:

```sh
git clone https://github.com/Bgfoxx/session-handoff.git && cd session-handoff
./install.sh              # -> ~/.claude/skills/session-handoff
./install.sh --project    # -> ./.claude/skills/session-handoff
```

Start a new Claude Code session and run `/session-handoff` to confirm it
registered. It also triggers on "hand off", "wrap up session", "summarize before
I clear", and near-equivalents.

---

## What it produces

A fixed-structure summary in chat:

```
# Session Handoff — <what this session was about>
*Written: <absolute timestamp>*

## Where it started
## Decisions locked + what shipped
## Key files for next session
## Running state
## Verification — how to confirm things still work
## Deferred + open questions
## Pick up here
```

The structure never varies. Sections with nothing to report say "none" rather
than disappearing — so the next agent can tell the difference between "nothing is
running" and "the handoff forgot to check."

It pulls from plan files, todo state, background shells you started, external
schedulers, the project's own live trackers, files touched this session, memory
written, and questions that never got answered. It explicitly does **not** audit
the filesystem — no `git log`, no `Glob` sweeps. If you didn't touch it this
session, it doesn't belong in the handoff.

---

## Details that make it work

A handoff is easy to write badly. These rules are the difference:

- **Background process IDs are load-bearing.** If the session started a dev
  server with `run_in_background`, its shell ID and kill command must appear —
  the next agent has no other way to find it.
- **Absolute paths only.** The next agent may have a different working directory.
- **Absolute dates only, and the handoff is timestamped.** Every "tomorrow" is
  converted using the session's `currentDate`, because the next agent may read
  this days later, when "tomorrow" is silently wrong.
- **Live trackers outrank the handoff.** A handoff is a frozen snapshot, but the
  world keeps moving — replies land, crons fire, teammates push. If the project
  keeps its own state files, they're named in the summary with an explicit note
  that they win on any conflict.
- **Cross-repo boundaries are flagged.** Conflating two codebases sends the next
  agent editing the wrong one.

---

## Configuration

The skill ends with an **"Adaptation points"** section listing every knob and the
reasoning behind each default. In short:

- **Template sections are fixed on purpose** — that's what makes handoffs
  comparable and makes omissions visible. Add sections if your work needs them,
  but add them to the template rather than leaving it to per-session judgment.
- **Chat-only is load-bearing.** Handoffs written to files go stale and then get
  read as current state. If you want one archived, paste it yourself rather than
  loosening the rule.
- **Point the plan-file bullet** in step 2 at whatever planning system you use,
  if any.
- **Verification commands** come from the project's `CLAUDE.md` and package
  scripts. If your projects share a standard check like `make verify`, name it
  directly in the template line.

---

## License

CC0 / public domain. Take it, fork it, rename it, ship it.
