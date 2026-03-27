# Codex Subagent Policy

This repository uses the VoltAgent `awesome-codex-subagents` catalog as the
default subagent library and expects skills to be selected just as deliberately
as subagents on every task.
Because this app is being built with Flutter, actively prefer `flutter-expert`
as the default specialist for app work unless a narrower role is clearly a
better fit.

## Installed Agent Source

- Global install path: `~/.codex/agents`
- Upstream snapshot: `~/.codex/vendor_imports/awesome-codex-subagents`
- Source catalog: `https://github.com/VoltAgent/awesome-codex-subagents.git`

All `.toml` agents from that catalog should remain installed globally unless a
task requires a smaller project-local override.
If a required VoltAgent agent is missing locally, restore it from the upstream
snapshot before defaulting away from the VoltAgent catalog.

## Installed Skill Source

- Global skill path: `~/.codex/skills`
- Built-in system skills: `~/.codex/skills/.system`
- Installer workflow: use the `skill-installer` skill when the best-fit skill
  is missing and the task would materially benefit from it

Prefer installed skills first. If the right skill does not exist locally,
install it before substantial work when feasible. If installation is blocked by
network, permissions, or missing source details, state the blocker, choose the
closest safe fallback, and continue with that limitation made explicit.

## Required Workflow

Before starting any task in this repository, make an explicit subagent choice
and an explicit skill choice. For small tasks, keep the team minimal, but do
not skip the selection step:

1. Inspect the task and choose the smallest useful subagent team first.
2. Identify the best-fit skill or skills for the task before editing code.
3. If the task is broad, ambiguous, or naturally multi-step, first use a
   VoltAgent orchestration role such as `agent-organizer`,
   `multi-agent-coordinator`, `task-distributor`, or
   `workflow-orchestrator` to design the split.
4. Assign clear responsibilities before editing code, with one write owner per
   file or module unless scopes are explicitly non-overlapping.
5. For small tasks that do not split cleanly, still launch at least one
   best-fit specialist subagent and add a read-only validation sidecar when it
   materially improves confidence.
6. Install missing but important skills before substantial work when feasible,
   typically via the `skill-installer` skill from a curated source or GitHub
   path.
7. Keep the main agent on the critical path and delegate sidecar analysis,
   debugging, UI cleanup, and validation in parallel.
8. Report which subagents and skills were selected, why they were chosen, and
   any install/fallback decision that affected execution.

## Selection Rules

- Match subagents by delivery surface first, then by language or framework.
- For this repository, when the task touches Flutter app code, widgets, state,
  navigation, platform integration, build behavior, runtime bugs, or device UI,
  prefer `flutter-expert` as the first specialist subagent.
- Prefer VoltAgent custom subagents over generic delegation when a matching
  role exists.
- Add a read-only validation sidecar such as `reviewer`, `code-reviewer`,
  `qa-expert`, `debugger`, or `security-auditor` when it improves confidence.
- Match skills by task objective first: implementation, debugging, deployment,
  design, docs, spreadsheet, PDF, transcription, security, and so on.
- Prefer the smallest skill set that covers the task well; do not load skills
  speculatively.
- Reuse the workflow, scripts, and assets defined by the chosen skill instead
  of reimplementing them ad hoc.

## Default Teaming Heuristics

For Travel Atlas mobile work, prefer this mapping:

- `flutter-expert`
  Use as the default first-choice specialist for Flutter feature work, widget
  behavior, runtime issues, device-specific bugs, and most UI changes.
- `mobile-developer`
  Use as a complementary or fallback mobile specialist when broader app-level
  ownership is more useful than Flutter-specific depth.
- `debugger`
  Use for crash reproduction, runtime log analysis, and root-cause isolation.
- `ui-fixer`
  Use for layout overflows, spacing regressions, and visual cleanup.
- `qa-expert`
  Use for simulator/device validation plans, regression coverage, and release
  acceptance.
- `reviewer`
  Use before final delivery when correctness or regression risk is high.

## Default Skill Heuristics

For this repository, prefer skills that directly match the active task:

- Use platform or framework specific skills first when available.
- Use implementation skills before generic reasoning when the task has a known
  workflow or helper scripts.
- Add a validation or review skill when the main skill optimizes for execution
  more than verification.
- If no suitable installed skill exists, install one before proceeding when the
  benefit is clear and the source is trustworthy.

## Return Behavior

Before or during substantive work, briefly state:

- which VoltAgent subagents were selected and why
- which skills were selected and why
- how ownership is split for parallel work
- whether any skill had to be installed, or why installation was skipped

## Validation Rule

Do not close a task on `analyze` or `test` alone when the request involves UI,
runtime behavior, or simulator/device bugs. Include runtime validation with the
relevant platform path whenever feasible.
