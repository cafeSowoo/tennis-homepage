#!/usr/bin/env node

import { createServer } from "node:http";
import { spawn } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { basename, resolve } from "node:path";
import { randomBytes } from "node:crypto";

const ROOT = resolve(new URL("..", import.meta.url).pathname);
const ENV_PATH = resolve(ROOT, ".env.local");
const TOKEN_PATH = resolve(ROOT, ".kakao-calendar-token.json");
const OUTPUT_DIR = resolve(ROOT, "tmp");

await loadDotEnv(ENV_PATH);

const REST_API_KEY = process.env.KAKAO_REST_API_KEY;
const CLIENT_SECRET = process.env.KAKAO_CLIENT_SECRET || "";
const REDIRECT_URI = process.env.KAKAO_REDIRECT_URI || "http://localhost:8787/oauth/callback";
const WINDOW_DAYS = Number(process.env.KAKAO_PROBE_DAYS || 31);
const OPEN_BROWSER = process.env.KAKAO_OPEN_BROWSER !== "false";

if (!REST_API_KEY && !process.env.KAKAO_ACCESS_TOKEN) {
  fail([
    "Missing KAKAO_REST_API_KEY.",
    "Create .env.local with:",
    "KAKAO_REST_API_KEY=your_rest_api_key",
    `KAKAO_REDIRECT_URI=${REDIRECT_URI}`,
    "",
    "The redirect URI must also be registered in Kakao Developers.",
  ]);
}

const token = await getAccessToken();
const range = kstDateRange(WINDOW_DAYS);

console.log(`Probe range: ${range.fromKstDate} 00:00 KST -> ${range.toKstDate} 00:00 KST`);

const calendarsResponse = await kakaoGet("/v2/api/calendar/calendars", { filter: "ALL" }, token.access_token);
const calendars = flattenCalendars(calendarsResponse);
console.log(`Calendars visible: ${calendars.length}`);
for (const calendar of calendars) {
  console.log(`- ${calendar.kind} ${calendar.id}${calendar.name ? ` (${calendar.name})` : ""}`);
}

const allEventsResponse = await listEvents({ token, range });
const allEvents = allEventsResponse.events || [];
console.log(`\nEvents visible without calendar filter: ${allEvents.length}`);
printEvents(allEvents);

const perCalendar = [];
for (const calendar of calendars) {
  const response = await listEvents({ token, range, calendarId: calendar.id });
  const events = response.events || [];
  perCalendar.push({ calendar, count: events.length, events });
  console.log(`\nEvents in ${calendar.id}${calendar.name ? ` (${calendar.name})` : ""}: ${events.length}`);
  printEvents(events);
}

const uniqueEventIds = [...new Set([
  ...allEvents.map(event => event.id).filter(Boolean),
  ...perCalendar.flatMap(item => item.events.map(event => event.id).filter(Boolean)),
])];
const details = [];

for (const eventId of uniqueEventIds.slice(0, 30)) {
  try {
    const detail = await kakaoGet("/v2/api/calendar/event", { event_id: eventId }, token.access_token);
    details.push({ eventId, ok: true, detail });
  } catch (error) {
    details.push({ eventId, ok: false, error: error.message });
  }
}

await mkdir(OUTPUT_DIR, { recursive: true });
const outputPath = resolve(OUTPUT_DIR, `kakao-calendar-probe-${timestampForFile()}.json`);
await writeFile(outputPath, JSON.stringify({
  generatedAt: new Date().toISOString(),
  range,
  calendarsResponse,
  allEventsResponse,
  perCalendar,
  details,
}, null, 2));

console.log(`\nWrote raw probe output to ${relativeName(outputPath)}`);
console.log("Next check: compare the visible events above with the KakaoTalk schedule tab.");

async function getAccessToken() {
  if (process.env.KAKAO_ACCESS_TOKEN) {
    return { access_token: process.env.KAKAO_ACCESS_TOKEN };
  }

  const saved = await readJsonIfExists(TOKEN_PATH);
  if (saved?.access_token) {
    return saved;
  }

  const token = await runOAuthFlow();
  await writeFile(TOKEN_PATH, JSON.stringify(token, null, 2));
  console.log(`Saved token to ${basename(TOKEN_PATH)} (ignored by git).`);
  return token;
}

async function runOAuthFlow() {
  const redirect = new URL(REDIRECT_URI);
  const state = randomBytes(16).toString("hex");
  const authUrl = new URL("https://kauth.kakao.com/oauth/authorize");
  authUrl.searchParams.set("client_id", REST_API_KEY);
  authUrl.searchParams.set("redirect_uri", REDIRECT_URI);
  authUrl.searchParams.set("response_type", "code");
  authUrl.searchParams.set("scope", "talk_calendar");
  authUrl.searchParams.set("state", state);

  const server = createServer();
  const codePromise = new Promise((resolveCode, rejectCode) => {
    server.on("request", (req, res) => {
      const requestUrl = new URL(req.url || "/", REDIRECT_URI);
      if (requestUrl.pathname !== redirect.pathname) {
        res.writeHead(404);
        res.end("Not found");
        return;
      }

      if (requestUrl.searchParams.get("state") !== state) {
        res.writeHead(400);
        res.end("Invalid OAuth state.");
        rejectCode(new Error("Invalid OAuth state."));
        return;
      }

      const error = requestUrl.searchParams.get("error");
      if (error) {
        const description = requestUrl.searchParams.get("error_description") || error;
        res.writeHead(400, { "Content-Type": "text/plain; charset=utf-8" });
        res.end(description);
        rejectCode(new Error(description));
        return;
      }

      const code = requestUrl.searchParams.get("code");
      res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("Kakao OAuth complete. You can close this tab.");
      resolveCode(code);
    });
  });

  await new Promise((resolveListen, rejectListen) => {
    server.once("error", rejectListen);
    server.listen(Number(redirect.port || 80), redirect.hostname, resolveListen);
  });

  console.log("Open this URL to authorize Talk Calendar read access:");
  console.log(authUrl.toString());
  if (OPEN_BROWSER && process.platform === "darwin") {
    spawn("open", [authUrl.toString()], { stdio: "ignore", detached: true });
  }

  try {
    const code = await codePromise;
    if (!code) throw new Error("OAuth callback did not include a code.");
    return await exchangeCode(code);
  } finally {
    server.close();
  }
}

async function exchangeCode(code) {
  const body = new URLSearchParams({
    grant_type: "authorization_code",
    client_id: REST_API_KEY,
    redirect_uri: REDIRECT_URI,
    code,
  });
  if (CLIENT_SECRET) body.set("client_secret", CLIENT_SECRET);

  const response = await fetch("https://kauth.kakao.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded;charset=utf-8" },
    body,
  });

  if (!response.ok) {
    throw new Error(`Token exchange failed: ${response.status} ${await response.text()}`);
  }
  return await response.json();
}

async function listEvents({ token, range, calendarId = "" }) {
  const params = {
    from: range.fromUtc,
    to: range.toUtc,
    limit: "1000",
    time_zone: "Asia/Seoul",
  };
  if (calendarId) params.calendar_id = calendarId;

  let response = await kakaoGet("/v2/api/calendar/events", params, token.access_token);
  const events = [...(response.events || [])];
  while (response.has_next && response.after_url) {
    response = await kakaoGetAbsolute(response.after_url, token.access_token);
    events.push(...(response.events || []));
  }
  return { ...response, events };
}

async function kakaoGet(path, params, accessToken) {
  const url = new URL(path, "https://kapi.kakao.com");
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== "") {
      url.searchParams.set(key, String(value));
    }
  }
  return await kakaoGetAbsolute(url.toString(), accessToken);
}

async function kakaoGetAbsolute(url, accessToken) {
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!response.ok) {
    throw new Error(`${url} failed: ${response.status} ${await response.text()}`);
  }
  return await response.json();
}

function flattenCalendars(response) {
  return [
    ...(response.calendars || []).map(calendar => ({ ...calendar, kind: "USER" })),
    ...(response.subscribe_calendars || []).map(calendar => ({ ...calendar, kind: "SUBSCRIBE" })),
  ];
}

function printEvents(events) {
  if (!events.length) {
    console.log("  (none)");
    return;
  }

  for (const event of events.slice(0, 25)) {
    const start = event.time?.start_at || "?";
    const end = event.time?.end_at || "?";
    const visible = Object.keys(event).sort().join(", ");
    console.log(`  - ${start} -> ${end} | ${event.title || "(no title)"} | id=${event.id || "(no id)"} | fields=[${visible}]`);
  }

  if (events.length > 25) {
    console.log(`  ... ${events.length - 25} more`);
  }
}

function kstDateRange(days) {
  const now = new Date();
  const kstNow = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const fromKstDate = kstNow.toISOString().slice(0, 10);
  const toKstDate = new Date(kstNow.getTime() + days * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
  return {
    fromKstDate,
    toKstDate,
    fromUtc: new Date(`${fromKstDate}T00:00:00+09:00`).toISOString(),
    toUtc: new Date(`${toKstDate}T00:00:00+09:00`).toISOString(),
  };
}

async function loadDotEnv(path) {
  if (!existsSync(path)) return;
  const content = await readFile(path, "utf8");
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const match = trimmed.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (!match) continue;
    const [, key, rawValue] = match;
    if (process.env[key] !== undefined) continue;
    process.env[key] = rawValue.replace(/^['"]|['"]$/g, "");
  }
}

async function readJsonIfExists(path) {
  if (!existsSync(path)) return null;
  return JSON.parse(await readFile(path, "utf8"));
}

function timestampForFile() {
  return new Date().toISOString().replace(/[:.]/g, "-");
}

function relativeName(path) {
  return path.startsWith(`${ROOT}/`) ? path.slice(ROOT.length + 1) : path;
}

function fail(lines) {
  console.error(lines.join("\n"));
  process.exit(1);
}
