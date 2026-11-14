# Finish Line

A Cursor-format plugin (the same format Grok Bot plugins use) that pushes AI agents to **hand in finished work** instead of stopping at questions, partial drafts, plans, or "on it" messages.

When details are missing, agents should make reasonable, clearly stated assumptions, deliver a complete best-effort result, and invite you to correct it. They must not send messages, spend money, delete things, or take irreversible actions on assumptions — for those, they prepare everything and ask for one confirmation.

## What it does

- Applies an always-on rule so agents finish the current task in the same turn.
- Adds a `/finish-line:finish` command when you want to force a finished deliverable now.
- Optionally helps you create a master bot named **Finisher** in Grok Bot that reviews other agents, nudges ones that stopped early, and reports finished/unfinished status.
- Includes a Cursor `stop` hook that can ask the agent to continue if the last turn looks unfinished, capped at 2 automatic follow-ups.

## Install

1. Keep this folder as a git repository (it already has an initial commit), or copy `/workspace/finish-line` to a repo you control.
2. In **Grok Bot** or **Cursor**, open the plugin / Customize panel and install from this local folder, or from the git remote if you publish one.
3. Enable the plugin for the workspace or assistant where you want the finishing rules to apply.
4. If you want the Finisher master bot, ask the assistant to set it up or run `/finish-line:setup-master`. Installing the plugin does **not** create that bot by itself.

Host apps differ. Use whatever "install plugin from folder or git repo" flow your app provides.

## Components

| Path | Role |
|------|------|
| `.cursor-plugin/plugin.json` | Plugin manifest (`finish-line` 1.0.0, author Vishnu). |
| `rules/finish-the-work.mdc` | Always-on finishing rules, assumptions, definition of done, partial blockers, and safety exceptions. |
| `skills/finish-the-work/SKILL.md` | Step-by-step workflow: understand, assume, do, self-check, deliver, invite corrections. |
| `skills/setup-master-bot/SKILL.md` | How to create the Finisher bot when you ask — not on install. |
| `skills/audit-unfinished-work/SKILL.md` | How Finisher judges a teammate's last turn and nudges unfinished work. |
| `commands/finish.md` | `/finish-line:finish` — finish the current task now. |
| `commands/setup-master.md` | `/finish-line:setup-master` — create Finisher when invoked. |
| `agents/finisher.md` | Finisher persona / system prompt. |
| `hooks/hooks.json` and `scripts/check-finished.sh` | Cursor `stop` hook. May return a `followup_message` so the agent continues, with `loop_limit` 2. |
| `LICENSE` | MIT. |

## How to use

- Just give the agent a task. The always-on rule should make it finish and list assumptions.
- If a reply still stops early, run `/finish-line:finish` or say "finish it now."
- To add oversight in Grok Bot, run `/finish-line:setup-master` (or ask to set up Finisher), then ask Finisher to check a teammate's work.

## Honest limitations

- **No auto-creation on install.** Plugins cannot silently create bots when they are installed. Finisher is created only when you invoke setup.
- **Hook support is not guaranteed in Grok Bot.** The `stop` hook is a Cursor agent-hook feature: the script reads the stop event, and if the last turn looks unfinished it can return `{ "followup_message": "..." }` so the agent continues, at most twice (`loop_limit`: 2). Other hosts, including Grok Bot, Dots, or Muse, may ignore `hooks/` entirely. Even in Cursor, the hook only inspects a transcript when `transcript_path` or `CURSOR_TRANSCRIPT_PATH` is provided; with no transcript it will not auto-continue a normal completed turn (to avoid nagging). Detection is heuristic, not perfect.
- **Finisher can only oversee teammates where the app allows it** — for example, reading transcripts and sending bot-to-bot follow-ups. If the host cannot do that, Finisher can still review anything you paste, and the always-on rule still applies to agents that load this plugin.
- **Other apps (Dots, Muse, and similar)** get these behaviors only if they load this Cursor plugin format (rules, skills, commands, agents, hooks). The plugin will not rewrite a host that uses a different extension system.
- **This is not a jailbreak around safety.** Outbound messages, spending, deletion, and other irreversible actions still need one explicit confirmation.

## License

MIT. See [LICENSE](LICENSE).
