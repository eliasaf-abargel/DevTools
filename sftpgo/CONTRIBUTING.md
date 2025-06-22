# Contributing to SFTPGo Docker Deployment

Thank you for your interest in contributing to this project! This guide will help you get started.

## Development Setup

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/sftpgo.git
   cd sftpgo
   ```

3. **Set up development environment**
   ```bash
   ./scripts/setup.sh
   ```

## Making Changes

### Before You Start
- Check existing issues and pull requests
- Create an issue to discuss major changes
- Follow the existing code style

### Development Workflow
1. Create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes
3. Test your changes
   ```bash
   ./scripts/manage.sh test-sftp
   ./scripts/backup.sh
   ./scripts/restore.sh backups/test_backup.tar.gz
   ```

4. Commit your changes
   ```bash
   git add .
   git commit -m "Add feature: description"
   ```

5. Push to your fork
   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a Pull Request

## Guidelines

### Code Style
- Use clear, descriptive variable names
- Add comments for complex logic
- Follow shell scripting best practices
- Use consistent indentation (2 spaces)

### Documentation
- Update README.md for new features
- Add inline comments for scripts
- Update QUICKSTART.md if needed

### Testing
- Test all scripts before submitting
- Verify Docker Compose configuration
- Test backup and restore functionality

## Types of Contributions

### Bug Fixes
- Clear description of the problem
- Steps to reproduce
- Proposed solution

### Feature Additions
- Description of the feature
- Use case explanation
- Implementation approach

### Documentation
- Typo fixes
- Clarity improvements
- Missing information

### Security
- Report security issues privately
- Follow responsible disclosure

## Pull Request Process

1. **Description**: Clearly describe what your PR does
2. **Testing**: Describe how you tested the changes
3. **Documentation**: Update docs if needed
4. **Breaking Changes**: Clearly mark any breaking changes

## Code Review

- All PRs require review
- Address feedback promptly
- Be open to suggestions
- Maintain a professional tone

## Questions?

- Open an issue for questions
- Check existing documentation first
- Be specific about your environment

Thank you for contributing! 🎉
