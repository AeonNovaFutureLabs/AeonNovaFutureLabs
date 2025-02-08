# ----------------------------------------------------------------------------
# File: 250208_CORE_ENV_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Core environment configuration and validation for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# - 250208_LOGGING_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Establishes and validates core environment settings for the ANFL framework

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Environment States
# -------------------------------

# Define environment states
typeset -gA ENV_STATES
ENV_STATES=(
    [UNINITIALIZED]=0
    [PARTIALLY_INITIALIZED]=1
    [FULLY_INITIALIZED]=2
    [ERROR]=3
)

# Current environment state
: ${ENV_STATE:=$ENV_STATES[UNINITIALIZED]}

# -------------------------------
# 2. Required Variables
# -------------------------------

# Define required environment variables
typeset -ga REQUIRED_ENV_VARS
REQUIRED_ENV_VARS=(
    "ANFL_ROOT"
    "ANFL_CUSTOM_ZSH"
    "ANFL_DEPLOYMENT"
    "ANFL_LOGS"
    "ANFL_ENV"
)

# Define required directories
typeset -ga REQUIRED_DIRS
REQUIRED_DIRS=(
    "${ANFL_ROOT}"
    "${ANFL_CUSTOM_ZSH}"
    "${ANFL_DEPLOYMENT}"
    "${ANFL_LOGS}"
    "${ANFL_LOGS}/errors"
    "${ANFL_LOGS}/deployment"
    "${ANFL_LOGS}/monitoring"
)

# -------------------------------
# 3. Environment Validation
# -------------------------------

# Validate environment variables
function validate_env_vars() {
    local missing_vars=()
    
    for var in "${REQUIRED_ENV_VARS[@]}"; do
        if [[ -z "${(P)var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if (( ${#missing_vars} > 0 )); then
        log_error "Missing required environment variables: ${(j:, :)missing_vars}"
        return "${ERROR_CODES[CONFIG_ERROR]}"
    fi
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Validate directory structure
function validate_directories() {
    local missing_dirs=()
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if (( ${#missing_dirs} > 0 )); then
        log_error "Missing required directories: ${(j:, :)missing_dirs}"
        return "${ERROR_CODES[CONFIG_ERROR]}"
    }
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Validate permissions
function validate_permissions() {
    local invalid_perms=()
    
    # Check log directory permissions
    if [[ ! -w "${ANFL_LOGS}" ]]; then
        invalid_perms+=("${ANFL_LOGS} (not writable)")
    fi
    
    # Check deployment directory permissions
    if [[ ! -x "${ANFL_DEPLOYMENT}" ]]; then
        invalid_perms+=("${ANFL_DEPLOYMENT} (not executable)")
    fi
    
    if (( ${#invalid_perms} > 0 )); then
        log_error "Invalid permissions: ${(j:, :)invalid_perms}"
        return "${ERROR_CODES[CONFIG_ERROR]}"
    }
    
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 4. Environment Setup
# -------------------------------

# Create required directories
function create_directories() {
    local created=0
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || {
                log_error "Failed to create directory: $dir"
                return "${ERROR_CODES[CONFIG_ERROR]}"
            }
            chmod 750 "$dir"
            ((created++))
        fi
    done
    
    if (( created > 0 )); then
        log_info "Created $created required directories"
    fi
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Set environment defaults
function set_env_defaults() {
    # Set default environment if not set
    : ${ANFL_ENV:="development"}
    
    # Set default log level based on environment
    case "$ANFL_ENV" in
        production)
            : ${LOG_LEVEL:=$LOG_LEVELS[INFO]}
            ;;
        staging)
            : ${LOG_LEVEL:=$LOG_LEVELS[DEBUG]}
            ;;
        development)
            : ${LOG_LEVEL:=$LOG_LEVELS[DEBUG]}
            ;;
        *)
            : ${LOG_LEVEL:=$LOG_LEVELS[INFO]}
            ;;
    esac
    
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 5. Core Functions
# -------------------------------

# Initialize environment
function init_env() {
    log_info "Initializing environment..."
    
    # Create required directories
    create_directories || return $?
    
    # Set environment defaults
    set_env_defaults || return $?
    
    # Validate environment
    validate_environment || return $?
    
    ENV_STATE=$ENV_STATES[FULLY_INITIALIZED]
    log_info "Environment initialized successfully"
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Validate complete environment
function validate_environment() {
    log_info "Validating environment..."
    
    # Validate environment variables
    validate_env_vars || return $?
    
    # Validate directories
    validate_directories || return $?
    
    # Validate permissions
    validate_permissions || return $?
    
    log_info "Environment validation successful"
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export environment states
typeset -gx ENV_STATES ENV_STATE

# Export core functions
typeset -fx init_env validate_environment
typeset -fx validate_env_vars validate_directories validate_permissions
typeset -fx create_directories set_env_defaults

# Initialize environment when sourced
init_env

# ----------------------------------------------------------------------------