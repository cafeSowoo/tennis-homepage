# Automation Prompts

This directory keeps restorable copies of Codex automation prompts used for this
project.

The live automation state is stored outside the repository under
`~/.codex/automations/`. Keep stable prompt versions here so a working
automation can be restored after accidental edits or app-side changes.

## Current Baseline

- `kakao-schedule-visible-row-backspace-2026-07-10.md`
  - Automation id: `automation-4`
  - Exact live prompt snapshot from 2026-07-10.
  - Uses one Backspace key press to return from detail to the schedule list.
  - Starts from today or the first future schedule and processes visible rows
    immediately.
  - Excludes comments and the `discussions` table.
  - Multi-court labels use `court_unit_id=null`.
  - The attendee helper dynamically finds the current detail window and clicks
    the center of the `N명 참석` text without fixed window indexes or coordinates.
  - Live setting: `status=PAUSED`, `model=gpt-5.6-terra`,
    `reasoning_effort=high`.

## Previous Baselines

- `kakao-schedule-visible-row-start-position-2026-06-08.md`
  - Automation id: `automation-4`
  - Strategy: process each currently visible KakaoTalk schedule row immediately,
    but first move to today's date or the first future schedule instead of
    trusting the schedule tab's remembered scroll position.
  - Scope: schedules, members, courts, court units.
  - Excludes: comments and the `discussions` table.
  - Multi-court labels such as `AB`, `A.B`, `A/B`, and `A+B` are stored with
    `court_unit_id=null` instead of becoming unresolved.
  - Strikethrough, dimmed, or not-attending display is not used as a skip
    reason.
  - If the schedule window closes after returning from detail, reopen the
    KakaoTalk board schedule tab and continue from the next fresh visible row
    snapshot when safe.
  - Successful run setting: `model=gpt-5.5`, `reasoning_effort=high`.

- `kakao-schedule-visible-row-multicourt-2026-05-27.md`
  - Automation id: `automation-4`
  - Strategy: process each currently visible KakaoTalk schedule row immediately.
  - Scope: schedules, members, courts, court units.
  - Excludes: comments and the `discussions` table.
  - Multi-court labels such as `AB`, `A.B`, `A/B`, and `A+B` are stored with
    `court_unit_id=null` instead of becoming unresolved.

- `kakao-schedule-visible-row-2026-05-27.md`
  - First visible-row baseline before the multi-court unresolved rule was
    relaxed.
