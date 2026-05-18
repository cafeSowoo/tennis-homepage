# Local data store

This folder is the local data source for the single-file SPA.

- `members.json`: member records. Schedules reference members by `member.id`.
- `courts.json`: court records. Schedules reference courts by `court.id`.
- `schedules.json`: schedule records. UI display fields such as `place` and attendee names are hydrated in `index.html`.
- `discussions.json`: match discussion records. Discussion rows reference schedules by `schedule.id` and members by `member.id`. Use `displayTime` when the source only provides a human-readable timestamp.

Keep `id` values stable. They are the bridge to a future hosted database such as Supabase.
