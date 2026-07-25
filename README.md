# dotfiles

## pi

`pi/settings.json` + `pi/extensions/` - config for [pi](https://pi.dev), the terminal coding agent.

- `compact-mode.ts` - tight one-line rendering for built-in tools (read/bash/edit/write/grep/find/ls), skips the default padded box shell.
- `tighten-prompts.ts` - patches out hardcoded vertical padding around user message boxes (gap in pi's `outputPad`, which is horizontal-only).

`install.sh` symlinks these into `~/.pi/agent/`. Never commit `pi/auth.json` (has raw provider API keys), `pi/trust.json`, `pi/sessions/`, `pi/models-store.json` - all machine-local or secret, blocked by `.gitignore`.
