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
alter table public.discussions enable row level security;

drop policy if exists "public read members" on public.members;
drop policy if exists "public read courts" on public.courts;
drop policy if exists "public read schedules" on public.schedules;
drop policy if exists "public read discussions" on public.discussions;
drop policy if exists "preview write schedules" on public.schedules;
drop policy if exists "preview write discussions" on public.discussions;

create policy "public read members" on public.members for select using (true);
create policy "public read courts" on public.courts for select using (true);
create policy "public read schedules" on public.schedules for select using (true);
create policy "public read discussions" on public.discussions for select using (true);

-- Personal preview mode: anon writes are convenient but should be replaced
-- with authenticated admin-only policies before sharing the URL with members.
create policy "preview write schedules" on public.schedules for all using (true) with check (true);
create policy "preview write discussions" on public.discussions for all using (true) with check (true);
