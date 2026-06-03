# Kakao Calendar Probe

This is a read-only experiment to verify whether schedules from the KakaoTalk
chat room schedule tab are visible through the Talk Calendar REST API.

The probe does not write to Supabase, local JSON, homepage code, Netlify, or
Kakao. It only calls Kakao's calendar read endpoints and writes ignored local
probe output under `tmp/`.

## Kakao Developers Setup

1. In Kakao Developers, enable Kakao Login for the app.
2. In consent items, enable Talk Calendar calendar/event access:
   `talk_calendar`.
3. Register this redirect URI:

```text
http://localhost:8787/oauth/callback
```

4. Create a local `.env.local` file:

```sh
KAKAO_REST_API_KEY=your_rest_api_key
KAKAO_REDIRECT_URI=http://localhost:8787/oauth/callback
```

If the app uses a client secret, also add:

```sh
KAKAO_CLIENT_SECRET=your_client_secret
```

## Run

```sh
node scripts/probe-kakao-calendar.mjs
```

The script opens the Kakao OAuth URL, saves the token to
`.kakao-calendar-token.json`, prints visible calendars and events, and writes raw
API responses to `tmp/kakao-calendar-probe-*.json`.

By default, it checks 31 days from today because Kakao rejects wider event-list
queries. To inspect a shorter window:

```sh
KAKAO_PROBE_DAYS=14 node scripts/probe-kakao-calendar.mjs
```

## How To Interpret

Compare the printed events with the KakaoTalk schedule tab in
`아직도 성장중🎾🎾`.

Important caveat: Kakao's Talk Calendar concepts document says the API does not
currently support the Shared Calendar created from a Team chat. If this chat
room schedule tab is backed by that unsupported calendar type, the probe may
show no usable schedule data.

Useful outcomes:

- If future tennis schedules appear with `id`, `title`, `time`, and `location`,
  an API-based importer is probably viable.
- If they appear only as anonymous `time` blocks, the API may still reduce UI
  work but cannot fully replace the KakaoTalk UI automation.
- If they do not appear at all, move to a staging/diff workflow around the
  current GUI automation.

Official docs note that events not created by the service may return only the
`time` field in list responses, so the raw output matters.

## 2026-05-27 Result

The probe was run against a Kakao Developers app named
`tennis-homepage-probe`.

Result for `2026-05-27 00:00 KST` through `2026-06-27 00:00 KST`:

- Visible calendars: one `primary` user calendar.
- Visible events: one event.
- Returned event fields: `time` only.
- Missing fields: `id`, `title`, `location`, attendee data, comments.

Decision: the Talk Calendar API is not enough to replace the current KakaoTalk
GUI-based schedule source. It can at most provide a coarse time-block hint.

## Next Step

Do not build the API importer from this probe result.

The next implementation direction is to keep KakaoTalk as the source of truth
but split the current GUI automation into a resumable staging workflow:

1. Collect KakaoTalk schedule candidates into a staging table or local ignored
   run artifact without writing to production schedule tables.
2. Generate a diff against Supabase schedules, attendees, and discussions.
3. Resume failed runs from the last collected or verified schedule instead of
   starting over.
4. Apply only reviewed or fully verified changes to Supabase.
5. Keep the current direct Supabase update path disabled until collection and
   diff stages have completed.
