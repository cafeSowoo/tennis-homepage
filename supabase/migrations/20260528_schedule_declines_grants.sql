-- Run once in Supabase SQL Editor if "permission denied for table schedule_declines" occurs.
-- Safe to re-run: creates table/policies if missing, then grants write access.

create table if not exists public.schedule_declines (
  schedule_id text not null references public.schedules(id) on delete cascade,
  member_id text not null references public.members(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (schedule_id, member_id)
);

alter table public.schedule_declines enable row level security;

drop policy if exists "public read schedule declines" on public.schedule_declines;
drop policy if exists "owner insert schedule declines" on public.schedule_declines;
drop policy if exists "owner update schedule declines" on public.schedule_declines;
drop policy if exists "owner delete schedule declines" on public.schedule_declines;

create policy "public read schedule declines"
  on public.schedule_declines
  for select
  using (true);

create policy "owner insert schedule declines"
  on public.schedule_declines
  for insert
  to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner update schedule declines"
  on public.schedule_declines
  for update
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create policy "owner delete schedule declines"
  on public.schedule_declines
  for delete
  to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

grant select on public.schedule_declines to anon, authenticated;
grant insert, update, delete on public.schedule_declines to authenticated;
