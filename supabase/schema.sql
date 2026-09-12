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
alter table public.schedules add column if not exists photo_url text;
alter table public.schedules add column if not exists photo_path text;
alter table public.schedules add column if not exists photo_position_x numeric(5,2) not null default 50;
alter table public.schedules add column if not exists photo_position_y numeric(5,2) not null default 50;
alter table public.schedules add column if not exists photo_zoom numeric(4,2) not null default 1;
alter table public.schedules add column if not exists photo_uploaded_at timestamptz;

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
drop policy if exists "owner update schedule declines" on public.schedule_declines;
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

grant usage on schema public to anon, authenticated;
grant select on public.members, public.courts, public.court_units, public.schedules, public.events, public.discussions, public.schedule_declines to anon, authenticated;
revoke insert, update, delete, truncate on public.members, public.courts, public.court_units, public.schedules, public.events, public.discussions, public.schedule_declines from anon, authenticated;
grant insert, update, delete on public.courts, public.court_units, public.schedules, public.events, public.discussions to authenticated;
grant insert, update, delete on public.schedule_declines to authenticated;

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

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'schedule-photos',
  'schedule-photos',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
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
drop policy if exists "owner read schedule photos" on storage.objects;
drop policy if exists "owner insert schedule photos" on storage.objects;
drop policy if exists "owner update schedule photos" on storage.objects;
drop policy if exists "owner delete schedule photos" on storage.objects;

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

create policy "owner read schedule photos"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'schedule-photos'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

create policy "owner insert schedule photos"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'schedule-photos'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

create policy "owner update schedule photos"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'schedule-photos'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  )
  with check (
    bucket_id = 'schedule-photos'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

create policy "owner delete schedule photos"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'schedule-photos'
    and lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
  );

-- Kakao metadata and protected source comments
-- Public metadata never includes comment bodies or Kakao account identifiers.
alter table public.schedules add column if not exists kakao_creator_name text;
alter table public.schedules add column if not exists kakao_comment_count integer check (kakao_comment_count >= 0);
alter table public.schedules add column if not exists kakao_synced_at timestamptz;
alter table public.schedules add column if not exists kakao_deeplink text check (kakao_deeplink like 'kakaomoim://post?%');

-- A Google login alone does not establish club membership.
create table if not exists public.kakao_comment_readers (
  user_id uuid primary key references auth.users(id) on delete cascade,
  member_id text references public.members(id) on delete cascade
);
alter table public.kakao_comment_readers enable row level security;
revoke all on public.kakao_comment_readers from anon, authenticated;
grant select, insert, update, delete on public.kakao_comment_readers to authenticated;
drop policy if exists "read own comment membership" on public.kakao_comment_readers;
create policy "read own comment membership" on public.kakao_comment_readers
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "owner manages comment membership" on public.kakao_comment_readers;
create policy "owner manages comment membership" on public.kakao_comment_readers
  for all to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create table if not exists public.kakao_schedule_comments (
  id text primary key references public.schedules(id) on delete cascade,
  source text not null default 'kakao' check (source = 'kakao'),
  comments jsonb not null default '[]'::jsonb check (jsonb_typeof(comments) = 'array'),
  comments_complete boolean not null default false,
  synced_at timestamptz not null
);
alter table public.kakao_schedule_comments enable row level security;
revoke all on public.kakao_schedule_comments from anon, authenticated;
grant select, insert, update, delete on public.kakao_schedule_comments to authenticated;
drop policy if exists "members read kakao comments" on public.kakao_schedule_comments;
create policy "members read kakao comments" on public.kakao_schedule_comments
  for select to authenticated using (
    lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com'
    or exists (select 1 from public.kakao_comment_readers r where r.user_id = (select auth.uid()))
  );
drop policy if exists "owner writes kakao comments" on public.kakao_schedule_comments;
create policy "owner writes kakao comments" on public.kakao_schedule_comments
  for all to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

-- One completion record per Kakao sync
create table if not exists public.kakao_sync_state (
  id text primary key check (id = 'kakao'),
  last_collected_at timestamptz not null,
  completed_at timestamptz not null default now(),
  schedule_count integer not null check (schedule_count >= 0),
  batch_fingerprint text not null check (length(batch_fingerprint) = 64)
);
alter table public.kakao_sync_state enable row level security;
revoke all on public.kakao_sync_state from anon, authenticated;
grant select on public.kakao_sync_state to anon, authenticated;
grant insert, update on public.kakao_sync_state to authenticated;
drop policy if exists "public reads kakao sync state" on public.kakao_sync_state;
create policy "public reads kakao sync state" on public.kakao_sync_state for select using (true);
drop policy if exists "owner inserts kakao sync state" on public.kakao_sync_state;
create policy "owner inserts kakao sync state" on public.kakao_sync_state for insert to authenticated
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');
drop policy if exists "owner updates kakao sync state" on public.kakao_sync_state;
create policy "owner updates kakao sync state" on public.kakao_sync_state for update to authenticated
  using (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com')
  with check (lower((select auth.jwt() ->> 'email')) = 'harminis@gmail.com');

create or replace function public.record_kakao_sync(p_collected_at timestamptz, p_schedule_count integer, p_fingerprint text)
returns public.kakao_sync_state language plpgsql security invoker set search_path = '' as $$
declare recorded public.kakao_sync_state;
begin
  if lower(coalesce((select auth.jwt() ->> 'email'), '')) <> 'harminis@gmail.com' then
    raise exception 'Owner login required' using errcode = '42501';
  end if;
  select * into recorded from public.kakao_sync_state where id = 'kakao';
  if recorded.last_collected_at = p_collected_at and recorded.batch_fingerprint = p_fingerprint then
    return recorded;
  end if;
  insert into public.kakao_sync_state(id,last_collected_at,schedule_count,batch_fingerprint)
    values ('kakao',p_collected_at,p_schedule_count,p_fingerprint)
  on conflict(id) do update set
    last_collected_at = excluded.last_collected_at, completed_at = now(),
    schedule_count = excluded.schedule_count, batch_fingerprint = excluded.batch_fingerprint
  where public.kakao_sync_state.last_collected_at < excluded.last_collected_at
  returning * into recorded;
  if not found then raise exception 'A newer Kakao sync has already completed'; end if;
  return recorded;
end;
$$;
revoke all on function public.record_kakao_sync(timestamptz,integer,text) from public, anon;
grant execute on function public.record_kakao_sync(timestamptz,integer,text) to authenticated;

-- Kakao RSVP source and homepage choices
alter table public.schedules add column if not exists kakao_attendee_ids text[];
alter table public.schedules add column if not exists kakao_absentee_ids text[];
alter table public.schedules add column if not exists absentee_ids text[] not null default '{}';
create table if not exists public.schedule_rsvp_overrides (
  schedule_id text not null references public.schedules(id) on delete cascade,
  member_id text not null references public.members(id) on delete cascade,
  state text not null check(state in ('attending','declined','pending')),
  primary key(schedule_id,member_id)
);
alter table public.schedule_rsvp_overrides enable row level security;
revoke all on public.schedule_rsvp_overrides from anon,authenticated;
grant select on public.schedule_rsvp_overrides to anon,authenticated;
grant insert,update,delete on public.schedule_rsvp_overrides to authenticated;
drop policy if exists "public reads rsvp overrides" on public.schedule_rsvp_overrides;
create policy "public reads rsvp overrides" on public.schedule_rsvp_overrides for select using(true);
drop policy if exists "owner manages rsvp overrides" on public.schedule_rsvp_overrides;
create policy "owner manages rsvp overrides" on public.schedule_rsvp_overrides for all to authenticated
using(lower((select auth.jwt()->>'email'))='harminis@gmail.com')
with check(lower((select auth.jwt()->>'email'))='harminis@gmail.com');
insert into public.schedule_rsvp_overrides select d.schedule_id,d.member_id,'declined'
from public.schedule_declines d join public.schedules s on s.id=d.schedule_id where s.source='kakao' and s.kakao_attendee_ids is null on conflict do nothing;

create or replace function public.resolve_schedule_rsvp() returns trigger language plpgsql security invoker set search_path='' as $$
begin
  if new.source='kakao' and new.kakao_attendee_ids is not null then
    -- Existing homepage editors write attendee_ids. Convert only their delta
    -- into explicit choices; source importers write the kakao_* columns.
    if tg_op='UPDATE' and new.kakao_attendee_ids is not distinct from old.kakao_attendee_ids
       and new.kakao_absentee_ids is not distinct from old.kakao_absentee_ids
       and new.attendee_ids is distinct from old.attendee_ids then
      insert into public.schedule_rsvp_overrides(schedule_id,member_id,state)
      select new.id,id,case when id=any(new.attendee_ids) then 'attending' else 'pending' end
      from ((select unnest(new.attendee_ids) id except select unnest(old.attendee_ids))
            union (select unnest(old.attendee_ids) except select unnest(new.attendee_ids))) changed
      on conflict(schedule_id,member_id) do update set state=excluded.state;
    end if;
    select coalesce(array_agg(distinct member_id order by member_id),'{}') into new.attendee_ids from (
      select unnest(new.kakao_attendee_ids) member_id
      except select o.member_id from public.schedule_rsvp_overrides o where o.schedule_id=new.id
      union select o.member_id from public.schedule_rsvp_overrides o where o.schedule_id=new.id and state='attending'
    ) a;
    select coalesce(array_agg(distinct member_id order by member_id),'{}') into new.absentee_ids from (
      select unnest(coalesce(new.kakao_absentee_ids,'{}')) member_id
      except select o.member_id from public.schedule_rsvp_overrides o where o.schedule_id=new.id
      union select o.member_id from public.schedule_rsvp_overrides o where o.schedule_id=new.id and state='declined'
    ) a;
  end if;
  return new;
end $$;
drop trigger if exists resolve_schedule_rsvp on public.schedules;
create trigger resolve_schedule_rsvp before insert or update on public.schedules for each row execute function public.resolve_schedule_rsvp();
update public.schedules set kakao_attendee_ids=attendee_ids where source='kakao' and kakao_attendee_ids is null;

create or replace function public.set_schedule_rsvp(p_schedule_id text,p_member_id text,p_state text)
returns public.schedules language plpgsql security invoker set search_path='' as $$
declare result public.schedules;
begin
  if lower(coalesce((select auth.jwt()->>'email'),'')) <> 'harminis@gmail.com' then
    raise exception 'Owner login required' using errcode='42501';
  end if;
  select * into result from public.schedules where id=p_schedule_id and source='kakao' for update;
  if not found then raise exception 'Kakao schedule not found'; end if;
  if p_state is null then
    delete from public.schedule_rsvp_overrides where schedule_id=p_schedule_id and member_id=p_member_id;
  else
    insert into public.schedule_rsvp_overrides(schedule_id,member_id,state) values(p_schedule_id,p_member_id,p_state)
    on conflict(schedule_id,member_id) do update set state=excluded.state;
  end if;
  update public.schedules set kakao_attendee_ids=kakao_attendee_ids where id=p_schedule_id returning * into result;
  return result;
end $$;
revoke all on function public.resolve_schedule_rsvp() from public,anon,authenticated;
revoke all on function public.set_schedule_rsvp(text,text,text) from public,anon;
grant execute on function public.set_schedule_rsvp(text,text,text) to authenticated;
