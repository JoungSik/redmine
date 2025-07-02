# Redmine Project Overview

This is a Redmine project - a web-based project management and issue tracking tool built with Ruby on Rails.

## Project Structure

### Core Application (`app/`)
- **Controllers**: Handle HTTP requests and application logic
- **Models**: Define data structures and business logic
- **Views**: Render HTML templates and user interfaces
- **Helpers**: Provide view-specific utility methods
- **Assets**: Contains fonts, images, and JavaScript files
- **Jobs**: Background job processing classes

### Configuration (`config/`)
- **Database**: Database configuration files (database.yml)
- **Routes**: URL routing definitions (routes.rb)
- **Environments**: Environment-specific settings (development, production, test)
- **Initializers**: Application initialization scripts
- **Locales**: Internationalization files for multiple languages

### Database (`db/`)
- **Migrations**: Database schema version control files
- Over 200 migration files showing the evolution of the database schema

### Testing (`test/`)
- **Unit Tests**: Model and library testing
- **Functional Tests**: Controller testing
- **Integration Tests**: Full application workflow testing
- **System Tests**: Browser-based end-to-end testing
- **Fixtures**: Test data definitions

### Additional Directories
- **lib/**: Core Redmine library code and rake tasks
- **plugins/**: Plugin system for extending functionality
- **themes/**: UI theme customization
- **public/**: Static web assets
- **files/**: File storage location
- **extra/**: Additional utilities and sample configurations

## Key Features
- Issue tracking and project management
- Multi-language support (30+ languages)
- Plugin architecture for extensibility
- Repository integration (Git, SVN, Mercurial, etc.)
- Time tracking
- Wiki functionality
- User management and permissions
- Email integration

## Current Status
- Repository is clean (no uncommitted changes)
- Main branch: master
- Recent commits focus on bug fixes and improvements
- Well-maintained with regular updates