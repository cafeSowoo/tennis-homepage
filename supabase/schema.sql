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

create table if not exists public.court_units (
  id text primary key,
  court_id text not null references public.courts(id) on delete cascade,
  label text not null,
  surface text,
  sort_order integer default 0
);

create table if not exists public.schedules (
  id text primary key,
  date date not null,
  day text not null,
  time text not null,
  title text not null,
  court_id text references public.courts(id),
  court_unit_id text references public.court_units(id),
  host_id text references public.members(id),
  attendee_ids text[] not null default '{}',
  regular boolean,
  closed boolean,
  important boolean,
  source text default 'supabase',
  created_at timestamptz default now()
);

alter table public.schedules add column if not exists host_id text references public.members(id);

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

create table if not exists public.schedule_declines (
  schedule_id text not null references public.schedules(id) on delete cascade,
  member_id text not null references public.members(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (schedule_id, member_id)
);

alter table public.members enable row level security;
alter table public.courts enable row level security;
alter table public.court_units enable row level security;
alter table public.schedules enable row level security;
alter table public.events enable row level security;
alter table public.discussions enable row level security;
alter table public.schedule_declines enable row level security;

drop policy if exists "public read members" on public.members;
drop policy if exists "public read courts" on public.courts;
drop policy if exists "public read court units" on public.court_units;
drop policy if exists "public read schedules" on public.schedules;
drop policy if exists "public read events" on public.events;
drop policy if exists "public read discussions" on public.discussions;
drop policy if exists "preview write schedules" on public.schedules;
drop policy if exists "preview write events" on public.events;
drop policy if exists "preview write discussions" on public.discussions;
drop policy if exists "owner insert schedules" on public.schedules;
drop policy if exists "owner update schedules" on public.schedules;
drop policy if exists "owner delete schedules" on public.schedules;
drop policy if exists "owner insert courts" on public.courts;
drop policy if exists "owner update courts" on public.courts;
drop policy if exists "owner delete courts" on public.courts;
drop policy if exists "owner insert court units" on public.court_units;
drop policy if exists "owner update court units" on public.court_units;
drop policy if exists "owner delete court units" on public.court_units;
drop policy if exists "owner insert events" on public.events;
drop policy if exists "owner update events" on public.events;
drop policy if exists "owner delete events" on public.events;
drop policy if exists "owner insert discussions" on public.discussions;
drop policy if exists "owner update discussions" on public.discussions;
drop policy if exists "owner delete discussions" on public.discussions;
drop policy if exists "public read schedule declines" on public.schedule_declines;
drop policy if exists "owner insert schedule declines" on public.schedule_declines;
drop policy if exists "owner delete schedule declines" on public.schedule_declines;

create policy "public read members" on public.members for select using (true);
create policy "public read courts" on public.courts for select using (true);
create policy "public read court units" on public.court_units for select using (true);
create policy "public read schedules" on public.schedules for select using (true);
create policy "public read events" on public.events for select using (true);
create policy "public read discussions" on public.discussions for select using (true);
create policy "public read schedule declines" on public.schedule_declines for select using (true);

create policy "owner insert courts"
  on public.courts
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner update courts"
  on public.courts
  for update
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete courts"
  on public.courts
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner insert court units"
  on public.court_units
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner update court units"
  on public.court_units
  for update
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete court units"
  on public.court_units
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

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

create policy "owner insert schedule declines"
  on public.schedule_declines
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete schedule declines"
  on public.schedule_declines
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

grant usage on schema public to anon, authenticated;
grant select on public.members, public.courts, public.court_units, public.schedules, public.events, public.discussions, public.schedule_declines to anon, authenticated;
revoke insert, update, delete, truncate on public.members, public.courts, public.court_units, public.schedules, public.events, public.discussions, public.schedule_declines from anon, authenticated;
grant insert, update, delete on public.courts, public.court_units, public.schedules, public.events, public.discussions to authenticated;
grant insert, delete on public.schedule_declines to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'court-images',
  'court-images',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public read court images" on storage.objects;
drop policy if exists "owner read court images" on storage.objects;
drop policy if exists "owner insert court images" on storage.objects;
drop policy if exists "owner update court images" on storage.objects;
drop policy if exists "owner delete court images" on storage.objects;

create policy "owner read court images"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'court-images'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

create policy "owner insert court images"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'court-images'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

create policy "owner update court images"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'court-images'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  )
  with check (
    bucket_id = 'court-images'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

create policy "owner delete court images"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'court-images'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );
