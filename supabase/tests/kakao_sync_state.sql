-- Execute within BEGIN / ROLLBACK. No real schedules are modified.
delete from public.kakao_sync_state;
set local role authenticated;
select set_config('request.jwt.claims','{"email":"member@example.invalid"}',true);
do $$ begin
  begin
    perform public.record_kakao_sync('2026-09-12T01:00:00Z',24,repeat('a',64));
    raise exception 'FAIL: non-owner can write sync state';
  exception when insufficient_privilege then null;
  end;
end $$;
select set_config('request.jwt.claims','{"email":"harminis@gmail.com"}',true);
do $$ declare first_run public.kakao_sync_state; second_run public.kakao_sync_state;
begin
  first_run := public.record_kakao_sync('2026-09-12T01:00:00Z',24,repeat('a',64));
  second_run := public.record_kakao_sync('2026-09-12T01:00:00Z',24,repeat('a',64));
  if first_run.completed_at <> second_run.completed_at then raise exception 'FAIL: retry changed completion'; end if;
  begin
    perform public.record_kakao_sync('2026-09-11T01:00:00Z',23,repeat('b',64));
    raise exception 'FAIL: older source replaced sync state';
  exception when raise_exception then
    if sqlerrm not like 'A newer Kakao sync%' then raise; end if;
  end;
  if (select count(*) from public.kakao_sync_state) <> 1 then raise exception 'FAIL: duplicate sync rows'; end if;
end $$;
reset role;
set local role anon;
do $$ begin
  if not exists(select 1 from public.kakao_sync_state where schedule_count=24) then raise exception 'FAIL: sync state not publicly readable'; end if;
  begin
    perform public.record_kakao_sync('2026-09-12T02:00:00Z',24,repeat('c',64));
    raise exception 'FAIL: anonymous RPC allowed';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;
