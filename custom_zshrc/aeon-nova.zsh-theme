# ----------------------------------------------------------------------------
# File: 250118_INIT_CORE_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaProject/.aeon_nova/themes/core/init.zsh
#
# Purpose: Core initialization script for Aeon Nova Framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-01-18
# ----------------------------------------------------------------------------

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# ----------------------------------------------------------------------------
# 1. Core Path Definitions
# ----------------------------------------------------------------------------

: ${AEON_NOVA_ROOT:="/Volumes/mattstack/VSCode/AeonNovaProject"}
: ${AEON_NOVA_THEMES:="${AEON_NOVA_ROOT}/.aeon_nova/themes"}
: ${AEON_CORE:="${AEON_NOVA_THEMES}/core"}
: ${HELPERS:="${AEON_CORE}/deployment/helpers"}
: ${DEPLOYMENT_DIR:="${AEON_NOVA_ROOT}/deployment/scripts"}
: ${AEON_TOOLS_ROOT:="/Volumes/MattStack/Development/tools"}
: ${ANACONDA_PATH:="${AEON_TOOLS_ROOT}/anaconda3"}

# Export core paths
export AEON_NOVA_ROOT AEON_NOVA_THEMES AEON_CORE HELPERS DEPLOYMENT_DIR
export AEON_TOOLS_ROOT ANACONDA_PATH

# ----------------------------------------------------------------------------
# 2. Core Functions
# ----------------------------------------------------------------------------

# Print status message with color
print_status() {
    local color="$1"
    local message="$2"
    print -P "${__aeon_colors[$color]}$message${__aeon_colors[reset]}"
}

# Initialize color definitions
init_colors() {
    # Define color palette
    typeset -gA __aeon_colors=(
        [reset]="%f"
        [blue]="%F{blue}"
        [cyan]="%F{cyan}"
        [green]="%F{green}"
        [yellow]="%F{yellow}"
        [magenta]="%F{magenta}"
        [red]="%F{red}"
    )
    export __aeon_colors
}

# Initialize error codes
init_error_codes() {
    typeset -gA ERROR_CODES=(
        [SUCCESS]=0
        [ENV_ERROR]=1
        [SECURITY_ERROR]=2
        [DEPLOY_ERROR]=3
        [VALIDATION_ERROR]=4
        [LOAD_ERROR]=5
        [UNKNOWN_ERROR]=99
    )
    export ERROR_CODES
}

# Load helper script
load_helper() {
    local helper="$1"
    local helper_path="${HELPERS}/${helper}"
    print_status "cyan" "  ↪ Loading ${helper}..."

    if [[ ! -f "$helper_path" ]]; then
        print_status "red" "❌ Helper not found: ${helper}"
        return "${ERROR_CODES[LOAD_ERROR]}"
    fi

    source "$helper_path" || {
        print_status "red" "❌ Failed to load helper: ${helper}"
        return "${ERROR_CODES[LOAD_ERROR]}"
    }

    return "${ERROR_CODES[SUCCESS]}"
}

# ----------------------------------------------------------------------------
# 3. Environment Setup
# ----------------------------------------------------------------------------

# Set up core environment
setup_core_env() {
    print_status "cyan" "🌟 Setting up core environment..."

    # Initialize colors and error codes
    init_colors
    init_error_codes

    # Create required directories
    mkdir -p "${AEON_NOVA_ROOT}/logs/errors" 2>/dev/null
    mkdir -p "${DEPLOYMENT_DIR}" 2>/dev/null

    # Load core environment handler
    local core_env="${AEON_CORE}/core_env.zsh"
    if [[ -f "$core_env" ]]; then
        source "$core_env" || {
            print_status "red" "❌ Failed to load core environment"
            return 1
        }
        print_status "green" "✅ Core environment handler loaded"
    else
        print_status "red" "❌ Core environment file not found"
        return 1
    fi

    return 0
}

# ----------------------------------------------------------------------------
# 4. Optional Components
# ----------------------------------------------------------------------------

# Initialize Conda environment
init_conda() {
    if [[ -f "${ANACONDA_PATH}/etc/profile.d/conda.sh" ]]; then
        print_status "cyan" "🐍 Initializing Conda environment..."
        source "${ANACONDA_PATH}/etc/profile.d/conda.sh" || return 1
        conda config --set auto_activate_base false 2>/dev/null || true
        print_status "green" "✅ Conda environment initialized"
        return 0
    fi
    return 0
}

# Load development environment
load_dev_env() {
    if [[ -f "${AEON_NOVA_ROOT}/.env.development" ]]; then
        print_status "cyan" "🔧 Loading development environment..."
        source "${AEON_NOVA_ROOT}/.env.development" && {
            print_status "green" "✅ Development environment loaded"
        }
    fi
}

# ----------------------------------------------------------------------------
# 5. Main Initialization
# ----------------------------------------------------------------------------

# Main initialization function
main() {
    # Set up core environment
    setup_core_env || return 1

    # Initialize core environment
    init_core_env || {
        print_status "yellow" "⚠️  Core initialization incomplete"
    }

    # Initialize optional components (non-blocking)
    {
        init_conda
        load_dev_env
    } 2>/dev/null

    print_status "blue" "🚀 Initializing Aeon Nova Framework..."

    # Initialize security (non-blocking)
    if typeset -f init_security >/dev/null; then
        init_security || print_status "yellow" "⚠️  Security initialization incomplete"
    fi

    # Initialize Vault (non-blocking)
    if typeset -f init_vault_env >/dev/null; then
        init_vault_env || print_status "yellow" "⚠️  Vault initialization unavailable"
    fi

    print_status "green" "✨ Framework initialized"
    print_status "blue" "💡 Type 'aeon_nova_help' for available commands"

    print_status "green" "🎉 Aeon Nova environment ready!"
    return 0
}

# Run main initialization
main "$@"
