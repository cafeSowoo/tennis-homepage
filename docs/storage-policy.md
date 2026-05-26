# Storage Policy

This project uses Supabase as the single official data source when Supabase is
configured:

```text
Kakao schedule automation -> Supabase
Homepage direct edits -> Supabase
Homepage display -> Supabase
```

## Official Source

Supabase is the official source of truth for operational data:

- `members`: people who can appear as attendees or discussion authors.
- `courts`: places used by schedules.
- `schedules`: tennis schedules and attendee IDs.
- `events`: non-tennis calendar events that should be shared as official data.
- `discussions`: schedule comments.

The Kakao automation updates Supabase only. It does not update local JSON files,
UI code, assets, or browser storage.

## Local JSON Files

Files under `data/*.json` are seed and fallback data, not the preferred
operational source once Supabase is configured.

Use JSON files for:

- bootstrapping a Supabase project with `scripts/build-supabase-seed.mjs`;
- local fallback when Supabase is not configured or intentionally unavailable;
- reviewing the original static data shape.

Do not treat JSON changes as production data changes while the deployed app is
reading from Supabase.

## Browser localStorage

Browser `localStorage` is device-local. Data saved there exists only in that
browser profile on that phone or computer.

With the committed GitHub Pages configuration, direct homepage edits write to
Supabase after the owner signs in with Google. In that mode, localStorage does
not override official schedules, attendees, events, or discussions.

localStorage is still used as a fallback when Supabase is not configured or when
remote writes are intentionally disabled for a preview.

Current official-data-related keys to watch:

- `tennis.localSchedules`
- `tennis.localEvents`
- `tennis.deletedScheduleIds`
- `tennis.scheduleAttendeeOverrides`
- `tennis.localDiscussions`
- `tennis.scheduleOverrides`
- `tennis.eventOverrides`

Long term, localStorage should keep only personal or UI state such as:

- notification preference;
- reminder send log;
- dismissed PWA install banner;
- selected local profile or display preference.

It should not be the official home for schedules, attendees, events, members,
courts, or discussions.

## Transition Rule

After switching homepage edits to official Supabase writes:

1. Review any important edits that exist only in the phone browser.
2. Copy the edits that should be kept into Supabase.
3. Clear site data on the phone once Supabase contains the desired official data.
4. Use Supabase as the single operational source from that point on.

If the homepage screen disagrees with Supabase after a large data cleanup, check
whether localStorage still contains old schedule overrides, deletions, or local
comments.
