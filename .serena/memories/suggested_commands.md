# 개발 명령어 가이드

## 서버 실행
```bash
bin/rails server                    # 개발 서버 시작 (기본 포트 3000)
```

## 테스트
```bash
bin/rails test                      # 전체 테스트 실행
bin/rails test:units                # 단위 테스트만
bin/rails test:functionals          # 기능 테스트만
bin/rails test:system               # 시스템 테스트만 (Capybara + Selenium)
bin/rails test test/unit/issue_test.rb        # 특정 파일 테스트
bin/rails test test/unit/issue_test.rb:42     # 특정 줄 테스트
```

## 린팅 / 코드 품질
```bash
bundle exec rubocop                 # Ruby 코드 스타일 검사
bundle exec rubocop --parallel      # 병렬 실행 (CI에서 사용)
bundle exec rubocop -a              # 자동 수정 가능한 것 수정
npx stylelint "app/assets/stylesheets/**/*.css"  # CSS 린팅
bundle exec bundle audit check --update          # 보안 취약점 검사
```

## 데이터베이스
```bash
bin/rails db:migrate                # 마이그레이션 실행
bin/rails db:seed                   # 시드 데이터 로드
bin/rails redmine:load_default_data # Redmine 기본 설정 데이터 로드
bin/rails db:rollback               # 마지막 마이그레이션 롤백
```

## Docker / 배포
```bash
docker build -t redmine .           # Docker 이미지 빌드
kamal deploy                        # Kamal로 배포
```

## 유틸리티 (macOS/Darwin)
```bash
git status                          # Git 상태 확인
git log --oneline -10               # 최근 커밋 10개 확인
bundle install                      # gem 설치
yarn install                        # Node.js 의존성 설치
```

## 에셋
```bash
bin/rails assets:precompile         # 에셋 프리컴파일
```
