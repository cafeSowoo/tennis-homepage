-- Run inside BEGIN / ROLLBACK, including migration first on an empty schema.
insert into public.members(id,name) values ('rsvp-test-a','Test A'),('rsvp-test-b','Test B');
insert into public.schedules(id,date,day,time,title,source,kakao_attendee_ids,kakao_absentee_ids)
values ('kakao-rsvp-test','2099-01-01','목','09:00-11:00','RSVP test','kakao',array['rsvp-test-a'],array['rsvp-test-b']);
set local role authenticated;
select set_config('request.jwt.claims','{"email":"harminis@gmail.com"}',true);
do $$ declare r public.schedules;
begin
  r := public.set_schedule_rsvp('kakao-rsvp-test','rsvp-test-a','declined');
  if cardinality(r.attendee_ids)<>0 or cardinality(r.absentee_ids)<>2 then raise exception 'decline failed'; end if;
  update public.schedules set kakao_attendee_ids=array['rsvp-test-a','rsvp-test-b'],kakao_absentee_ids='{}' where id='kakao-rsvp-test' returning * into r;
  if r.attendee_ids<>array['rsvp-test-b'] or r.absentee_ids<>array['rsvp-test-a'] then raise exception 'source overwrote homepage'; end if;
  r := public.set_schedule_rsvp('kakao-rsvp-test','rsvp-test-a',null);
  if cardinality(r.attendee_ids)<>2 or cardinality(r.absentee_ids)<>0 then raise exception 'follow source failed'; end if;
  update public.schedules set attendee_ids=array['rsvp-test-a'] where id='kakao-rsvp-test';
  update public.schedules set kakao_attendee_ids=array['rsvp-test-a','rsvp-test-b'] where id='kakao-rsvp-test' returning * into r;
  if r.attendee_ids<>array['rsvp-test-a'] then raise exception 'pending overwritten'; end if;
  update public.schedules set attendee_ids=array['rsvp-test-a','rsvp-test-b'] where id='kakao-rsvp-test';
  update public.schedules set kakao_attendee_ids='{}',kakao_absentee_ids=array['rsvp-test-a','rsvp-test-b'] where id='kakao-rsvp-test' returning * into r;
  if not ('rsvp-test-b'=any(r.attendee_ids)) or 'rsvp-test-b'=any(r.absentee_ids) then raise exception 'homepage attending lost'; end if;
end $$;
select set_config('request.jwt.claims','{"email":"outsider@example.invalid"}',true);
do $$ begin
  begin
    perform public.set_schedule_rsvp('kakao-rsvp-test','rsvp-test-a','declined');
    raise exception 'unauthorized write accepted';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;
