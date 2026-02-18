# 코드베이스 구조

## 주요 디렉터리

### app/
- **controllers/** (57개): HTTP 요청 처리
  - 주요: issues, projects, users, wiki, timelog, repositories, settings 등
  - 특수: webhooks, reactions, oauth2_applications, twofa 등
- **models/** (80+개): 비즈니스 로직 및 데이터
  - 핵심: Issue, Project, User, TimeEntry, Wiki, Document, Repository
  - 쿼리: IssueQuery, ProjectQuery, UserQuery, TimeEntryQuery, ProjectAdminQuery
  - 커스텀필드: 엔티티별 커스텀 필드 모델 다수
  - 기타: Webhook, Reaction, Token, Import 등
- **views/**: ERB 템플릿
- **helpers/**: 뷰 헬퍼 메서드
- **javascript/controllers/**: Stimulus 컨트롤러
  - gantt/, api_key_copy, list_autofill, quote_reply, sticky_issue_header
- **assets/**: 폰트, 이미지, CSS, JS
- **jobs/**: 백그라운드 잡
- **validators/**: 커스텀 밸리데이터

### lib/redmine/
- 핵심 라이브러리 코드 (모듈화)
- access_control, plugin, hook, menu_manager, wiki_formatting 등
- scm/ (SCM 어댑터), twofa/ (2FA), export/ (내보내기)

### config/
- routes.rb (Doorkeeper 포함)
- database.yml (멀티 DB 지원)
- locales/ (30+ 언어)

### test/
- unit/, functional/, integration/, system/
- fixtures/ (테스트 데이터)
- helpers/, controllers/, models/

### plugins/
- 독립적 MVC 구조의 플러그인

### themes/
- alternate, classic 테마 포함

### db/migrate/
- 200+ 마이그레이션 파일

### .github/
- workflows/: tests.yml, linters.yml, deploy.yml
- dependabot.yml
- PULL_REQUEST_TEMPLATE.md
