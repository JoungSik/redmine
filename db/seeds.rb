# frozen_string_literal: true

# 개발용 더미 데이터 시드
# 사용법: REDMINE_LANG=ko bin/rails db:seed
# 주의: development 환경에서만 실행 가능

unless Rails.env.development?
  abort "이 시드는 development 환경에서만 실행할 수 있습니다. (현재: #{Rails.env})"
end

Rails.logger.info "=== Redmine 개발용 시드 데이터 생성 시작 (#{Rails.env}) ==="

# 1. 기본 데이터 로드 (트래커, 상태, 우선순위, 역할, 워크플로우 등)
lang = ENV.fetch('REDMINE_LANG', 'ko')
Object.new.extend(Redmine::I18n).set_language_if_valid(lang)

begin
  Redmine::DefaultData::Loader.load(lang)
  Rails.logger.info "기본 데이터 로드 완료 (#{lang})"
rescue Redmine::DefaultData::DataAlreadyLoaded
  Rails.logger.info "기본 데이터 이미 존재, 건너뜀"
end

# 2. 관리자 계정 확인
admin = User.find_by(login: 'admin')
if admin
  Rails.logger.info "관리자 계정 이미 존재 (admin)"
else
  admin = User.new(
    login: 'admin',
    firstname: 'Redmine',
    lastname: 'Admin',
    mail: 'admin@example.com',
    admin: true,
    status: User::STATUS_ACTIVE,
    language: lang
  )
  admin.password = 'password'
  admin.password_confirmation = 'password'
  admin.save!
  Rails.logger.info "관리자 계정 생성 (admin@example.com / password)"
end

User.current = admin

# 3. 일반 사용자 생성
users_data = [
  {login: 'developer1', firstname: '김', lastname: '개발', mail: 'dev1@example.com'},
  {login: 'developer2', firstname: '이', lastname: '코딩', mail: 'dev2@example.com'},
  {login: 'manager1',   firstname: '박', lastname: '관리', mail: 'mgr1@example.com'},
  {login: 'reporter1',  firstname: '최', lastname: '보고', mail: 'rpt1@example.com'},
  {login: 'designer1',  firstname: '정', lastname: '디자인', mail: 'des1@example.com'},
]

users = users_data.map do |data|
  user = User.find_by(login: data[:login])
  unless user
    user = User.new(data.merge(status: User::STATUS_ACTIVE, language: lang))
    user.password = 'password'
    user.password_confirmation = 'password'
    user.save!
    Rails.logger.info "사용자 생성: #{data[:login]}"
  end
  user
end

dev1, dev2, mgr1, rpt1, des1 = users

# 4. 역할 조회
role_manager   = Role.find_by(name: I18n.t(:default_role_manager))
role_developer = Role.find_by(name: I18n.t(:default_role_developer))
role_reporter  = Role.find_by(name: I18n.t(:default_role_reporter))

# 번역 키로 못 찾으면 위치 기반으로 조회
role_manager   ||= Role.sorted.where(builtin: 0).first
role_developer ||= Role.sorted.where(builtin: 0).second
role_reporter  ||= Role.sorted.where(builtin: 0).third

# 5. 트래커/상태/우선순위 조회
trackers   = Tracker.sorted.to_a
statuses   = IssueStatus.sorted.to_a
priorities = IssuePriority.active.to_a

status_new      = statuses[0]
status_progress = statuses[1]
status_resolved = statuses[2]
status_feedback = statuses[3]
status_closed   = statuses[4]

priority_normal = priorities.find(&:is_default?) || priorities[1]
priority_high   = priorities[2]
priority_urgent = priorities[3]

# 6. 프로젝트 생성
projects_data = [
  {
    name: '웹 서비스 개발',
    identifier: 'web-service',
    description: '메인 웹 서비스 백엔드/프론트엔드 개발 프로젝트',
    is_public: true
  },
  {
    name: '모바일 앱',
    identifier: 'mobile-app',
    description: 'iOS/Android 모바일 앱 개발 프로젝트',
    is_public: true
  },
  {
    name: '인프라 관리',
    identifier: 'infra',
    description: '서버, CI/CD, 모니터링 등 인프라 관리',
    is_public: false
  },
]

projects = projects_data.map do |data|
  project = Project.find_by(identifier: data[:identifier])
  unless project
    project = Project.new(data)
    project.trackers = trackers
    project.enable_module!('issue_tracking')
    project.enable_module!('time_tracking')
    project.enable_module!('news')
    project.enable_module!('wiki')
    project.enable_module!('repository')
    project.enable_module!('boards')
    project.enable_module!('calendar')
    project.enable_module!('gantt')
    project.save!
    Rails.logger.info "프로젝트 생성: #{data[:name]}"
  end
  project
end

web_project, mobile_project, infra_project = projects

# 7. 서브 프로젝트
sub_project_data = {
  name: 'API 서버',
  identifier: 'api-server',
  description: 'REST API 서버 개발',
  is_public: true,
  parent_id: web_project.id
}
sub_project = Project.find_by(identifier: 'api-server')
unless sub_project
  sub_project = Project.new(sub_project_data)
  sub_project.trackers = trackers
  sub_project.enable_module!('issue_tracking')
  sub_project.save!
  Rails.logger.info "서브 프로젝트 생성: API 서버"
end

# 8. 멤버 배정
def add_member(project, user, role)
  return if Member.find_by(project: project, user: user)

  member = Member.new(project: project, user: user)
  member.roles << role
  member.save!
end

# 웹 서비스 프로젝트
add_member(web_project, mgr1, role_manager)
add_member(web_project, dev1, role_developer)
add_member(web_project, dev2, role_developer)
add_member(web_project, rpt1, role_reporter)
add_member(web_project, des1, role_developer)
add_member(sub_project, dev1, role_developer)
add_member(sub_project, dev2, role_developer)

# 모바일 앱 프로젝트
add_member(mobile_project, mgr1, role_manager)
add_member(mobile_project, dev2, role_developer)
add_member(mobile_project, des1, role_developer)

# 인프라 프로젝트
add_member(infra_project, mgr1, role_manager)
add_member(infra_project, dev1, role_developer)

Rails.logger.info "멤버 배정 완료"

# 9. 버전 (마일스톤) 생성
versions_data = [
  {project: web_project, name: 'v1.0.0', description: '첫 번째 릴리스', status: 'open', due_date: 30.days.from_now},
  {project: web_project, name: 'v1.1.0', description: '기능 개선', status: 'open', due_date: 60.days.from_now},
  {project: web_project, name: 'v0.9.0', description: '베타 릴리스', status: 'locked', due_date: 10.days.ago},
  {project: mobile_project, name: 'v1.0.0', description: '앱 스토어 출시', status: 'open', due_date: 45.days.from_now},
]

versions = versions_data.map do |data|
  project = data.delete(:project)
  version = project.versions.find_by(name: data[:name])
  version ||= project.versions.create!(data)
  version
end
Rails.logger.info "버전 생성 완료"

web_v1, web_v11, _web_v09, mobile_v1 = versions

# 10. 이슈 카테고리
categories_data = [
  {project: web_project, name: '백엔드'},
  {project: web_project, name: '프론트엔드'},
  {project: web_project, name: 'UI/UX'},
  {project: mobile_project, name: 'iOS'},
  {project: mobile_project, name: 'Android'},
]

categories = categories_data.map do |data|
  project = data.delete(:project)
  cat = project.issue_categories.find_by(name: data[:name])
  cat || project.issue_categories.create!(data)
end
Rails.logger.info "이슈 카테고리 생성 완료"

cat_backend, cat_frontend, cat_uiux, cat_ios, cat_android = categories

# 11. 이슈 생성
bug_tracker     = trackers[0]
feature_tracker = trackers[1]
support_tracker = trackers[2]

issues_data = [
  # 웹 서비스 - 버그
  {project: web_project, tracker: bug_tracker, subject: '로그인 페이지에서 비밀번호 재설정 링크 동작 안 함',
   description: "비밀번호 재설정 링크를 클릭하면 404 에러가 발생합니다.\n\n## 재현 순서\n" \
                "1. 로그인 페이지 접속\n2. '비밀번호를 잊으셨나요?' 클릭\n3. 404 에러 페이지 표시",
   priority: priority_urgent, status: status_progress, assigned_to: dev1, category: cat_backend,
   fixed_version: web_v1, start_date: 5.days.ago, due_date: 2.days.from_now, done_ratio: 60},

  {project: web_project, tracker: bug_tracker, subject: '대시보드 차트가 Safari에서 렌더링 깨짐',
   description: "Safari 17에서 대시보드의 원형 차트가 제대로 표시되지 않습니다.",
   priority: priority_high, status: status_new, assigned_to: des1, category: cat_frontend,
   fixed_version: web_v1, start_date: 2.days.ago, due_date: 7.days.from_now, done_ratio: 0},

  {project: web_project, tracker: bug_tracker, subject: '파일 업로드 시 10MB 이상 파일에서 타임아웃 발생',
   description: "대용량 파일 업로드 시 Nginx 타임아웃이 발생합니다. 서버 설정 변경이 필요합니다.",
   priority: priority_normal, status: status_resolved, assigned_to: dev1, category: cat_backend,
   fixed_version: web_v1, done_ratio: 100},

  {project: web_project, tracker: bug_tracker, subject: '이메일 알림이 중복 발송되는 문제',
   description: "특정 조건에서 이메일 알림이 2회 발송됩니다.",
   priority: priority_high, status: status_feedback, assigned_to: dev2, category: cat_backend,
   fixed_version: web_v1, done_ratio: 80},

  # 웹 서비스 - 기능 요청
  {project: web_project, tracker: feature_tracker, subject: '다크모드 지원',
   description: "사용자 설정에서 다크모드를 선택할 수 있도록 UI 테마 기능을 추가합니다.\n\n## 요구사항\n" \
                "- OS 설정 연동 (자동)\n- 수동 전환 토글\n- 커스텀 색상 팔레트",
   priority: priority_normal, status: status_progress, assigned_to: des1, category: cat_uiux,
   fixed_version: web_v11, start_date: 3.days.ago, due_date: 20.days.from_now, done_ratio: 30},

  {project: web_project, tracker: feature_tracker, subject: '2단계 인증(2FA) 도입',
   description: "보안 강화를 위해 TOTP 기반 2단계 인증을 추가합니다.",
   priority: priority_high, status: status_new, assigned_to: dev1, category: cat_backend,
   fixed_version: web_v11, start_date: Date.today, due_date: 30.days.from_now, done_ratio: 0},

  {project: web_project, tracker: feature_tracker, subject: '사용자 활동 로그 대시보드',
   description: "관리자가 사용자 활동을 한눈에 볼 수 있는 대시보드를 추가합니다.",
   priority: priority_normal, status: status_new, category: cat_frontend,
   fixed_version: web_v11, done_ratio: 0},

  {project: web_project, tracker: feature_tracker, subject: 'REST API v2 설계',
   description: "기존 API를 개선한 v2 API를 설계합니다. OpenAPI 3.0 스펙 기반.",
   priority: priority_normal, status: status_progress, assigned_to: dev2, category: cat_backend,
   fixed_version: web_v1, start_date: 10.days.ago, due_date: 15.days.from_now, done_ratio: 50},

  # 웹 서비스 - 지원 요청
  {project: web_project, tracker: support_tracker, subject: '신규 팀원 계정 생성 요청',
   description: "마케팅팀 신규 입사자 3명의 계정을 생성해주세요.",
   priority: priority_normal, status: status_closed, assigned_to: mgr1, done_ratio: 100},

  {project: web_project, tracker: support_tracker, subject: '스테이징 환경 접속 권한 요청',
   description: "QA팀에서 스테이징 환경 접속 권한을 요청합니다.",
   priority: priority_normal, status: status_new, assigned_to: mgr1, done_ratio: 0},

  # 모바일 앱
  {project: mobile_project, tracker: bug_tracker, subject: 'iOS 푸시 알림이 간헐적으로 수신되지 않음',
   description: "APNs 토큰 갱신 로직에 문제가 있는 것으로 추정됩니다.",
   priority: priority_urgent, status: status_progress, assigned_to: dev2, category: cat_ios,
   fixed_version: mobile_v1, start_date: 3.days.ago, due_date: 5.days.from_now, done_ratio: 40},

  {project: mobile_project, tracker: bug_tracker, subject: 'Android 12에서 스플래시 화면이 두 번 표시됨',
   description: "Android 12의 새 SplashScreen API와 기존 구현이 충돌합니다.",
   priority: priority_high, status: status_new, assigned_to: dev2, category: cat_android,
   fixed_version: mobile_v1, done_ratio: 0},

  {project: mobile_project, tracker: feature_tracker, subject: '생체 인증 로그인 지원',
   description: "Face ID / Touch ID / 지문 인식을 통한 로그인 기능을 추가합니다.",
   priority: priority_normal, status: status_new, category: cat_ios,
   fixed_version: mobile_v1, done_ratio: 0},

  {project: mobile_project, tracker: feature_tracker, subject: '오프라인 모드 지원',
   description: "네트워크가 없는 환경에서도 캐시된 데이터를 볼 수 있도록 합니다.",
   priority: priority_normal, status: status_progress, assigned_to: des1,
   fixed_version: mobile_v1, start_date: 7.days.ago, due_date: 25.days.from_now, done_ratio: 20},

  # 인프라
  {project: infra_project, tracker: bug_tracker, subject: 'CI 파이프라인 빌드 시간이 15분 이상 소요',
   description: "Docker 레이어 캐싱이 제대로 동작하지 않아 빌드 시간이 길어졌습니다.",
   priority: priority_high, status: status_progress, assigned_to: dev1,
   start_date: 4.days.ago, due_date: 3.days.from_now, done_ratio: 70},

  {project: infra_project, tracker: feature_tracker, subject: 'Kubernetes 클러스터 모니터링 대시보드 구축',
   description: "Grafana + Prometheus 기반 모니터링 대시보드를 구축합니다.",
   priority: priority_normal, status: status_new, assigned_to: dev1,
   start_date: Date.today, due_date: 20.days.from_now, done_ratio: 0},

  {project: infra_project, tracker: support_tracker, subject: 'SSL 인증서 갱신 (4월 만료 예정)',
   description: "메인 도메인의 SSL 인증서가 4월에 만료됩니다. " \
                "Let's Encrypt 자동 갱신 설정을 확인해주세요.",
   priority: priority_high, status: status_new, assigned_to: dev1,
   due_date: 15.days.from_now, done_ratio: 0},
]

issues_data.each do |data|
  project = data.delete(:project)
  tracker = data.delete(:tracker)
  priority = data.delete(:priority) || priority_normal
  status = data.delete(:status) || status_new
  assigned_to = data.delete(:assigned_to)
  category = data.delete(:category)
  fixed_version = data.delete(:fixed_version)

  issue = Issue.new(data)
  issue.project = project
  issue.tracker = tracker
  issue.priority = priority
  issue.status = status
  issue.author = [admin, dev1, dev2, mgr1, rpt1, des1].sample
  issue.assigned_to = assigned_to
  issue.category = category
  issue.fixed_version = fixed_version
  issue.save!
end
Rails.logger.info "이슈 #{issues_data.size}건 생성 완료"

# 12. 이슈에 코멘트 추가
issues_with_notes = Issue.where(project: [web_project, mobile_project]).where.not(assigned_to_id: nil).limit(8)
notes_samples = [
  "확인했습니다. 내일까지 수정 예정입니다.",
  "관련 코드를 리뷰했는데, 이 부분은 리팩토링이 필요할 것 같습니다.",
  "테스트 환경에서 재현 확인했습니다. 원인을 파악 중입니다.",
  "수정 완료하고 PR 올렸습니다. 리뷰 부탁드립니다.",
  "스테이징에 배포해서 확인해봤는데 정상 동작합니다.",
  "이 기능은 다음 스프린트로 미루는 게 어떨까요?",
  "디자인 시안 첨부합니다. 피드백 부탁드립니다.",
  "성능 테스트 결과, 응답 시간이 200ms에서 50ms로 개선되었습니다.",
]

issues_with_notes.each_with_index do |issue, i|
  issue.init_journal(users.sample, notes_samples[i])
  issue.save!
end
Rails.logger.info "이슈 코멘트 추가 완료"

# 13. 위키 페이지 생성
[web_project, mobile_project].each do |project|
  wiki = project.wiki || Wiki.create!(project: project, start_page: 'Wiki')

  pages_data = [
    {title: 'Wiki',
     content: "# #{project.name} 위키\n\n프로젝트 문서 모음입니다.\n\n## 목차\n\n" \
              "- [[개발 가이드]]\n- [[배포 절차]]"},
    {title: '개발_가이드',
     content: "# 개발 가이드\n\n## 환경 설정\n\n```bash\ngit clone <repo-url>\ncd project\n" \
              "bundle install\nbin/rails db:setup\nbin/rails server\n```\n\n## 코딩 컨벤션\n\n" \
              "- Ruby Style Guide 준수\n- 테스트 커버리지 80% 이상 유지\n- PR 리뷰 필수"},
    {title: '배포_절차',
     content: "# 배포 절차\n\n## 스테이징 배포\n" \
              "1. `main` 브랜치에서 `staging` 브랜치로 머지\n" \
              "2. CI 파이프라인 통과 확인\n3. 스테이징 환경에서 QA 테스트\n\n" \
              "## 프로덕션 배포\n1. 릴리스 태그 생성\n2. 배포 스크립트 실행\n3. 헬스체크 확인"},
  ]

  pages_data.each do |data|
    page = wiki.pages.find_by(title: data[:title])
    unless page
      page = wiki.pages.new(title: data[:title])
      content = page.build_content
      content.text = data[:content]
      content.author = admin
      page.save!
    end
  end
end
Rails.logger.info "위키 페이지 생성 완료"

# 14. 뉴스 생성
news_data = [
  {project: web_project, title: 'v0.9.0 베타 릴리스 완료',
   description: "베타 버전이 릴리스되었습니다. 테스트 참여 부탁드립니다.\n\n주요 변경사항:\n" \
                "- 사용자 인증 시스템 개선\n- 대시보드 UI 리뉴얼\n- API 응답 속도 개선",
   author: mgr1},
  {project: mobile_project, title: '앱 디자인 시스템 가이드 공유',
   description: "Figma로 작성된 디자인 시스템 가이드를 공유합니다. 컴포넌트 사용 시 참고해주세요.",
   author: des1},
]

news_data.each do |data|
  project = data.delete(:project)
  unless project.news.find_by(title: data[:title])
    project.news.create!(data)
  end
end
Rails.logger.info "뉴스 생성 완료"

Rails.logger.info "=== 시드 데이터 생성 완료 ==="
Rails.logger.info "  관리자: admin@example.com / password"
Rails.logger.info "  사용자: developer1, developer2, manager1, reporter1, designer1 / password"
Rails.logger.info "  프로젝트: web-service, mobile-app, infra"
