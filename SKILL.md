---
name: session-handoff
description: Use when the user says "session handoff", "wrap up session", "hand off", "handoff summary", or wants a structured end-of-session summary before clearing context. Produces a chat-only handoff covering decisions, shipped changes, key files, running state, verification steps, deferrals, and open questions so a fresh agent can continue seamlessly.
---

# Session Handoff

Produce a repeatable end-of-session summary so the user can `/clear` and start a
fresh agent without losing continuity. The next agent should be able to pick up
by reading this summary alone.

This is a **context-handoff artifact**, not a status report. The audience is a
future instance of you, not a stakeholder.

It pairs with the `session-end` skill: `session-handoff` when you're clearing
context and continuing, `session-end` when the work is actually done and durable
knowledge needs to be written to disk. This skill writes nothing.

## When to invoke

User says: "session handoff", "wrap up session", "hand off", "handoff summary",
"let's wrap up", "summarize before I clear", or any near-equivalent. Also invoke
proactively if the user says they're about to `/clear` without having run it yet.

## How to produce the summary

1. **Review the full conversation**, not just the last few turns. Handoffs miss
   things when they only summarize recent context.
2. **Pull state from these sources (in order):**
   - Plan files referenced this session — whatever planning system this project
     uses (a `.planning/` directory, `docs/plans/`, ad-hoc plan files under
     `~/.claude/plans/`, or none).
   - Todo-list state — any in-progress or pending tasks.
   - Background processes you started with `run_in_background` — shell IDs are
     load-bearing for the next agent (e.g. a dev server started this session).
   - External schedulers and remote processes the session relied on or
     configured — cron, systemd timers, launchd jobs, cloud scheduled tasks —
     with host and how to inspect them. Only ones known from THIS session's
     context; don't go hunting.
   - The project's own live tracker files, if this session read or wrote them
     (an open-items file, a correspondence log, planning state, README TODOs) —
     these go under "Live trackers" as the authoritative sources that outrank the
     handoff.
   - Files created or modified this session — you know what you touched; don't
     grep to re-discover.
   - Memory written or updated this session, across whichever stores are in use:
     Claude Code's auto-memory files for this project
     (`~/.claude/projects/<project-slug>/memory/`, where `<project-slug>` is the
     absolute working-directory path with `/` and spaces replaced by `-` — note
     any `MEMORY.md` index lines added), plus any memory or knowledge-capture MCP
     tools you actually used this session. Skip the stores this setup doesn't
     have.
   - Unresolved questions — things you asked the user that never got a clear
     answer, or things the user asked that got deflected.
3. **Do NOT audit the filesystem.** This is synthesis of what happened in THIS
   session. No `git log`, no broad `Glob` sweeps. If you didn't touch it this
   session, it doesn't belong here.
4. **Produce the output in chat.** Do not write a file. Do not update memory.
   Chat-only.

## Output template — use exactly this structure, every time

```
# Session Handoff — <one-line title of what this session was about>

*Written: <YYYY-MM-DD HH:MM, from the session context's currentDate — never computed>*

## Where it started
<2-3 sentences: what the user asked for, key framing or constraints that emerged>

## Decisions locked + what shipped
- <decision or change> — <why, and where it lives (absolute path if a file)>
- ...

## Key files for next session
- `<absolute path>` — <why the next agent should read this first>
- Plan file: `<absolute path>` (if a plan drove the session) — or "none"
- Live trackers: <the project's own state files (open-items file, correspondence log, planning state, README TODOs) — name them and state that on any conflict THEY win over this handoff> — or "none"
- Memory touched: `<memory file paths>` + note any knowledge-capture entries (if any) — or "none"

## Running state
- Background processes: <shell IDs + what they are + how to kill> — or "none"
- Dev servers / ports: <url + port> — or "none"
- External schedulers / remote processes: <cron, systemd timers, launchd jobs, cloud scheduled tasks — host + how to inspect> — or "none"
- Open worktrees / branches: <paths> — or "none"

## Verification — how to confirm things still work
- <command from this project's CLAUDE.md / package scripts — e.g. type check, lint, build, test> — <expected outcome>
- <feature-specific command> — <expected outcome>
- ...

## Deferred + open questions
- Deferred: <item> — <why pushed to later>
- Open: <question needing the user's input> — <context>

## Pick up here
<1-2 sentences: the single most likely next action for a fresh agent>
```

## Hard rules

1. **Chat output only.** Never write the handoff to a file. Never update memory
   from this skill.
2. **Never invent state.** If a section has nothing to report, write "none" — do
   not omit the section. Structure stability is the whole point.
3. **Absolute paths always.** The next agent may have a different working
   directory.
4. **If a plan file drove the session, name it first** in "Key files" so the next
   agent reads it before anything else.
5. **No emojis, no hype, no "great job" summaries.** Terse and concrete — paths,
   commands, shell IDs, decisions. Match the tone of a seasoned engineer handing
   off at end-of-shift.
6. **Background process IDs are critical.** If you started any `run_in_background`
   shells, their IDs must appear in "Running state" with the kill command — the
   next agent cannot find them otherwise.
7. **Flag cross-repo and ownership boundaries explicitly.** If the session touched
   or deferred work that belongs to a *different* repo or system, say so plainly
   and name where those edits belong. Conflating two codebases sends the next
   agent editing the wrong one.
8. **Absolute dates only, and stamp the handoff.** Convert every relative date
   ("tomorrow", "next week", "in two days") to an absolute date using the session
   context's `currentDate` — the next agent may read this days later, when
   "tomorrow" is silently wrong. The *Written:* line under the title is mandatory
   for the same reason.
9. **A handoff is a snapshot; the project's live trackers win.** External parties
   keep acting after you write this (replies land, crons fire, teammates push).
   If the project keeps its own live state files, list them under "Live trackers"
   and state that on any conflict those files override this handoff. The next
   agent should re-derive time-sensitive claims from them, not trust the frozen
   summary.

## Anti-patterns — do not do these

- Summarizing the last 3 turns and calling it a handoff.
- Listing files by relative path.
- Skipping the "Running state" section because "nothing is running" — write
  "none" instead.
- Writing the summary to a file. This is chat-only by design.
- Adding a "what went well / what went poorly" retrospective. This isn't a retro.
- Recommending next steps beyond the single "Pick up here" line. The next agent
  decides; you just hand off.

## Adaptation points

Edit these to fit your setup. Everything else works as-is.

1. **Template sections.** The structure is deliberately fixed so handoffs are
   comparable across sessions — that's why empty sections say "none" rather than
   disappearing. Add a section if your work needs one (e.g. "Deploys this
   session", "Open PRs"), but add it to the template rather than leaving it to
   per-session judgment.
2. **Plan file locations (step 2).** Point the first bullet at wherever your
   planning system keeps its files, if you use one.
3. **Verification commands.** The skill pulls these from the project's CLAUDE.md
   and package scripts. If your projects share a standard check (e.g.
   `make verify`), name it directly in the "Verification" template line.
4. **Memory stores (step 2).** Lists Claude Code's file-based auto-memory plus
   whatever memory MCP tools were used. Name your specific store there if you
   want it reported consistently.
5. **Chat-only rule.** Rule 1 is load-bearing: handoffs written to files go stale
   and get mistaken for current state. If you do want them archived, have the
   *user* paste it — don't loosen the rule.
