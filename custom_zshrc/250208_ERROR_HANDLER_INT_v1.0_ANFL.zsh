# ----------------------------------------------------------------------------
# File: 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Framework-compliant error handling and tracking system
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_LOGGING_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides robust error handling, tracking, and reporting for the ANFL framework

# Enable strict mode with proper variable scoping
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Error State Configuration
# -------------------------------

# Define error states with proper scoping
typeset -gA ERROR_STATES
ERROR_STATES=(
    [NONE]=0
    [WARNING]=1
    [ERROR]=2
    [CRITICAL]=3
)

# Current error state with safe initialization
: ${ERROR_STATE:=$ERROR_STATES[NONE]}

# Define error codes with proper scoping
typeset -gA ERROR_CODES
ERROR_CODES=(
    [SUCCESS]=0
    [GENERAL_ERROR]=1
    [CONFIG_ERROR]=2
    [SECURITY_ERROR]=3
    [VAULT_ERROR]=4
    [DEPLOYMENT_ERROR]=5
    [MONITORING_ERROR]=6
)

# -------------------------------
# 2. Logging Configuration
# -------------------------------

# Ensure log directory exists with proper permissions
if [[ ! -d "${ANFL_LOGS}/errors" ]]; then
    mkdir -p "${ANFL_LOGS}/errors" || {
        print -P "%F{red}❌ Failed to create error log directory%f" >&2
        return "${ERROR_CODES[GENERAL_ERROR]}"
    }
    chmod 750 "${ANFL_LOGS}/errors"
fi

# Initialize error log with proper permissions
ERROR_LOG="${ANFL_LOGS}/errors/error.log"
if [[ ! -f "$ERROR_LOG" ]]; then
    touch "$ERROR_LOG" || {
        print -P "%F{red}❌ Failed to create error log file%f" >&2
        return "${ERROR_CODES[GENERAL_ERROR]}"
    }
    chmod 640 "$ERROR_LOG"
fi

# -------------------------------
# 3. Core Error Functions
# -------------------------------

# Generic error handler for trap
function handle_error_generic() {
    local exit_code=$?
    local line_no=$1
    local func_name=${funcstack[1]:-UNKNOWN}

    # Update state
    ERROR_STATE=$ERROR_STATES[ERROR]

    # Log error with context
    print -P "%F{red}❌ Error in ${func_name} on line ${line_no} (Exit code: ${exit_code})%f" >&2

    # Track error
    track_error "$exit_code" "$func_name" "Error on line $line_no" "ERROR"

    return $exit_code
}

# Enhanced error handler with severity levels
function handle_error() {
    local exit_code=$1
    local function_name=$2
    local message=$3
    local severity=${4:-ERROR}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Update state
    ERROR_STATE=$ERROR_STATES[$severity]

    # Log error with full context
    print -P "%F{red}❌ [${timestamp}] [${severity}] [${function_name}] ${message} (Exit code: ${exit_code})%f" >&2

    # Track if severe enough
    if (( ERROR_STATE >= ERROR_STATES[ERROR] )); then
        track_error "$exit_code" "$function_name" "$message" "$severity"
    fi

    return $exit_code
}

# Track error with proper logging
function track_error() {
    local exit_code=$1
    local function_name=$2
    local message=$3
    local severity=$4
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local user=${USER:-UNKNOWN}
    local pwd=${PWD:-UNKNOWN}

    # Ensure log directory exists
    if [[ ! -d "${ANFL_LOGS}/errors" ]]; then
        mkdir -p "${ANFL_LOGS}/errors"
    fi

    # Log error with full context
    echo "[${timestamp}] [${severity}] [${function_name}] (${exit_code}) ${message} | User: ${user} | PWD: ${pwd}" >> "$ERROR_LOG"

    # Rotate logs if needed
    if [[ -f "$ERROR_LOG" ]] && [[ $(stat -f%z "$ERROR_LOG") -gt 5242880 ]]; then  # 5MB
        mv "$ERROR_LOG" "${ERROR_LOG}.$(date +%Y%m%d_%H%M%S)"
        touch "$ERROR_LOG"
        chmod 640 "$ERROR_LOG"
    fi
}

# -------------------------------
# 4. Utility Functions
# -------------------------------

# Check current error state
function check_error_state() {
    (( ERROR_STATE > ERROR_STATES[NONE] ))
}

# Reset error state
function reset_error_state() {
    ERROR_STATE=$ERROR_STATES[NONE]
}

# Print formatted error message
function print_error() {
    local message=$1
    local severity=${2:-ERROR}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    print -P "%F{red}❌ [${timestamp}] [${severity}] ${message}%f" >&2
}

# Print formatted warning message
function print_warning() {
    local message=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    print -P "%F{yellow}⚠️  [${timestamp}] [WARNING] ${message}%f" >&2
}

# -------------------------------
# 5. Initialization
# -------------------------------

# Initialize error handler
function init_error_handler() {
    # Set error trap
    trap 'handle_error_generic $LINENO' ERR

    # Initialize error state
    ERROR_STATE=$ERROR_STATES[NONE]

    # Verify log setup
    if [[ ! -f "$ERROR_LOG" ]]; then
        mkdir -p "${ANFL_LOGS}/errors" 2>/dev/null
        touch "$ERROR_LOG" 2>/dev/null
        chmod 640 "$ERROR_LOG" 2>/dev/null
    fi

    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export error states and codes
typeset -gx ERROR_STATES ERROR_STATE ERROR_CODES ERROR_LOG

# Export error functions
typeset -fx handle_error_generic handle_error track_error
typeset -fx check_error_state reset_error_state
typeset -fx print_error print_warning init_error_handler

# Initialize handler when sourced
init_error_handler

# ----------------------------------------------------------------------------