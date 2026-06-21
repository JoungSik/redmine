# AGENTS.md

This file provides shared guidance to Codex, Claude Code, and other coding agents when working with code in this repository.

## 기본 작업 규칙

- 항상 한국어로 응답한다. 코드, 명령어, 파일명, 경로, API 이름, 로그는 명확성을 위해 원문을 유지한다.
- 커밋이나 push는 사용자가 명시적으로 요청한 경우에만 수행한다.
- `git push --force`는 사용하지 않는다. 히스토리 갱신이 필요한 경우에도 `git push --force-with-lease`만 사용한다.
- commit message는 본문 없이 한 줄로 작성한다: `git commit -m "<type>: <Korean summary>"`.
- 변경은 작고 집중적으로 유지한다. 관련 없는 refactor나 metadata churn은 피한다.
- Ruby/Rails 테스트는 Minitest 기준으로 작성하고, 기존 Redmine 패턴을 우선한다.

## MCP 자동 호출 규칙

### Redmine

- 프로젝트 ID: `1`
- 프로젝트 identifier: `redmine`
- 프로젝트 URL: https://redmine.joungsik.com/projects/redmine
- 상위 프로젝트: Home (ID: `15`)
- 이슈 검색/조회 시 `project_id` 파라미터에 `1` 또는 `redmine` 사용

## 프로젝트 개요

Redmine - Ruby on Rails 기반의 프로젝트 관리 및 이슈 추적 웹 애플리케이션 (GPL v2).

- **Ruby** 3.4.1 (>= 3.2.0, < 4.1.0) / **Rails** 8.1.3
- **DB**: MySQL, PostgreSQL, SQLite3, SQL Server
- **Frontend**: ERB 뷰 + Stimulus (importmap-rails) + jQuery
- **Asset Pipeline**: Propshaft
- **테스트**: Minitest + Mocha + Capybara + Selenium (RSpec 아님)
- **배포**: Docker + Kamal

## 주요 명령어

```bash
# 서버
bin/rails server

# 테스트
bin/rails test
bin/rails test:units
bin/rails test:functionals
bin/rails test:integration
bin/rails test:system
bin/rails test test/unit/issue_test.rb
bin/rails test test/unit/issue_test.rb:42
bin/rails test:autoload

# CI와 같은 기준의 전체 테스트
TZ=UTC bin/rails test
GOOGLE_CHROME_OPTS_ARGS=headless,disable-gpu,no-sandbox,disable-dev-shm-usage bin/rails test:system

# 린팅/보안
bundle exec rubocop --parallel
npx stylelint "app/assets/stylesheets/**/*.css"
bundle exec bundle audit check --update

# DB
bin/rails db:migrate
RAILS_ENV=test bin/rails db:migrate
bin/rails redmine:load_default_data
```

## Redmine Upstream 동기화 프로세스

이 저장소는 `redmine/master`를 원본 upstream 코드로 두고, 커스텀 배포 브랜치는 `origin/main`으로 운영한다. upstream 반영 시 기준은 `origin/master`가 아니라 반드시 `redmine/master`다.

### Rebase를 기본으로 선택하는 이유

- 목적이 "upstream 위에 커스텀 변경을 커밋 단위로 명확하게 검토"하는 것이라면 rebase가 merge보다 적합하다.
- merge는 공개 히스토리 보존이 최우선일 때 유리하지만, 커스텀 commit을 upstream 최신 commit 위에 선형으로 재배치해 검토하려는 목적에는 부적합하다.
- force push가 허용된 작업에서는 `--force-with-lease`를 사용해 `origin/main`을 갱신한다.

### 표준 절차

1. 최신 remote ref를 가져온다.

```bash
git fetch --all --prune
```

2. 현재 상태와 divergence를 확인한다.

```bash
git status --short --branch
git merge-base origin/main redmine/master
git rev-list --left-right --count origin/main...redmine/master
git log --reverse --oneline redmine/master..origin/main
git log --oneline --decorate --max-count=10 redmine/master
```

3. `origin/main`을 직접 건드리지 말고 작업 브랜치를 만든다.

```bash
git switch -c rebase/redmine-master-YYYYMMDD origin/main
```

4. `redmine/master` 위로 커스텀 commit을 rebase한다.

```bash
git rebase redmine/master
```

5. 충돌이 나면 파일별로 upstream 변경과 커스텀 의도를 비교해 해결한다.

- upstream 구조 변경, Rails/Ruby API 변경: upstream을 우선한다.
- 커스텀 기능: Docker, PWA, cronjob, 배포/CI 설정, 테마는 유지한다.
- 보안/CVE 대응 gem: 더 안전한 패치 버전을 선택한다.
- 자동 생성 파일: `Gemfile.lock`, `db/schema.rb`, `.rubocop_todo.yml`은 rebase 후 명령으로 재생성하거나 보정한다.
- 충돌 해결 후 `git add <file>` → `git rebase --continue`를 반복한다.
- `git rebase --skip`은 커스텀 commit을 버릴 수 있으므로 사용 전 반드시 사용자 확인을 받는다.

6. rebase 결과를 커밋 단위로 검증한다.

```bash
git status --short --branch
git rev-list --left-right --count redmine/master...HEAD
git log --reverse --oneline redmine/master..HEAD
git range-diff "$(git merge-base origin/main redmine/master)"..origin/main redmine/master..HEAD
git diff --check redmine/master..HEAD
```

정상적인 결과는 `redmine/master...HEAD` 기준으로 left가 `0`, right가 커스텀 commit 수가 되는 것이다.

7. 의존성과 자동 생성 파일을 보정한다.

```bash
bundle install
RAILS_ENV=test bin/rails db:migrate
bundle check
```

`bundle audit`가 최신 advisory 기준으로 실패하면 전체 update를 하지 말고 취약 대상 gem만 제한적으로 갱신한다.

```bash
bundle update erb faraday jwt net-imap oauth2 puma
```

실제 대상 gem은 `bundle audit` 출력에 맞춰 조정한다.

8. rebase 보정 변경을 정리한다.

- 기존 커스텀 commit 중 `fix: rebase 후 CI 통과...`처럼 rebase 보정용 commit이 있으면 해당 commit에 amend하는 것을 우선한다.
- 없다면 별도 commit으로 만든다: `git commit -m "fix: redmine upstream rebase 보정"`.
- 빈 파일이 RuboCop `Lint/EmptyFile`에 걸리고 참조가 없으면 삭제한다.
- `db/schema.rb`는 새 upstream migration을 test DB에 적용한 결과라면 함께 반영한다.

9. CI 기준 검증을 실행한다.

```bash
bundle check
bundle exec rubocop --parallel
TZ=UTC bin/rails test
bin/rails test:autoload
npx stylelint "app/assets/stylesheets/**/*.css"
bundle exec bundle audit check --update
```

system test는 CI Ubuntu/Chrome 환경과 로컬 macOS/headless Chrome 환경의 clipboard 및 keyboard shortcut 동작이 다를 수 있다. 로컬에서 실패하면 실패 범위가 환경 의존인지 구분해 기록한다.

```bash
GOOGLE_CHROME_OPTS_ARGS=headless,disable-gpu,no-sandbox,disable-dev-shm-usage bin/rails test:system
```

10. 사용자 확인 후 원격 `main`을 갱신한다.

```bash
git push origin HEAD:main --force-with-lease
```

11. push 후 로컬 `main`을 원격과 맞춘다.

```bash
git branch -f main origin/main
git switch main
git status --short --branch
git rev-parse main origin/main
```

## 이번 rebase 작업에서 확인된 기준

- `redmine/master` 위에 커스텀 commit 10개를 유지하는 형태가 정상이다.
- `origin/main`에 force-with-lease push 후에는 로컬 `main`도 `origin/main`으로 포인터를 맞춰야 한다.
- `TZ=UTC bin/rails test`를 사용해야 CI와 같은 시간대 기준으로 날짜/시간 테스트가 동작한다.
- sandbox 또는 로컬 macOS 환경에서는 `127.0.0.1` bind, clipboard, command/control key 동작 때문에 일부 테스트가 CI와 다르게 실패할 수 있다.

## 아키텍처 핵심 패턴

### 권한 시스템 (Permission & Access Control)

`lib/redmine/preparation.rb`에서 `Redmine::AccessControl.map`으로 모든 권한을 선언적으로 정의한다. 권한은 `project_module` 블록으로 모듈별 그룹화된다.

```ruby
map.project_module :issue_tracking do |map|
  map.permission :view_issues, {:issues => [:index, :show]}, :read => true
  map.permission :add_issues, {:issues => [:new, :create]}
end
```

컨트롤러에서 `before_action :authorize` 또는 `before_action :require_admin`으로 권한을 확인한다. API 액세스는 `accept_api_auth :index, :show` 매크로로 선언한다.

### Query 시스템

`Query` (`app/models/query.rb`)가 기본 클래스다. `IssueQuery`, `ProjectQuery`, `UserQuery`, `TimeEntryQuery` 등이 상속한다. 각 Query 클래스는 `available_columns`, `available_filters`를 정의하여 목록 화면의 필터링/정렬/그룹화를 제어한다. `QueryColumn` 객체가 정렬 가능 여부, 그룹화 가능 여부 등을 캡슐화한다.

### Custom Field 시스템

`CustomField` 모델과 `Redmine::FieldFormat` 모듈로 동작한다. 엔티티별 커스텀 필드 서브클래스가 존재한다 (`IssueCustomField`, `ProjectCustomField` 등). `CustomValue`가 실제 값을 저장한다. `Redmine::FieldFormat`에 포맷별 싱글턴 인스턴스가 등록된다.

### Hook 시스템

`Redmine::Hook`을 통해 플러그인이 코어 동작에 개입한다. `Redmine::Hook::Listener`를 상속한 Singleton 클래스로 구현한다. 뷰에서 `call_hook(:hook_name, context)`를 호출한다.

### Plugin 시스템

`Redmine::Plugin.register :name do ... end`로 등록한다. `plugins/` 디렉터리에 독립적 MVC 구조를 둘 수 있다. 자체 migration, asset, locale 파일을 포함할 수 있다. `config/initializers/30-redmine.rb`에서 `Redmine::PluginLoader.load` 호출로 로드한다.

### SafeAttributes

`Redmine::SafeAttributes` 모듈로 사용자 권한에 따른 mass-assignment를 제어한다. `safe_attributes` 매크로로 조건부 허용 속성을 선언한다.

```ruby
safe_attributes 'title', 'pages'
safe_attributes 'isbn', :if => {|book, user| book.author == user}
```

### ApplicationController 필터 체인

`before_action` 순서: `session_expiration` → `user_setup` → `check_if_login_required` → `set_localization` → `check_password_change` → `check_twofa_activation`

### acts_as 패턴

`Redmine::Acts::Positioned` (정렬), `Redmine::Acts::Mentionable` (@멘션)이 `ApplicationRecord`에 포함된다 (`lib/redmine/preparation.rb`).

## 코드 스타일

- **frozen_string_literal**: 모든 Ruby 파일 상단에 필수 (`db/`, `Gemfile`, `Rakefile` 제외)
- **RuboCop**: `.rubocop.yml` 설정 준수. Metrics 규칙 비활성화. `rubocop-performance`, `rubocop-rails` 플러그인 사용
- **Hash 문법**: `no_mixed_keys`, shorthand는 `either`
- **파일 헤더**: GPL 라이선스 주석 포함 (기존 파일과 동일한 형식)
- **i18n**: `config/locales/`에 번역 키 정의. 모델에서 `l(:key)` 또는 `Redmine::I18n` 모듈 사용

## 테스트 패턴

- `fixtures :all` 사용 (전체 fixture 로드)
- `with_settings(key: value) { ... }` - 설정 임시 변경
- `with_current_user(user) { ... }` - 사용자 컨텍스트 전환
- `@request.session[:user_id] = 2` - 기능 테스트에서 로그인
- `set_tmp_attachments_directory` - 첨부파일 테스트용 임시 디렉터리
- Mocha로 목킹: `require 'mocha/minitest'`
- `Setting.clear_cache` - 각 테스트 후 자동 호출 (teardown)

## CI (GitHub Actions)

- **linters.yml**: RuboCop (`bundle exec rubocop --parallel`), Stylelint, bundle-audit
- **tests.yml**: `bin/rails test`, Bazaar non-ASCII test, `bin/rails test:autoload`, system test
- **deploy.yml**: Kamal 배포
