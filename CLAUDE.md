# Redmine Project Overview

This is a Redmine project - a flexible web-based project management and issue tracking tool built with Ruby on Rails framework.

## Technology Stack

- **Ruby**: >= 3.2.0, < 3.5.0
- **Rails**: 7.2.2.1
- **Database**: Supports MySQL, PostgreSQL, SQLite3, SQL Server
- **Frontend**: Rails views with Stimulus, jQuery, and custom JavaScript
- **Styling**: CSS with responsive design support
- **Testing**: Rails test framework with unit, functional, integration, and system tests

## Project Structure

### Core Application (`app/`)
- **Controllers** (`app/controllers/`): Handle HTTP requests and application logic (40+ controllers)
- **Models** (`app/models/`): Define data structures and business logic (50+ models)
- **Views** (`app/views/`): Render HTML templates and user interfaces with comprehensive partials
- **Helpers** (`app/helpers/`): Provide view-specific utility methods
- **Assets** (`app/assets/`): Contains fonts, images, stylesheets, and JavaScript files
- **Jobs** (`app/jobs/`): Background job processing classes
- **JavaScript** (`app/javascript/`): Stimulus controllers for interactive components
- **Validators** (`app/validators/`): Custom validation classes

### Configuration (`config/`)
- **Database**: Database configuration files (database.yml)
- **Routes**: URL routing definitions (routes.rb)
- **Environments**: Environment-specific settings (development, production, test)
- **Initializers**: Application initialization scripts
- **Locales**: Internationalization files for 30+ languages

### Database (`db/`)
- **Migrations**: Database schema version control files
- Over 200 migration files showing the evolution of the database schema from early versions

### Testing (`test/`)
- **Unit Tests**: Model and library testing
- **Functional Tests**: Controller testing
- **Integration Tests**: Full application workflow testing
- **System Tests**: Browser-based end-to-end testing with Capybara
- **Fixtures**: Test data definitions

### Additional Directories
- **lib/**: Core Redmine library code and rake tasks
- **plugins/**: Plugin system for extending functionality
- **themes/**: UI theme customization (alternate and classic themes included)
- **public/**: Static web assets and PWA manifest
- **files/**: File storage location for attachments
- **extra/**: Additional utilities and sample configurations

## Key Features

### Core Functionality
- **Issue Tracking**: Comprehensive bug tracking and task management with custom fields
- **Project Management**: Multi-project support with flexible permissions and roles
- **Time Tracking**: Track time spent on projects and issues with detailed reporting
- **Wiki**: Built-in wiki functionality for project documentation
- **Repository Integration**: Support for Git, SVN, Mercurial, CVS, Bazaar, and filesystem repositories
- **Document Management**: File and document sharing with version control

### Advanced Features
- **Multi-language Support**: Available in 30+ languages with full i18n support
- **Plugin Architecture**: Extensible through plugins with dedicated plugin directory
- **Email Integration**: Email notifications, issue creation via email, and mail handling
- **User Management**: Flexible user and role-based permission system with groups
- **Search**: Full-text search across projects, issues, wiki, and documents
- **API**: RESTful API with JSON and XML support
- **Two-Factor Authentication**: TOTP-based 2FA with backup codes
- **OAuth2**: OAuth2 provider capabilities with Doorkeeper gem

### UI/UX Features
- **Responsive Design**: Mobile-friendly interface
- **Themes**: Customizable themes and styling
- **Gantt Charts**: Project timeline visualization
- **Calendar Views**: Issue and project calendar views
- **Contextual Menus**: Right-click context menus for quick actions
- **Progressive Web App**: PWA support with service worker

## Development Guidelines

### Code Quality
- **Linting**: RuboCop for Ruby code style enforcement
- **Security**: Bundle-audit for dependency vulnerability scanning
- **Testing**: Comprehensive test suite with high coverage requirements

### Development Commands
```bash
# Run tests
rails test                    # All tests
rails test:units             # Unit tests only
rails test:functionals       # Functional tests only
rails test:system           # System tests only

# Code quality
bundle exec rubocop         # Code style check
bundle exec bundle-audit    # Security audit

# Development server
rails server                # Start development server
```

### Database Operations
```bash
rails db:migrate            # Run migrations
rails db:seed               # Load seed data
rails redmine:load_default_data  # Load Redmine default configuration
```

## Architecture Notes

### MVC Pattern
- Follows Rails MVC architecture with clear separation of concerns
- Controllers handle HTTP requests and delegate to models
- Models encapsulate business logic and data access
- Views render templates with helper methods for presentation logic

### Plugin System
- Plugins extend core functionality without modifying core files
- Located in `plugins/` directory with their own MVC structure
- Can include assets, migrations, and locale files

### Security
- CSRF protection enabled
- SQL injection protection through ActiveRecord
- XSS protection through output escaping
- Role-based access control (RBAC) system
- Secure password handling with bcrypt

## Current Status
- Repository is clean (no uncommitted changes)
- Main branch: master
- Recent commits focus on bug fixes and improvements
- Well-maintained with regular updates
- Production-ready with extensive test coverage