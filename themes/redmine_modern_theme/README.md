# Redmine Modern Theme

Redmine에 다크모드를 추가하는 경량 플러그인입니다. Open Color 디자인 시스템 기반의 세련된 다크 테마를 제공하며, OS 설정 연동을 지원합니다.

![Redmine](https://img.shields.io/badge/Redmine-Plugin-red)
![License](https://img.shields.io/badge/License-GPL--3.0-blue)
![Version](https://img.shields.io/badge/Version-0.1.0-green)

## 주요 기능

- **다크모드 테마** - Open Color 변수 체계를 활용한 전체 UI 다크 테마
- **3가지 모드 지원** - 자동(OS 설정 연동), 항상 다크, 항상 라이트
- **전체 컴포넌트 커버리지** - 테이블, 폼, 모달, 에디터, 간트차트, 캘린더 등
- **모바일 반응형** - 900px 이하 화면에 대한 반응형 스타일
- **다국어 지원** - 한국어, 영어

## 설치

```bash
cd /path/to/redmine/plugins
git clone https://github.com/JoungSik/redmine_modern_theme.git
```

Redmine을 재시작하면 설치가 완료됩니다. 별도의 마이그레이션이나 gem 설치는 필요하지 않습니다.

## 설정

1. **관리** > **플러그인** 에서 Redmine Modern Theme의 **설정** 클릭
2. 테마 모드 선택:
   - **자동** - OS의 다크/라이트 모드 설정을 따름 (기본값)
   - **항상 다크** - 항상 다크 테마 적용
   - **항상 라이트** - Redmine 기본 테마 사용

## 호환성

- Redmine 5.x 이상
- CSS Custom Properties를 지원하는 모던 브라우저

## 라이선스

이 프로젝트는 [GNU General Public License v3.0](LICENSE) 하에 배포됩니다.

## 작성자

[JoungSik](https://github.com/JoungSik)
