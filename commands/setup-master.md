---
name: setup-master
description: Set up the Finisher master bot in Grok Bot. Runs only when invoked; the plugin does not create bots on install.
---

# Set up the Finisher master bot

Create a master bot named Finisher in Grok Bot that oversees other agents and checks that they hand in finished work.

## Usage

Invoke via `/finish-line:setup-master`.

This command is user-invoked. **Do not run it automatically when the plugin is installed.**

## Workflow

1. Load and follow the `setup-master-bot` skill.
2. Use Grok Bot's (or this app's) create-agent ability to create a bot named **Finisher**.
3. Paste the skill's full master bot system description into the bot's instructions. That text is the same persona as `agents/finisher.md`.
4. Attach the `audit-unfinished-work` and `finish-the-work` skills if the app allows it.
5. Confirm to the user what was created and how to use Finisher. If a click or approval only they can give is required, prepare the configuration and wait for that one confirmation.
6. Be honest about limits: Finisher can review and nudge other bots only where this app supports transcripts and bot-to-bot follow-ups. Hooks in this plugin may not run in every host app.
