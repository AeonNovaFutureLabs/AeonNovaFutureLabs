# ----------------------------------------------------------------------------
# File: 250208_LOGGING_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Framework-compliant logging system with structured output and rotation
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides comprehensive logging functionality with severity levels, rotation, and structured output

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Log Configuration
# -------------------------------

# Define log levels with proper scoping
typeset -gA LOG_LEVELS
LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARNING]=2
    [ERROR]=3
    [CRITICAL]=4
)

# Define log colors
typeset -gA LOG_COLORS
LOG_COLORS=(
    [DEBUG]="%F{cyan}"
    [INFO]="%F{green}"
    [WARNING]="%F{yellow}"
    [ERROR]="%F{red}"
    [CRITICAL]="%F{red}%B"
)

# Current log level with safe initialization
: ${LOG_LEVEL:=$LOG_LEVELS[INFO]}

# Log file configuration
: ${LOG_MAX_SIZE:=5242880}  # 5MB
: ${LOG_BACKUP_COUNT:=5}
: ${MAIN_LOG:="${ANFL_LOGS}/anfl.log"}

# -------------------------------
# 2. Core Logging Functions
# -------------------------------

# Initialize logging system
function init_logging() {
    # Create log directory if it doesn't exist
    if [[ ! -d "${ANFL_LOGS}" ]]; then
        mkdir -p "${ANFL_LOGS}" || {
            print -P "%F{red}❌ Failed to create log directory%f" >&2
            return 1
        }
        chmod 750 "${ANFL_LOGS}"
    fi

    # Initialize main log file
    if [[ ! -f "$MAIN_LOG" ]]; then
        touch "$MAIN_LOG" || {
            print -P "%F{red}❌ Failed to create main log file%f" >&2
            return 1
        }
        chmod 640 "$MAIN_LOG"
    fi

    return 0
}

# Core logging function
function _log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=${LOG_COLORS[$level]}
    local reset="%f%b"
    local func_name=${funcstack[2]:-MAIN}

    # Check if we should log this level
    if (( LOG_LEVELS[$level] < LOG_LEVEL )); then
        return 0
    fi

    # Format message
    local formatted_message="[${timestamp}] [${level}] [${func_name}] ${message}"

    # Print to console if interactive
    if [[ -o interactive ]]; then
        print -P "${color}${formatted_message}${reset}"
    fi

    # Write to log file
    echo "$formatted_message" >> "$MAIN_LOG"

    # Check log rotation
    if [[ -f "$MAIN_LOG" ]] && [[ $(stat -f%z "$MAIN_LOG") -gt $LOG_MAX_SIZE ]]; then
        rotate_logs
    fi
}

# -------------------------------
# 3. Log Level Functions
# -------------------------------

# Debug level logging
function log_debug() {
    _log "DEBUG" "$1"
}

# Info level logging
function log_info() {
    _log "INFO" "$1"
}

# Warning level logging
function log_warning() {
    _log "WARNING" "$1"
}

# Error level logging
function log_error() {
    _log "ERROR" "$1"
}

# Critical level logging
function log_critical() {
    _log "CRITICAL" "$1"
}

# -------------------------------
# 4. Log Management
# -------------------------------

# Rotate log files
function rotate_logs() {
    local base_log=$1
    : ${base_log:=$MAIN_LOG}

    # Remove oldest log if it exists
    if [[ -f "${base_log}.${LOG_BACKUP_COUNT}" ]]; then
        rm "${base_log}.${LOG_BACKUP_COUNT}"
    fi

    # Rotate existing logs
    for i in {$LOG_BACKUP_COUNT..1}; do
        local j=$((i - 1))
        if [[ -f "${base_log}.${j}" ]]; then
            mv "${base_log}.${j}" "${base_log}.${i}"
        fi
    done

    # Rotate current log
    if [[ -f "${base_log}" ]]; then
        mv "${base_log}" "${base_log}.1"
        touch "${base_log}"
        chmod 640 "${base_log}"
    fi
}

# Clear logs
function clear_logs() {
    local keep_days=${1:-30}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    find "${ANFL_LOGS}" -type f -name "*.log.*" -mtime +${keep_days} -delete
    log_info "Cleared logs older than ${keep_days} days at ${timestamp}"
}

# -------------------------------
# 5. Utility Functions
# -------------------------------

# Set log level
function set_log_level() {
    local level=$1
    if [[ -n "${LOG_LEVELS[$level]}" ]]; then
        LOG_LEVEL=$LOG_LEVELS[$level]
        log_info "Log level set to: $level"
        return 0
    else
        log_error "Invalid log level: $level"
        return 1
    fi
}

# Get current log level
function get_log_level() {
    for level in ${(k)LOG_LEVELS}; do
        if [[ $LOG_LEVELS[$level] == $LOG_LEVEL ]]; then
            echo $level
            return 0
        fi
    done
    return 1
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export configuration
typeset -gx LOG_LEVELS LOG_LEVEL LOG_COLORS MAIN_LOG

# Export functions
typeset -fx init_logging _log
typeset -fx log_debug log_info log_warning log_error log_critical
typeset -fx rotate_logs clear_logs
typeset -fx set_log_level get_log_level

# Initialize logging when sourced
init_logging

# ----------------------------------------------------------------------------