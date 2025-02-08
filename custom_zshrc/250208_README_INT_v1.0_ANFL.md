# ANFL ZSH Configuration System

## Overview

The ANFL ZSH Configuration System provides a comprehensive shell environment for the Aeon Nova Future Labs framework. It follows the ANFL style guide and implements a modular, secure, and maintainable shell configuration.

## Components

### Core Components

1. **Shell Main** (250208_SHELL_MAIN_INT_v1.0_ANFL.zsh)
   - Main entry point for the ZSH configuration
   - Coordinates component loading and initialization
   - Manages environment setup

2. **Error Handler** (250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh)
   - Error state management
   - Error tracking and logging
   - Error recovery mechanisms

3. **Logging System** (250208_LOGGING_INT_v1.0_ANFL.zsh)
   - Structured logging with severity levels
   - Log rotation and management
   - Log file organization

4. **Core Environment** (250208_CORE_ENV_INT_v1.0_ANFL.zsh)
   - Environment variable management
   - Directory structure validation
   - Environment state tracking

### Security Components

5. **Security Framework** (250208_SECURITY_INT_v1.0_ANFL.zsh)
   - Security state management
   - Permission validation
   - Security audit logging

6. **Vault Handler** (250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh)
   - HashiCorp Vault integration
   - Secrets management
   - Token and policy management

### Operational Components

7. **Deployment Handler** (250208_DEPLOY_HANDLER_INT_v1.0_ANFL.zsh)
   - Component deployment management
   - Deployment verification
   - Rollback capabilities

8. **Monitoring Integration** (250208_MONITOR_INT_v1.0_ANFL.zsh)
   - Prometheus/Grafana integration
   - Metrics collection
   - Health checks

### Utility Components

9. **Aliases** (250208_ALIASES_INT_v1.0_ANFL.zsh)
   - Framework command shortcuts
   - Navigation aliases
   - Common operation aliases

10. **Functions** (250208_FUNCTIONS_INT_v1.0_ANFL.zsh)
    - Utility functions
    - Helper operations
    - Common tasks automation

## Directory Structure

```
custom_zshrc/
├── 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
├── 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
├── 250208_LOGGING_INT_v1.0_ANFL.zsh
├── 250208_CORE_ENV_INT_v1.0_ANFL.zsh
├── 250208_SECURITY_INT_v1.0_ANFL.zsh
├── 250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh
├── 250208_DEPLOY_HANDLER_INT_v1.0_ANFL.zsh
├── 250208_MONITOR_INT_v1.0_ANFL.zsh
├── 250208_ALIASES_INT_v1.0_ANFL.zsh
└── 250208_FUNCTIONS_INT_v1.0_ANFL.zsh
```

## Usage

### Installation

1. Clone the repository:
```bash
git clone https://github.com/AeonNovaFutureLabs/AeonNovaFutureLabs.git
```

2. Add to your .zshrc:
```bash
# ANFL Framework
export ANFL_ROOT="/Volumes/mattstack/VSCode/AeonNovaFutureLabs"
source "${ANFL_ROOT}/custom_zshrc/250208_SHELL_MAIN_INT_v1.0_ANFL.zsh"
```

### Common Commands

```bash
# Get framework status
anfl-status

# View framework help
anfl-help

# Navigate to framework directories
anfl-root    # Go to framework root
anfl-src     # Go to source directory
anfl-docs    # Go to documentation

# Deploy components
anfl-deploy [component]

# Monitor system
anfl-monitor
anfl-metrics

# Security operations
anfl-secure
anfl-vault

# View logs
anfl-logs [error|deploy|security]
```

## Security

- All configuration files follow ANFL security standards
- Sensitive operations require appropriate permissions
- Vault integration for secrets management
- Comprehensive audit logging

## Monitoring

- Integration with Prometheus/Grafana
- System metrics collection
- Component health monitoring
- Performance tracking

## Maintenance

### Log Management

```bash
# Clean old logs
anfl-clean-logs [days]

# View specific logs
anfl-error-logs
anfl-deploy-logs
anfl-security-logs
```

### Backup Operations

```bash
# Create backup
anfl-backup

# Restore from backup
anfl-restore [backup_file]
```

## Development

### Adding New Components

1. Follow ANFL naming convention:
   ```
   [YYMMDD][TYPE][AUDIENCE]_[VERSION]_ANFL.zsh
   ```

2. Include standard header:
   ```bash
   # ----------------------------------------------------------------------------
   # File: [filename]
   # Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
   #
   # Purpose: [description]
   # Security Level: Confidential
   # Owner: [team]
   # Version: [version]
   # Last Modified: [date]
   # ----------------------------------------------------------------------------
   ```

3. Follow modular structure:
   - Configuration section
   - Core functions
   - Helper functions
   - Exports

### Testing

```bash
# Run framework tests
anfl-test

# Generate test coverage
anfl-coverage

# Run linting
anfl-lint
```

## References

- ANFL Style Guide
- Framework Documentation
- Security Standards
- Monitoring Guidelines

## Support

For issues or questions:
1. Check framework logs
2. Run health checks
3. Review documentation
4. Contact infrastructure team

## Version History

- v1.0 (2025-02-08): Initial release
  - Core framework components
  - Security integration
  - Monitoring setup
  - Utility functions