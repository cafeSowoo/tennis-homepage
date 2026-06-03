# Kakao Schedule Automation - Visible Row Baseline

Date: 2026-05-27  
Automation id: `automation-4`  
Automation name: `카카오톡 테니스 일정 업데이트 - visible-row`  
Status: stable-ish baseline  

## Purpose

Use the KakaoTalk `아직도 성장중🎾🎾` schedule tab as the source of truth, while
avoiding the fragile collect-then-reopen workflow. Each currently visible future
schedule row is snapshotted and processed immediately.

## Notes

- Comments are intentionally skipped.
- The `discussions` table is not read or written.
- A visible row must pass detail identity verification before it can become
  `verified`.
- Only `verified` schedules are compared with and written to Supabase.
- `unresolved` schedules are reported but not written.
- This prompt is a restore point for the app-side automation, not a runnable
  script.

## Prompt

```md
# 카카오톡 테니스 일정 업데이트 - visible row 즉시 처리

목표: 카카오톡 `아직도 성장중🎾🎾` 채팅방의 일정 탭을 원본으로 보고, 오늘 포함 미래 테니스 일정을 Supabase에 반영한다. 댓글은 수집하지 않는다.

## 원칙

- 카카오톡 Mac 앱의 `아직도 성장중🎾🎾` 채팅방에서만 작업한다.
- 일정 탭을 열기 전과 각 상세 화면을 열기 전 현재 채팅방 제목이 `아직도 성장중🎾🎾`인지 확인한다.
- 로컬 파일, JSON, 코드, UI, asset, Netlify는 수정하지 않는다.
- Supabase DB만 업데이트한다.
- `discussions` 테이블은 조회/수정하지 않는다.
- 댓글은 열람하거나 수집하지 않는다.
- 날짜 기준은 실행 시각의 `Asia/Seoul` 오늘 포함 미래 일정이다.
- 연도가 없는 날짜는 2026년으로 해석한다.

## 핵심 방식

카카오톡 일정 목록은 가상화되어 있으므로, 전체 후보를 먼저 수집한 뒤 다시 찾아 클릭하지 않는다.

각 일정은 현재 화면에 보이는 순간 바로 처리한다.

반복 흐름:

1. 일정 목록에서 현재 화면에 보이는 미래 일정 row 하나를 고른다.
2. 그 row의 보이는 텍스트를 `row snapshot`으로 기록한다.
   - 날짜
   - 시작/종료 시간
   - 장소/코트 텍스트
   - 일정명 일부
3. 바로 그 visible row를 연다.
4. 상세 화면의 날짜/시간/장소가 `row snapshot`과 일치하는지 확인한다.
5. 일치하면 `verified`로 처리한다.
6. 일치하지 않으면 `unresolved: row-target mismatch`로 기록하고 DB 반영 대상에서 제외한다.
7. 목록으로 돌아가 다음 visible 미래 일정 row를 처리한다.
8. 아래로 계속 스크롤하며 반복한다.
9. `게시물 저장주기 안내` 등 목록 끝 안내가 보이고 새 일정이 더 이상 없으면 상세 확인을 종료한다.

저장된 row index, 접근성 row 순번, 과거 좌표는 재사용하지 않는다.

## verified 처리

상세 identity가 row snapshot과 일치한 일정만 verified가 될 수 있다.

verified 일정에서는 아래를 확인한다.

- 일정명
- 날짜
- 시작/종료 시간
- 원본 장소 텍스트
- 테니스장
- 몇 코트인지
- 참가자 수
- 참가자 명단

## unresolved 처리

아래 경우 해당 일정은 unresolved로 기록하고 DB 반영하지 않는다.

- 상세 화면이 row snapshot과 일치하지 않음
- 참석자 팝오버 헬퍼 실패
- 코트 번호가 있는데 `court_units`에 매핑 불가
- 테니스장 자체를 `courts`에 매핑 불가
- 카카오톡 UI 접근 불가
- Supabase 조회/쓰기 실패

unresolved가 있어도 다음 일정으로 계속 진행한다.

## 코트 매핑

장소/일정명/본문에서 테니스장과 코트 단위를 분리한다.

- `새아침 4번코트`, `새아침 4번`, `새아침 4코트` -> `court_id=court-newmorning`, `court_unit_id=court-newmorning-4`
- `새아침3`, `새아침 3`, `새아침 3코트` -> `court_id=court-newmorning`, `court_unit_id=court-newmorning-3`
- `달빛 12번코트`, `달빛공원 12번`, `달빛 12코트` -> `court_id=court-moonlight`, `court_unit_id=court-moonlight-12`
- `달빛축제 B`, `달빛축제 B코트`, `달빛축제공원 B` -> `court_id=court-moonlight-festival`, `court_unit_id=court-moonlight-festival-b`
- `만석 A`, `만석동 A코트` -> `court_id=court-manseok`, `court_unit_id=court-manseok-a`
- `제이필드 D`, `제이필드 1977 D코트` -> `court_id=court-jfield`, `court_unit_id=court-jfield-d`

장소에 테니스장만 있고 코트 번호가 없으면 `court_id`만 저장하고 `court_unit_id`는 비운다.

장소에 코트 번호가 있는데 매핑할 수 없으면 unresolved 처리한다.

## 참석자 확인

참가자가 0명이 아닌 verified 일정은 반드시 참석자 명단을 확인한다.

참석자 명단 확인은 아래 헬퍼만 사용한다.

`/Users/dorm/coding/kakao-attendee-popup/open-kakao-attendees.zsh`

헬퍼 결과가 아래 중 하나면 성공으로 본다.

- `attendee popover opened`
- `attendee popover already open`

성공하면 팝오버 안의 참석자 명단을 읽는다.

헬퍼가 실패하면 해당 일정은 `unresolved: 참석자 헬퍼 실패`로 기록하고 DB 반영하지 않는다.

일반 클릭, 접근성 클릭, 고정 좌표 클릭으로 참석자 팝오버를 따로 시도하지 않는다.

## DB 반영

목록 끝까지 처리한 뒤, verified 일정만 Supabase와 비교한다.

사용 테이블:

- `schedules`
- `members`
- `courts`
- `court_units`

사용하지 않는 테이블:

- `discussions`

기존 일정은 우선 아래 기준으로 찾는다.

`date + start/end time + court_id + court_unit_id`

`court_unit_id`가 없으면:

`date + start/end time + court_id + 원본 장소 텍스트`

변경분만 최소 범위로 반영한다.

참가자 명단은 기존 DB와 비교해 추가/삭제/변경분만 반영한다.

카카오톡 일정이 아닌 로컬/개인 일정은 삭제하거나 수정하지 않는다.

예:

- `독서모임`
- `연세 테니스장`

## 종료 보고

작업 종료 후 보고한다.

- 처리한 visible row 수
- verified 개수
- unresolved 개수와 목록
- skipped 개수와 목록
- 변경된 일정
- 이전 값과 새 값
- 코트/코트 단위 매핑 결과
- 참가자 변경 내역
- 수정한 Supabase 테이블
- 댓글 수집 생략 사실
- 검증 결과
- 다음 실행에서 참고할 memory.md 내용

unresolved가 있으면 `전체 미래 일정 점검 완료`라고 말하지 않는다.

대신:

`검증 완료 항목 반영, unresolved 항목 남음`

이라고 보고한다.

변경사항이 없으면 `변경 없음`이라고 명확히 보고한다.
```

