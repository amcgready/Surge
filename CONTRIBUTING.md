# Contributing to Surge

We welcome contributions to the Surge project! This document provides guidelines for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain a positive community environment

## How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use issue templates** when available
3. **Provide detailed information**:
   - Operating system and version
   - Docker/Docker Compose versions
   - Configuration details (remove sensitive data)
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs

### Suggesting Features

1. **Check the roadmap** to see if it's already planned
2. **Open a feature request** with:
   - Clear description of the feature
   - Use case and benefits
   - Proposed implementation (if you have ideas)
   - Potential drawbacks or considerations

### Contributing Code

#### Setting Up Development Environment

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Surge.git
   cd Surge
   ```

3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Test your changes**:
   ```bash
   # Test deployment
   ./scripts/deploy.sh plex
   
   # Test updates
   ./scripts/update.sh
   
   # Test maintenance functions
   ./scripts/maintenance.sh status
   ```

#### Code Standards

- **Shell scripts**: Follow bash best practices
  - Use `set -e` for error handling
  - Quote variables properly
  - Include error checking
  - Add comments for complex logic

- **Docker Compose**: 
  - Use consistent formatting
  - Include proper labels and metadata
  - Follow security best practices
  - Test with multiple configurations

- **Documentation**:
  - Update relevant docs for any changes
  - Use clear, concise language
  - Include examples where helpful
  - Test all documented procedures

#### Pull Request Process

1. **Ensure tests pass**:
   ```bash
   # Test deployment with different media servers
   ./scripts/deploy.sh plex
   ./scripts/deploy.sh jellyfin
   ./scripts/deploy.sh emby
   
   # Test update process
   ./scripts/update.sh
   
   # Test maintenance commands
   ./scripts/maintenance.sh health
   ```

2. **Update documentation** if needed

3. **Create pull request** with:
   - Clear title and description
   - Reference related issues
   - List of changes made
   - Testing performed
   - Screenshots (if UI changes)

4. **Address review feedback** promptly

## Development Guidelines

### Adding New Services

When adding a new service to Surge:

1. **Research the service**:
   - Official Docker image availability
   - Resource requirements
   - Configuration complexity
   - Integration capabilities

2. **Update Docker Compose**:
   - Add service definition
   - Include proper volumes and networks
   - Set appropriate profiles
   - Add health checks if available

3. **Update configuration**:
   - Add to `.env.example`
   - Update homepage configuration
   - Add service-specific config templates

4. **Update documentation**:
   - Add to README service list
   - Update quick start guide
   - Add troubleshooting section

5. **Test thoroughly**:
   - Fresh deployment
   - Service integration
   - Update process
   - Backup/restore

### Updating Existing Services

1. **Test with current configuration**
2. **Check for breaking changes**
3. **Update documentation** if needed
4. **Test migration path** for existing users

### Security Considerations

- **Never commit secrets** or credentials
- **Use environment variables** for configuration
- **Follow least privilege** principle
- **Keep images updated** regularly
- **Review third-party images** for security

## Testing

### Manual Testing Checklist

- [ ] Fresh deployment with Plex
- [ ] Fresh deployment with Jellyfin  
- [ ] Fresh deployment with Emby
- [ ] Minimal deployment option
- [ ] Update from previous version
- [ ] Service restart/reset
- [ ] Log viewing functionality
- [ ] Backup/restore process
- [ ] Permission handling
- [ ] Network connectivity between services

### Automated Testing

We're working on automated testing. Contributions welcome!

## Documentation

### Types of Documentation

1. **User Documentation**:
   - Installation guides
   - Configuration examples
   - Troubleshooting steps
   - Best practices

2. **Developer Documentation**:
   - Architecture overview
   - Contributing guidelines
   - API documentation
   - Testing procedures

### Documentation Standards

- **Use clear headings** and structure
- **Include code examples** with proper syntax highlighting
- **Add screenshots** for UI-related instructions
- **Keep it up-to-date** with code changes
- **Use consistent formatting** and style

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community chat
- **Pull Requests**: Code review and collaboration

### Getting Help

- **Check documentation** first
- **Search existing issues** and discussions
- **Ask specific questions** with relevant details
- **Be patient and respectful**

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Special thanks for major features

## License

By contributing to Surge, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Questions?

If you have questions about contributing, please:
1. Check this document
2. Search existing discussions
3. Open a new discussion with the "question" label

Thank you for contributing to Surge! 🚀
