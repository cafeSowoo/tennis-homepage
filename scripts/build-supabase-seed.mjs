import { readFileSync } from "node:fs";

const readJSON = path => JSON.parse(readFileSync(new URL(`../${path}`, import.meta.url), "utf8"));
const members = readJSON("data/members.json");
const courts = readJSON("data/courts.json");
const courtUnits = readJSON("data/court-units.json");
const schedules = readJSON("data/schedules.json");
const events = readJSON("data/events.json");
const discussions = readJSON("data/discussions.json");

const sql = value => {
  if (value === undefined || value === null) return "null";
  return `'${String(value).replaceAll("'", "''")}'`;
};

const bool = value => value === undefined || value === null ? "null" : String(Boolean(value));
const textArray = values => `array[${(values || []).map(sql).join(", ")}]::text[]`;

console.log("begin;");

console.log("insert into public.members (id, name, status) values");
console.log(members.map(member =>
  `  (${sql(member.id)}, ${sql(member.name)}, ${sql(member.status || "active")})`
).join(",\n") + "\non conflict (id) do update set name = excluded.name, status = excluded.status;");

console.log("insert into public.courts (id, name, image, type, location, canonical_name) values");
console.log(courts.map(court =>
  `  (${sql(court.id)}, ${sql(court.name)}, ${sql(court.image)}, ${sql(court.type)}, ${sql(court.location)}, ${sql(court.canonicalName)})`
).join(",\n") + "\non conflict (id) do update set name = excluded.name, image = excluded.image, type = excluded.type, location = excluded.location, canonical_name = excluded.canonical_name;");

console.log("insert into public.court_units (id, court_id, label, surface, sort_order) values");
console.log(courtUnits.map(unit =>
  `  (${sql(unit.id)}, ${sql(unit.courtId)}, ${sql(unit.label)}, ${sql(unit.surface)}, ${unit.sortOrder ?? 0})`
).join(",\n") + "\non conflict (id) do update set court_id = excluded.court_id, label = excluded.label, surface = excluded.surface, sort_order = excluded.sort_order;");

console.log("insert into public.schedules (id, date, day, time, title, court_id, court_unit_id, attendee_ids, regular, closed, important, source, created_at) values");
console.log(schedules.map(schedule =>
  `  (${sql(schedule.id)}, ${sql(schedule.date)}, ${sql(schedule.day)}, ${sql(schedule.time)}, ${sql(schedule.title)}, ${sql(schedule.courtId)}, ${sql(schedule.courtUnitId)}, ${textArray(schedule.attendeeIds)}, ${bool(schedule.regular)}, ${bool(schedule.closed)}, ${bool(schedule.important)}, ${sql(schedule.source || "seed")}, ${sql(schedule.createdAt)})`
).join(",\n") + "\non conflict (id) do update set date = excluded.date, day = excluded.day, time = excluded.time, title = excluded.title, court_id = excluded.court_id, court_unit_id = excluded.court_unit_id, attendee_ids = excluded.attendee_ids, regular = excluded.regular, closed = excluded.closed, important = excluded.important;");

if (events.length) {
  console.log("insert into public.events (id, date, title, category, start_time, end_time, all_day, location, note, source, created_at) values");
  console.log(events.map(event =>
    `  (${sql(event.id)}, ${sql(event.date)}, ${sql(event.title)}, ${sql(event.category || "other")}, ${sql(event.startTime)}, ${sql(event.endTime)}, ${bool(event.allDay)}, ${sql(event.location)}, ${sql(event.note)}, ${sql(event.source || "seed")}, ${sql(event.createdAt)})`
  ).join(",\n") + "\non conflict (id) do update set date = excluded.date, title = excluded.title, category = excluded.category, start_time = excluded.start_time, end_time = excluded.end_time, all_day = excluded.all_day, location = excluded.location, note = excluded.note, created_at = excluded.created_at;");
}

console.log("insert into public.discussions (id, schedule_id, member_id, display_time, message, source, created_at) values");
console.log(discussions.map(discussion =>
  `  (${sql(discussion.id)}, ${sql(discussion.scheduleId)}, ${sql(discussion.memberId)}, ${sql(discussion.displayTime)}, ${sql(discussion.message)}, ${sql(discussion.source || "seed")}, ${sql(discussion.createdAt)})`
).join(",\n") + "\non conflict (id) do update set schedule_id = excluded.schedule_id, member_id = excluded.member_id, display_time = excluded.display_time, message = excluded.message, created_at = excluded.created_at;");

console.log("commit;");
