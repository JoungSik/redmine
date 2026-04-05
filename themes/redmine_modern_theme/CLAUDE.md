# Redmine Modern Theme

Redmine에 다크모드를 추가하는 경량 플러그인. Open Color 디자인 시스템 기반의 다크 테마를 제공하며, OS 설정 연동(auto), 항상 다크, 항상 라이트 3가지 모드를 지원한다.

## 프로젝트 구조

- `init.rb` - 플러그인 등록 및 설정 정의
- `lib/redmine_modern_theme/hooks.rb` - Redmine 뷰 훅으로 스타일시트 주입
- `assets/stylesheets/modern_theme.css` - Open Color 변수 기반 다크 테마 CSS
- `app/views/hooks/` - 조건부 스타일시트 로딩 (auto/dark/light)
- `app/views/settings/` - 관리자 설정 UI
- `config/locales/` - 다국어(ko, en) 번역 파일

## 커밋 규칙

- 커밋 메세지는 반드시 한 줄로 작성한다 (본문 없이 제목만)
