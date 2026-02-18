# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Redmine - Ruby on Rails 기반의 프로젝트 관리 및 이슈 추적 웹 애플리케이션 (GPL v2).

- **Ruby** 3.4.1 (>= 3.2.0, < 3.5.0) / **Rails** 8.0.4
- **DB**: MySQL, PostgreSQL, SQLite3, SQL Server
- **Frontend**: ERB 뷰 + Stimulus (importmap-rails) + jQuery
- **Asset Pipeline**: Propshaft
- **테스트**: Minitest + Mocha + Capybara + Selenium (RSpec 아님)
- **배포**: Docker (GHCR) + GitHub Actions

## 주요 명령어

```bash
# 서버
bin/rails server

# 테스트
bin/rails test                                    # 전체
bin/rails test:units                              # 단위 테스트
bin/rails test:functionals                        # 기능 테스트
bin/rails test:integration                        # 통합 테스트
bin/rails test:system                             # 시스템 테스트 (Capybara)
bin/rails test test/unit/issue_test.rb            # 특정 파일
bin/rails test test/unit/issue_test.rb:42         # 특정 줄

# 린팅
bundle exec rubocop                               # Ruby 코드 스타일
bundle exec rubocop --parallel                    # 병렬 실행
npx stylelint "app/assets/stylesheets/**/*.css"   # CSS 린팅
bundle exec bundle audit check --update           # 보안 취약점

# DB
bin/rails db:migrate
bin/rails redmine:load_default_data
```

## 아키텍처 핵심 패턴

### 권한 시스템 (Permission & Access Control)

`lib/redmine/preparation.rb`에서 `Redmine::AccessControl.map`으로 모든 권한을 선언적으로 정의. 권한은 `project_module` 블록으로 모듈별 그룹화됨.

```ruby
map.project_module :issue_tracking do |map|
  map.permission :view_issues, {:issues => [:index, :show]}, :read => true
  map.permission :add_issues, {:issues => [:new, :create]}
end
```

컨트롤러에서 `before_action :authorize` 또는 `before_action :require_admin`으로 권한 확인. API 액세스는 `accept_api_auth :index, :show` 매크로로 선언.

### Query 시스템

`Query` (app/models/query.rb)가 기본 클래스. `IssueQuery`, `ProjectQuery`, `UserQuery`, `TimeEntryQuery` 등이 상속. 각 Query 클래스는 `available_columns`, `available_filters`를 정의하여 목록 화면의 필터링/정렬/그룹화를 제어. `QueryColumn` 객체가 정렬 가능 여부, 그룹화 가능 여부 등을 캡슐화.

### Custom Field 시스템

`CustomField` 모델 + `Redmine::FieldFormat` 모듈로 동작. 엔티티별 커스텀 필드 서브클래스 존재 (`IssueCustomField`, `ProjectCustomField` 등). `CustomValue`가 실제 값을 저장. `Redmine::FieldFormat`에 포맷별 싱글턴 인스턴스가 등록됨.

### Hook 시스템

`Redmine::Hook`을 통해 플러그인이 코어 동작에 개입. `Redmine::Hook::Listener`를 상속한 Singleton 클래스로 구현. 뷰에서 `call_hook(:hook_name, context)` 호출.

### Plugin 시스템

`Redmine::Plugin.register :name do ... end`으로 등록. `plugins/` 디렉터리에 독립적 MVC 구조. 자체 마이그레이션, 에셋, 로케일 파일 포함 가능. `config/initializers/30-redmine.rb`에서 `Redmine::PluginLoader.load` 호출로 로드.

### SafeAttributes

`Redmine::SafeAttributes` 모듈로 사용자 권한에 따른 mass-assignment 제어. `safe_attributes` 매크로로 조건부 허용 속성 선언:
```ruby
safe_attributes 'title', 'pages'
safe_attributes 'isbn', :if => {|book, user| book.author == user}
```

### ApplicationController 필터 체인

`before_action` 순서: `session_expiration` → `user_setup` → `check_if_login_required` → `set_localization` → `check_password_change` → `check_twofa_activation`

### acts_as 패턴

`Redmine::Acts::Positioned` (정렬), `Redmine::Acts::Mentionable` (@멘션)이 `ApplicationRecord`에 포함됨 (`lib/redmine/preparation.rb`).

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

- **linters.yml**: RuboCop (병렬), Stylelint, bundle-audit
- **tests.yml**: 테스트 실행
- **deploy.yml**: Docker 빌드 → GHCR push → Slack 알림
