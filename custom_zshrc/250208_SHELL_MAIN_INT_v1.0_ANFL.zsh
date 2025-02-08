# ----------------------------------------------------------------------------
# File: 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Main ZSH configuration entry point for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250113_SHELL_HELPERS_EXT_v1.0_ANFL.sh
# - 250107_FILE_TREE_LIVING_v1.0_ANFL.md
# ----------------------------------------------------------------------------

# BLUF: Core ZSH configuration that initializes and coordinates all ANFL framework components

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Core Environment Setup
# -------------------------------

# Define core paths
: ${ANFL_ROOT:="/Volumes/mattstack/VSCode/AeonNovaFutureLabs"}
: ${ANFL_CUSTOM_ZSH:="${ANFL_ROOT}/custom_zshrc"}
: ${ANFL_DEPLOYMENT:="${ANFL_ROOT}/deployment"}
: ${ANFL_LOGS:="${ANFL_ROOT}/logs"}

# Export core paths
export ANFL_ROOT ANFL_CUSTOM_ZSH ANFL_DEPLOYMENT ANFL_LOGS

# Create required directories
mkdir -p "${ANFL_LOGS}/errors" "${ANFL_LOGS}/deployment" "${ANFL_LOGS}/monitoring"

# -------------------------------
# 2. Load Core Components
# -------------------------------

# Define component loading order with versioned files
local components=(
    "250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh"    # Error handling
    "250208_LOGGING_INT_v1.0_ANFL.zsh"          # Logging system
    "250208_CORE_ENV_INT_v1.0_ANFL.zsh"         # Core environment
    "250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh"    # Vault integration
    "250208_DEPLOY_HANDLER_INT_v1.0_ANFL.zsh"   # Deployment management
    "250208_SECURITY_INT_v1.0_ANFL.zsh"         # Security functions
    "250208_MONITOR_INT_v1.0_ANFL.zsh"          # Monitoring integration
    "250208_ALIASES_INT_v1.0_ANFL.zsh"          # Custom aliases
    "250208_FUNCTIONS_INT_v1.0_ANFL.zsh"        # Utility functions
)

# Load components with error handling
for component in "${components[@]}"; do
    local component_path="${ANFL_CUSTOM_ZSH}/${component}"
    if [[ -f "$component_path" ]]; then
        source "$component_path" || {
            print -P "%F{red}❌ Failed to load: $component%f"
            return 1
        }
    else
        print -P "%F{yellow}⚠️  Component not found: $component%f"
    fi
done

# -------------------------------
# 3. Environment Configuration
# -------------------------------

# Load environment variables
if [[ -f "${ANFL_ROOT}/.env" ]]; then
    source "${ANFL_ROOT}/.env"
elif [[ -f "${ANFL_ROOT}/.env.development" ]]; then
    source "${ANFL_ROOT}/.env.development"
    export ANFL_ENV="development"
fi

# Set default environment
: ${ANFL_ENV:="development"}
export ANFL_ENV

# -------------------------------
# 4. Framework Functions
# -------------------------------

# Initialize framework components
function init_anfl_framework() {
    print -P "%F{blue}🚀 Initializing ANFL Framework...%f"

    # Initialize error handling
    init_error_handler || {
        print -P "%F{red}❌ Error handler initialization failed%f"
        return 1
    }

    # Initialize logging
    init_logging || {
        print -P "%F{red}❌ Logging initialization failed%f"
        return 1
    }

    # Initialize security (non-blocking)
    init_security || print -P "%F{yellow}⚠️  Security initialization incomplete%f"

    # Initialize Vault (non-blocking)
    init_vault || print -P "%F{yellow}⚠️  Vault initialization incomplete%f"

    # Initialize monitoring (non-blocking)
    init_monitoring || print -P "%F{yellow}⚠️  Monitoring initialization incomplete%f"

    print -P "%F{green}✨ Framework initialized successfully%f"
    print -P "%F{blue}💡 Type 'anfl help' for available commands%f"
}

# Display framework status
function anfl_status() {
    print -P "%F{cyan}📊 ANFL Framework Status%f"
    print -P "Environment: %F{green}${ANFL_ENV}%f"
    print -P "Root Path: %F{green}${ANFL_ROOT}%f"
    print -P "Security State: %F{green}${SECURITY_STATE:=UNKNOWN}%f"
    print -P "Vault Status: %F{green}$(vault status >/dev/null 2>&1 && echo "Running" || echo "Stopped")%f"
    print -P "Monitoring: %F{green}$(pgrep prometheus >/dev/null && echo "Running" || echo "Stopped")%f"
}

# Framework help command
function anfl_help() {
    print -P "%F{cyan}🔍 ANFL Framework Commands%f"
    print -P "%F{yellow}Core Commands:%f"
    print -P "  anfl status      - Display framework status"
    print -P "  anfl deploy      - Deploy components"
    print -P "  anfl monitor     - Access monitoring dashboard"
    print -P "  anfl logs        - View framework logs"
    print -P "  anfl vault       - Manage secrets"
    print -P "%F{yellow}Development Commands:%f"
    print -P "  anfl dev start   - Start development environment"
    print -P "  anfl dev stop    - Stop development environment"
    print -P "  anfl test        - Run test suite"
}

# -------------------------------
# 5. Aliases
# -------------------------------

alias anfl="anfl_help"
alias anfl-status="anfl_status"
alias anfl-deploy="deploy_components"
alias anfl-logs="view_logs"
alias anfl-monitor="open_monitoring"

# -------------------------------
# 6. Initialization
# -------------------------------

# Only run in interactive shells
if [[ -o interactive ]]; then
    init_anfl_framework
fi

# Export functions
export -f init_anfl_framework anfl_status anfl_help

# ----------------------------------------------------------------------------