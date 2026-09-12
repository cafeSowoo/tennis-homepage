-- Run inside a transaction and roll back. Uses no real comment content.
insert into public.schedules (id,date,day,time,title,source)
values ('kakao-access-test','2099-01-01','목','09:00-11:00','Access test','kakao');
insert into public.kakao_schedule_comments (id,comments,comments_complete,synced_at)
values ('kakao-access-test','[{"id":"test","message":"private fixture"}]',true,now());

set local role anon;
do $$ begin
  begin
    perform 1 from public.kakao_schedule_comments;
    raise exception 'FAIL: anon can query private comments';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;

set local role authenticated;
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000099","email":"nonmember@example.invalid"}',true);
do $$ begin
  if exists(select 1 from public.kakao_schedule_comments) then
    raise exception 'FAIL: nonmember can read comments';
  end if;
  begin
    insert into public.kakao_comment_readers(user_id) values ('00000000-0000-0000-0000-000000000099');
    raise exception 'FAIL: nonmember can grant membership';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;

-- Reuse an existing auth identity inside this rolled-back test only.
insert into public.kakao_comment_readers(user_id) select id from auth.users order by id limit 1
on conflict do nothing;
select set_config('request.jwt.claims',json_build_object('sub',(select id from auth.users order by id limit 1),'email','member@example.invalid')::text,true);
set local role authenticated;
do $$ begin
  if not exists(select 1 from public.kakao_schedule_comments where id='kakao-access-test') then
    raise exception 'FAIL: approved member cannot read comments';
  end if;
  update public.kakao_schedule_comments set comments='[]' where id='kakao-access-test';
  if found then raise exception 'FAIL: member can modify comments'; end if;
  delete from public.kakao_schedule_comments where id='kakao-access-test';
  if found then raise exception 'FAIL: member can delete comments'; end if;
end $$;
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000099","email":"harminis@gmail.com"}',true);
do $$ begin
  update public.kakao_schedule_comments set comments_complete=false where id='kakao-access-test';
  if not found then raise exception 'FAIL: owner cannot update comments'; end if;
  delete from public.kakao_schedule_comments where id='kakao-access-test';
  if not found then raise exception 'FAIL: owner cannot delete comments'; end if;
end $$;
reset role;
