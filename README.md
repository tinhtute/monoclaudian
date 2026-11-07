# monoclaudian

Claude Code–specific setup for a new machine: global `CLAUDE.md`, rules, the `settings.json` template, the agent model policy, Claude mods, the statusline, and the `test-runner` agent. `install.sh` installs them into `~/.claude/`.

The portable harness (skills, the `zharness` CLI, the `.harness/` protocol, and the `mono-lead` / `mono-worker` / `mono-verifier` agents) lives in [monoharness](https://github.com/tinhtute/monoharness). This repository only holds what is specific to Claude Code.

## Quick start

```bash
bash install.sh
```

After install: edit `~/.claude/settings.json` → set `ANTHROPIC_AUTH_TOKEN`.

`install.sh` also installs the core harness skills from monoharness (the workflow chain and what its playbooks call). The rarely used ones, `ambition`, `arena`, `librarian` and every skill in this repository (see [Skills](#skills)), install only with `bash install.sh --all` or on demand: `npx skills add git@github.com:tinhtute/<repo>.git -s <name> -a claude-code -g -y`. It does not install the harness agents; run monoharness's `scripts/install-agents.sh` from a monoharness checkout for those.

## Contents

| Path | Installed to | Notes |
| :--- | :--- | :--- |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Voice, hard rules, working style |
| `rules/*.md` | `~/.claude/rules/` | English coaching; retires rules folded into `CLAUDE.md` |
| `settings.json` | `~/.claude/settings.json` | Template; only copied if the file doesn't exist |
| `agents/test-runner.md` | `~/.claude/agents/` | Read-only agent that runs a named suite and returns only failures |
| `models.json` | not installed | Role → model policy for `agents/*.md`, checked by `scripts/test-agent-models.sh` |
| `mods/` | `~/.claude/mods/` | `ninja-kit` and `cache-guard`, loaded through `CLAUDE_CODE_PLUGIN_DIRS` |
| `skills/` | `~/.claude/skills/` (via `npx skills add`) | General-purpose skills outside the harness workflow; see [Skills](#skills) |
| `evals/` | not installed | Eval set for the `write` skill |
| `statusline/` | `~/.claude/statusline.{sh,py}` | Statusline installers, run by `install.sh` (slim) or by hand (`setup-pulse.sh`) |

## Skills

General-purpose skills that the monoharness SDLC workflow does not use. Each lives flat under `skills/<name>/` and installs with `npx skills add git@github.com:tinhtute/monoclaudian.git`.

| Skill | What it does |
| :--- | :--- |
| `write` | Writes and edits EN/VI prose so it reads natural, concise, and audience-aware |
| `prompt-leverage` | Turns a raw prompt into an execution-ready instruction set for an agent |
| `create-skill` | Creates or updates skills with progressive disclosure and lean context |
| `create-cli` | Designs CLI interfaces and a framework and shipping roadmap |
| `tldraw-diagram` | Draws architecture or workflow diagrams in tldraw offline and exports PNGs |
| `turbo-mono-platform` | Scaffolds and reviews Turborepo full-stack TypeScript monorepos |

`evals/` is the eval set for the `write` skill: each `evals/NN-*/prompt.md` loads `skills/write` and its `graders/` score the result.

## Prerequisites

- **Node.js** v18+ (required by `npx skills add` in `install.sh`)
- **jq** (required by the statusline and `scripts/test-agent-models.sh`) — `brew install jq` or `apt install jq`
- SSH key configured for `git@github.com:tinhtute/monoharness.git` and `git@github.com:tinhtute/monoclaudian.git`

## Mods

`ninja-kit` holds the tool guards (`rm` → `trash`, sensitive files, private URLs to web tools), the compaction rule reminder, and an active-plan footer. Test it with `claude plugin test mods/ninja-kit`.

The footer reads plans from the hardcoded path `.harness/plans/active` in the current repository. That is the zharness plan layout from [monoharness](https://github.com/tinhtute/monoharness); in a repository without that layout the footer shows nothing. The path is not configurable.

`cache-guard` shows a band above the prompt when the model or effort changes while context is at or above `threshold` percent (default 40, set under `pluginConfigs."cache-guard".options`), with Compact and Skip buttons, because the switch drops the prompt cache. Test it with `claude plugin test mods/cache-guard`.

## Checks

CI (`.github/workflows/ci.yml`) runs on push and pull request to `master`:

```bash
# mods: pure rule tests (register.test.ts and band.test.tsx need the private
# claude-code/testing kit and run only via `claude plugin test`)
(cd mods/ninja-kit && bun test hooks/rules.spec.ts)
(cd mods/cache-guard && bun test hooks/rules.spec.ts)

# agent-models: models.json matches agents/*.md frontmatter
bash scripts/test-agent-models.sh

# skills: every skills/*/SKILL.md has name == directory and a description
bash scripts/validate-skills.sh
```

from therealTINHTUTE with love
