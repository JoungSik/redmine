# Redmine 프로젝트 개요

## 목적
Redmine은 Ruby on Rails 기반의 유연한 웹 프로젝트 관리 및 이슈 추적 도구입니다.

## 기술 스택
- **Ruby**: 3.4.1 (>= 3.2.0, < 3.5.0)
- **Rails**: 8.0.4
- **Frontend**: Stimulus (importmap-rails), jQuery, 커스텀 JavaScript
- **CSS**: 순수 CSS (Stylelint으로 린팅)
- **Asset Pipeline**: Propshaft
- **DB 지원**: MySQL, PostgreSQL, SQLite3, SQL Server
- **배포**: Docker (GHCR) + GitHub Actions
- **테스트**: Rails 기본 테스트 프레임워크 + Mocha + Capybara + Selenium
- **인증**: Doorkeeper (OAuth2), TOTP 2FA, LDAP
- **백그라운드 잡**: Rails ActiveJob
- **스케줄러**: Whenever (cron)

## 주요 기능
- 이슈 추적 및 프로젝트 관리
- 시간 추적 및 보고
- Wiki, 문서 관리
- Git/SVN 등 저장소 통합
- 다국어 지원 (30+ 언어)
- 플러그인 아키텍처
- RESTful API (JSON/XML)
- OAuth2 제공자
- PWA 지원
- Webhook 지원
- 리액션 기능

## 라이선스
GNU General Public License v2
