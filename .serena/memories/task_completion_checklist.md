# 작업 완료 시 체크리스트

작업을 완료한 후 다음 항목을 확인해야 합니다:

## 1. 코드 스타일 검사
```bash
bundle exec rubocop                 # Ruby 코드 스타일 검사
```
- 변경한 파일에서 위반 사항이 없는지 확인
- `# frozen_string_literal: true` 헤더가 포함되어 있는지 확인 (db/ 파일 제외)

## 2. CSS 스타일 검사 (CSS 파일 변경 시)
```bash
npx stylelint "app/assets/stylesheets/**/*.css"
```

## 3. 테스트 실행
```bash
bin/rails test                      # 전체 테스트 (기본)
```
- 변경 범위에 따라 적절한 테스트 범위 선택
- 새 기능 추가 시 관련 테스트도 작성

## 4. 보안 검사 (gem 변경 시)
```bash
bundle exec bundle audit check --update
```

## 5. Git 커밋
- 커밋 메시지는 변경 내용을 명확히 기술
- 관련 이슈 번호 포함 (있는 경우)

## CI 파이프라인 (GitHub Actions)
- **tests.yml**: 테스트 실행
- **linters.yml**: RuboCop, Stylelint, bundle-audit 실행
- **deploy.yml**: 배포 (Kamal)
