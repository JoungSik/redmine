# Upstream Sync

Redmine upstream(redmine/redmine)의 최신 변경사항을 fork 저장소에 동기화한다.

## 실행 순서

### 1. 상태 확인 및 분석

```bash
git fetch redmine
```

merge-base를 기준으로 upstream과 커스텀 커밋 수를 확인한다.

```bash
MERGE_BASE=$(git merge-base HEAD redmine/master)
echo "Upstream 새 커밋: $(git rev-list --count $MERGE_BASE..redmine/master)"
echo "커스텀 커밋: $(git rev-list --count $MERGE_BASE..HEAD)"
```

충돌 가능성이 있는 파일을 사전 분석한다.

```bash
git diff --name-only $MERGE_BASE..redmine/master > /tmp/upstream_files.txt
git diff --name-only $MERGE_BASE..HEAD > /tmp/custom_files.txt
comm -12 <(sort /tmp/upstream_files.txt) <(sort /tmp/custom_files.txt)
```

### 2. 사용자에게 분석 결과 보고

분석 결과를 표 형태로 보여준다:
- upstream 새 커밋 수
- 커스텀 커밋 목록 (git log --oneline)
- 충돌 가능 파일 목록 (양쪽 모두 수정한 파일)

사용자가 진행을 확인한 후에만 다음 단계로 넘어간다.

### 3. 백업 및 rebase 실행

```bash
git branch backup/main-before-sync-$(date +%Y%m%d)
git rebase redmine/master
```

### 4. 충돌 해결 원칙

충돌이 발생하면 다음 원칙에 따라 해결한다:

| 유형 | 전략 | 예시 |
|------|------|------|
| upstream 구조 변경 (버전 업, API 변경) | upstream 채택 | rails, ruby 버전 |
| 커스텀 보안 수정 (CVE) | 더 높은 버전 채택 | nokogiri, rack |
| 커스텀 전용 기능 | 커스텀 유지 | Docker, PWA, cronjob, ArgoCD, CI |
| 자동 생성 파일 | rebase 후 재생성 | .rubocop_todo.yml, Gemfile.lock |

**Gemfile 충돌 해결 세부 원칙:**
- gem 버전: upstream과 커스텀 중 더 높은 버전 채택
- CVE 관련 gem: 반드시 패치된 버전 채택
- 커스텀 추가 gem (whenever, bootsnap, thor, rexml, uri 등): 유지
- 나머지: upstream 버전 따름

**주의:** 각 충돌 파일을 해결한 후 `git add <파일>` → `git rebase --continue` 반복한다.

### 5. 후처리

rebase 완료 후 자동 생성 파일을 재생성한다:

```bash
bundle install                            # Gemfile.lock 재생성
bundle exec rubocop --regenerate-todo     # .rubocop_todo.yml 재생성
RAILS_ENV=test bin/rails db:migrate       # 새 마이그레이션 적용
```

중복 gem이 없는지 Gemfile을 검수한다.
변경된 파일을 별도 커밋으로 추가한다.

### 6. 검증

```bash
bin/rails test                             # 전체 테스트
bundle exec rubocop --parallel             # 린트
bundle exec bundle-audit check --update    # 보안 취약점
git log --oneline redmine/master..HEAD     # 커스텀 커밋 수 유지 확인
```

모든 검증을 통과해야 다음 단계로 진행한다.

### 7. Force Push

반드시 사용자의 명시적 확인을 받은 후 실행한다.

```bash
git push origin main --force-with-lease
```

## Red Flags

### 하지 말 것
- 사용자 확인 없이 force push 하지 않는다
- upstream의 커스텀 전용 파일(Docker, CI, PWA 등)을 덮어쓰지 않는다
- CVE 패치된 gem을 낮은 버전으로 되돌리지 않는다
- `git rebase --skip`으로 커스텀 커밋을 건너뛰지 않는다
- 충돌 해결 시 한쪽만 일괄 선택(--ours/--theirs)하지 않는다

### 반드시 할 것
- rebase 전에 백업 브랜치를 생성한다
- 충돌 파일별로 내용을 분석하고 원칙에 따라 해결한다
- 후처리(bundle install, rubocop regenerate)를 빠뜨리지 않는다
- 테스트/린트/보안 점검을 모두 통과한 후에만 push한다
- 커스텀 커밋 수가 유지되는지 확인한다
