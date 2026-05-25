Netlify production은 항상 lock 유지, 운영 배포할 때만 unlock/deploy/re-lock 원칙.

이 프로젝트의 기본 배포는 GitHub 기반이다.
사용자가 "배포", "커밋 배포", "deploy"라고만 말하면 Netlify를 절대 사용하지 않는다.
기본 배포 절차는 git commit + git push origin main 후 GitHub Pages 워크플로(`.github/workflows/pages.yml`) 완료 여부를 확인하는 것까지 포함한다.
Netlify는 사용자가 명시적으로 "Netlify에 배포"라고 요청한 경우에만 사용한다.
Netlify Git 연동을 새로 만들거나 복구하지 않는다.
`netlify link`, `netlify init`, `unlinkSiteRepo` 반대 작업 등 Netlify와 GitHub를 다시 연결하는 작업은 사용자에게 별도 확인 없이 실행하지 않는다.

Codex 앱 번들 또는 설치본을 직접 패치/수정해야 하는 경우, 작업 전에 반드시 🚨 이모티콘을 포함해 실행 불능, 업데이트 충돌, 코드서명/무결성 문제 등의 위험이 있음을 명확히 고지하고 사용자 확인을 받은 뒤 진행할 것.

새 프로젝트나 코드 작업용 폴더를 만들 때는 특별히 다른 위치를 지정하지 않는 한 항상 /Users/dorm/coding 하위에 만들어 주세요.
Documents, Downloads, Desktop에는 프로젝트 폴더를 만들지 마세요.
예: /Users/dorm/coding/project-name
