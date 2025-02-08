# ----------------------------------------------------------------------------
# File: 250208_ALIASES_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Framework-compliant command aliases and shortcuts
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides standardized command aliases for common ANFL framework operations

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Navigation Aliases
# -------------------------------

# Core directories
alias anfl-root="cd ${ANFL_ROOT}"
alias anfl-src="cd ${ANFL_ROOT}/src"
alias anfl-docs="cd ${ANFL_ROOT}/docs"
alias anfl-tests="cd ${ANFL_ROOT}/tests"
alias anfl-ai="cd ${ANFL_ROOT}/ai_components"
alias anfl-infra="cd ${ANFL_ROOT}/infrastructure"

# -------------------------------
# 2. Framework Commands
# -------------------------------

# Status commands
alias anfl-status="get_framework_status"
alias anfl-health="check_framework_health"
alias anfl-logs="view_framework_logs"

# Deployment commands
alias anfl-deploy="deploy_components"
alias anfl-rollback="rollback_deployment"
alias anfl-verify="verify_deployment"

# Monitoring commands
alias anfl-monitor="get_monitoring_status"
alias anfl-metrics="collect_framework_metrics"
alias anfl-dashboard="open_monitoring_dashboard"

# Security commands
alias anfl-secure="get_security_status"
alias anfl-audit="view_security_audit"
alias anfl-vault="get_vault_status"

# -------------------------------
# 3. Development Aliases
# -------------------------------

# Testing shortcuts
alias anfl-test="run_framework_tests"
alias anfl-coverage="generate_test_coverage"
alias anfl-lint="run_code_linting"

# Build shortcuts
alias anfl-build="build_framework"
alias anfl-clean="clean_build_artifacts"
alias anfl-rebuild="clean_build_artifacts && build_framework"

# -------------------------------
# 4. Utility Aliases
# -------------------------------

# Log viewing
alias anfl-error-logs="tail -f ${ANFL_LOGS}/errors/error.log"
alias anfl-deploy-logs="tail -f ${ANFL_LOGS}/deployment/*.log"
alias anfl-security-logs="tail -f ${ANFL_LOGS}/security.log"

# Configuration
alias anfl-config="edit_framework_config"
alias anfl-env="edit_environment_config"
alias anfl-paths="print_framework_paths"

# Maintenance
alias anfl-clean-logs="clean_framework_logs"
alias anfl-backup="backup_framework_data"
alias anfl-restore="restore_framework_data"

# -------------------------------
# 5. Documentation Aliases
# -------------------------------

# View documentation
alias anfl-help="show_framework_help"
alias anfl-docs="open_framework_docs"
alias anfl-examples="show_framework_examples"

# Generate documentation
alias anfl-gen-docs="generate_framework_docs"
alias anfl-update-docs="update_framework_docs"
alias anfl-check-docs="verify_documentation"

# -------------------------------
# 6. Helper Functions
# -------------------------------

# Print framework paths
function print_framework_paths() {
    print -P "%F{cyan}ANFL Framework Paths:%f"
    print -P "Root: %F{green}${ANFL_ROOT}%f"
    print -P "Config: %F{green}${ANFL_ROOT}/config%f"
    print -P "Logs: %F{green}${ANFL_LOGS}%f"
    print -P "Deployment: %F{green}${ANFL_DEPLOYMENT}%f"
}

# Edit framework configuration
function edit_framework_config() {
    ${EDITOR:-vim} "${ANFL_ROOT}/config/framework.yaml"
}

# Edit environment configuration
function edit_environment_config() {
    ${EDITOR:-vim} "${ANFL_ROOT}/.env.${ANFL_ENV}"
}

# Open monitoring dashboard
function open_monitoring_dashboard() {
    local url="http://localhost:${GRAFANA_PORT}"
    if command -v open >/dev/null; then
        open "$url"
    else
        echo "Dashboard URL: $url"
    fi
}

# View framework logs
function view_framework_logs() {
    local log_type=${1:-"all"}
    case "$log_type" in
        "error")
            less "${ANFL_LOGS}/errors/error.log"
            ;;
        "deploy")
            less "${ANFL_LOGS}/deployment"/*.log
            ;;
        "security")
            less "${ANFL_LOGS}/security.log"
            ;;
        *)
            less "${ANFL_LOGS}"/*.log
            ;;
    esac
}

# -------------------------------
# 7. Exports
# -------------------------------

# Export helper functions
typeset -fx print_framework_paths edit_framework_config
typeset -fx edit_environment_config open_monitoring_dashboard
typeset -fx view_framework_logs

# ----------------------------------------------------------------------------