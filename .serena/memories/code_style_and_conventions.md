# 코드 스타일 및 컨벤션

## Ruby 코드 스타일 (RuboCop)
- **frozen_string_literal**: 항상 사용 (`# frozen_string_literal: true`), db/ 및 설정 파일 제외
- **Target Ruby**: 3.2+
- **Target Rails**: 7.2+
- **Metrics**: 비활성화됨 (메서드 길이 등 제한 없음)
- **Hash 문법**: `no_mixed_keys` 스타일, shorthand는 `either` 허용
- **네이밍**: AccessorMethodName, BinaryOperatorParameterName, PredicateMethod 규칙 비활성화
- **블록 구분자**: 유연함 (중괄호/do-end 혼용 가능)
- **공백**: SpaceBeforeBlockBraces, SpaceInsideBlockBraces 등 비활성화
- **줄 길이**: test 메서드명과 주석은 제외
- **EmptyElse**: `empty` 스타일 (빈 else 허용)
- **Heredoc 공백**: 허용
- **플러그인**: rubocop-performance, rubocop-rails

## CSS 스타일 (Stylelint)
- 기본 규칙 사용 (유효하지 않은 hex, 중복 속성 등 검사)
- jQuery CSS 파일은 무시

## JavaScript
- Stimulus 컨트롤러 사용 (importmap-rails)
- `app/javascript/controllers/` 디렉터리에 위치

## 파일 헤더
- 각 Ruby 파일 상단에 GPL 라이선스 주석 포함 (기존 파일에서 확인)

## 테스트 컨벤션
- Rails 기본 테스트 프레임워크 사용 (Minitest)
- RSpec이 아님
- Mocha로 목킹/스터빙
- Capybara + Selenium으로 시스템 테스트
- test/fixtures에 테스트 데이터 정의

## 프로젝트 구조 패턴
- MVC 패턴 (Rails 표준)
- 플러그인은 `plugins/` 디렉터리에 독립적 MVC 구조
- 라이브러리 코드는 `lib/redmine/` 하위에 모듈화
- Custom Field 시스템: 다양한 엔티티별 커스텀 필드 모델 존재
- Query 시스템: IssueQuery, ProjectQuery, UserQuery 등 쿼리 객체 패턴
