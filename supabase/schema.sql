create table if not exists public.members (
  id text primary key,
  name text not null,
  status text default 'active'
);

create table if not exists public.courts (
  id text primary key,
  name text not null,
  image text,
  type text,
  location text,
  canonical_name text
);

create table if not exists public.schedules (
  id text primary key,
  date date not null,
  day text not null,
  time text not null,
  title text not null,
  court_id text references public.courts(id),
  attendee_ids text[] not null default '{}',
  regular boolean,
  closed boolean,
  important boolean,
  source text default 'supabase',
  created_at timestamptz default now()
);

create table if not exists public.events (
  id text primary key,
  date date not null,
  title text not null,
  category text not null default 'other',
  start_time text,
  end_time text,
  all_day boolean,
  location text,
  note text,
  source text default 'supabase',
  created_at timestamptz default now()
);

create table if not exists public.discussions (
  id text primary key,
  schedule_id text not null references public.schedules(id) on delete cascade,
  member_id text references public.members(id),
  display_time text,
  message text not null,
  source text default 'supabase',
  created_at timestamptz default now()
);

alter table public.members enable row level security;
alter table public.courts enable row level security;
alter table public.schedules enable row level security;
alter table public.events enable row level security;
alter table public.discussions enable row level security;

drop policy if exists "public read members" on public.members;
drop policy if exists "public read courts" on public.courts;
drop policy if exists "public read schedules" on public.schedules;
drop policy if exists "public read events" on public.events;
drop policy if exists "public read discussions" on public.discussions;
drop policy if exists "preview write schedules" on public.schedules;
drop policy if exists "preview write events" on public.events;
drop policy if exists "preview write discussions" on public.discussions;
drop policy if exists "owner insert schedules" on public.schedules;
drop policy if exists "owner update schedules" on public.schedules;
drop policy if exists "owner delete schedules" on public.schedules;
drop policy if exists "owner insert events" on public.events;
drop policy if exists "owner update events" on public.events;
drop policy if exists "owner delete events" on public.events;
drop policy if exists "owner insert discussions" on public.discussions;
drop policy if exists "owner update discussions" on public.discussions;
drop policy if exists "owner delete discussions" on public.discussions;

create policy "public read members" on public.members for select using (true);
create policy "public read courts" on public.courts for select using (true);
create policy "public read schedules" on public.schedules for select using (true);
create policy "public read events" on public.events for select using (true);
create policy "public read discussions" on public.discussions for select using (true);

create policy "owner insert schedules"
  on public.schedules
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner update schedules"
  on public.schedules
  for update
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete schedules"
  on public.schedules
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner insert events"
  on public.events
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner update events"
  on public.events
  for update
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete events"
  on public.events
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner insert discussions"
  on public.discussions
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner update discussions"
  on public.discussions
  for update
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete discussions"
  on public.discussions
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

grant usage on schema public to anon, authenticated;
grant select on public.members, public.courts, public.schedules, public.events, public.discussions to anon, authenticated;
revoke insert, update, delete, truncate on public.members, public.courts, public.schedules, public.events, public.discussions from anon, authenticated;
grant insert, update, delete on public.schedules, public.events, public.discussions to authenticated;
