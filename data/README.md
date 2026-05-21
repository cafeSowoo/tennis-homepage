# Local data store

This folder is the local data source for the single-file SPA.

- `members.json`: member records. Schedules reference members by `member.id`.
- `courts.json`: court records. Schedules reference courts by `court.id`.
- `schedules.json`: schedule records. UI display fields such as `place` and attendee names are hydrated in `index.html`.
- `events.json`: non-tennis calendar events. Use this for personal, work, travel, family, or other dates that should appear on the dashboard calendar.
- `discussions.json`: match discussion records. Discussion rows reference schedules by `schedule.id` and members by `member.id`. Use `displayTime` when the source only provides a human-readable timestamp.

Keep `id` values stable. They are the bridge to a future hosted database such as Supabase.

Example `events.json` row:

```json
{
  "id": "event-2026-06-05-personal",
  "date": "2026-06-05",
  "title": "개인 일정",
  "startTime": "14:00",
  "endTime": "16:00",
  "category": "personal",
  "location": "송도",
  "note": "달력에만 표시되는 다른 일정"
}
```

Supported categories: `personal`, `work`, `travel`, `family`, `other`.
