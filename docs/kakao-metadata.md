# 카카오 일정 메타데이터

2026-09-12 구현. 수집기 위치:
`/Users/dorm/Documents/ChatGPT/웹쫀쿠/tools/kakao-tennis-schedules`.
홈페이지와 별도 Git 저장소이며 두 폴더의 변경은 자동 동기화되지 않는다.

- `schedules.kakao_creator_name`: 게시물 `owner_id`를 NTUser로 해석한 이름.
  예약/진행 담당자 `host_id`는 변경하지 않는다.
- `kakao_comment_count`, `kakao_deeplink`, `kakao_synced_at`: 공개 가능한 메타데이터.
  시각은 작업 실행 시간이 아니라 상세 응답의 HTTP Date이다.
- `kakao_schedule_comments`: 일정별 댓글 스냅샷. 본문, 작성자 이름/원본 ID,
  댓글 ID, 작성 시각을 보존한다. 기존 공개 `discussions`에 복제하지 않는다.
- 전체 댓글 수와 고유 ID 수가 일치하고 `has_more_comments=false`인 스냅샷만
  삭제를 반영한다. 일부 페이지만 있으면 기존 댓글을 합쳐 보존한다.
  이전 확인 시각의 데이터로 최신 데이터를 덮어쓰지 않는다.
- 원문 댓글은 읽기 전용이며 홈페이지 댓글은 카카오톡에 전송되지 않는다.
  HTML은 이스케이프하며 이모티콘은 대체 텍스트로 표시한다.

## 열람 권한

카카오 댓글은 서버 RLS로 보호한다. 비로그인 요청은 테이블 권한이 없고,
Google 로그인만 한 미등록 계정은 행을 읽지 못한다. 기존 관리자 계정은
열람/동기화가 가능하다. 승인된 회원은 `kakao_comment_readers`에 실제
`auth.users.id`와 해당 회원의 `members.id`를 등록해야 읽을 수 있다.
회원 이름이나 클라이언트 프로필 선택만으로 권한을 부여하지 않는다.
등록 회원은 읽기만 가능하며, 권한 등록은 관리자만 할 수 있다.

댓글은 브라우저 메모리에만 보관하고 로그아웃/계정 변경 즉시 비운다.
정적 JSON, localStorage, Service Worker 캐시에 저장하지 않는다.

## 운영

기존 `bin/kakao-schedule sync`가 개설자·댓글·링크를 함께 비교한다.
보호된 댓글 비교를 위해 읽기 단계부터 저장된 Supabase 로그인을 사용한다.
실제 쓰기는 기존 최종 확인 절차를 유지한다. 댓글 변경은 비교 보고서에서
`entity_type=kakao_comments`로 구분하며 재실행은 중복 생성하지 않는다.

초기 반영은 2026-09-11 14:31 수집 보고서의 25개 일정과 로컬 상세 캐시를
연결한 메타데이터 전용 작업이다. 일정 날짜/시간/참석자/Host는 변경하지 않았다.
불참 명단과 댓글 내용에서 추론한 양도/정산 상태는 이번 범위에 포함하지 않는다.

## 검증

- 수집기: `python3 -m unittest discover -s tests -q`
- DB: `begin;` 뒤 `supabase/tests/kakao_comments_access.sql`을 실행하고
  반드시 `rollback;`한다. 관리자/회원/미등록/비로그인 권한을 검사하며 실제
  댓글 내용을 출력하지 않는다.
- 브라우저: 공개 화면의 메타데이터, 댓글 HTML 이스케이프, 읽기 전용 출처,
  로그아웃 시 메모리 제거, 모바일 줄바꿈을 검사한다.
