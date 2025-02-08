# ----------------------------------------------------------------------------
# File: 250208_SECURITY_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Security management and validation for ANFL framework
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

# BLUF: Provides security validation, access control, and audit logging for ANFL framework

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Security Configuration
# -------------------------------

# Define security states
typeset -gA SECURITY_STATES
SECURITY_STATES=(
    [UNCHECKED]=0
    [CHECKING]=1
    [SECURE]=2
    [INSECURE]=3
    [ERROR]=4
)

# Current security state
: ${SECURITY_STATE:=$SECURITY_STATES[UNCHECKED]}

# Security log file
: ${SECURITY_LOG:="${ANFL_LOGS}/security.log"}

# -------------------------------
# 2. Security Validation
# -------------------------------

# Validate file permissions
function validate_permissions() {
    local path=$1
    local required_perms=$2
    local current_perms=$(stat -f "%Lp" "$path")
    
    if [[ $current_perms -gt $required_perms ]]; then
        log_error "Insecure permissions on $path: $current_perms (required: $required_perms)"
        return "${ERROR_CODES[SECURITY_ERROR]}"
    fi
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Validate environment security
function validate_environment_security() {
    local insecure_vars=()
    
    # Check for sensitive environment variables
    for var in "${REQUIRED_ENV_VARS[@]}"; do
        if [[ "${(P)var}" == *"password"* ]] || [[ "${(P)var}" == *"secret"* ]] || [[ "${(P)var}" == *"key"* ]]; then
            insecure_vars+=("$var")
        fi
    done
    
    if (( ${#insecure_vars} > 0 )); then
        log_warning "Found potentially sensitive environment variables: ${(j:, :)insecure_vars}"
    fi
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Validate file integrity
function validate_integrity() {
    local file=$1
    local expected_hash=$2
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return "${ERROR_CODES[SECURITY_ERROR]}"
    }
    
    local actual_hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    if [[ "$actual_hash" != "$expected_hash" ]]; then
        log_error "Integrity check failed for $file"
        return "${ERROR_CODES[SECURITY_ERROR]}"
    }
    
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 3. Access Control
# -------------------------------

# Check access permissions
function check_access() {
    local resource=$1
    local required_level=$2
    local current_level=${3:-0}
    
    if (( current_level < required_level )); then
        log_error "Access denied to $resource (required level: $required_level, current: $current_level)"
        return "${ERROR_CODES[SECURITY_ERROR]}"
    fi
    
    return "${ERROR_CODES[SUCCESS]}"
}

# Validate user permissions
function validate_user() {
    local required_group=$1
    
    if ! groups | grep -q "$required_group"; then
        log_error "User not in required group: $required_group"
        return "${ERROR_CODES[SECURITY_ERROR]}"
    fi
    
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 4. Audit Logging
# -------------------------------

# Log security event
function log_security_event() {
    local event=$1
    local severity=${2:-INFO}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local user=${USER:-UNKNOWN}
    local pwd=${PWD:-UNKNOWN}
    
    echo "[$timestamp] [$severity] [$user] [$pwd] $event" >> "$SECURITY_LOG"
    
    # Rotate log if needed
    if [[ -f "$SECURITY_LOG" ]] && [[ $(stat -f%z "$SECURITY_LOG") -gt 5242880 ]]; then
        mv "$SECURITY_LOG" "${SECURITY_LOG}.$(date +%Y%m%d_%H%M%S)"
        touch "$SECURITY_LOG"
        chmod 600 "$SECURITY_LOG"
    fi
}

# Clean security logs
function clean_security_logs() {
    local days=${1:-30}
    
    find "${ANFL_LOGS}" -name "security.log.*" -mtime "+$days" -delete
    log_info "Cleaned security logs older than $days days"
}

# -------------------------------
# 5. Security Operations
# -------------------------------

# Initialize security
function init_security() {
    SECURITY_STATE=$SECURITY_STATES[CHECKING]
    log_info "Initializing security framework..."
    
    # Create security log
    if [[ ! -f "$SECURITY_LOG" ]]; then
        touch "$SECURITY_LOG" || {
            log_error "Failed to create security log"
            SECURITY_STATE=$SECURITY_STATES[ERROR]
            return "${ERROR_CODES[SECURITY_ERROR]}"
        }
        chmod 600 "$SECURITY_LOG"
    }
    
    # Validate environment security
    validate_environment_security || {
        SECURITY_STATE=$SECURITY_STATES[INSECURE]
        return "${ERROR_CODES[SECURITY_ERROR]}"
    }
    
    # Validate critical file permissions
    local critical_paths=(
        "${ANFL_LOGS}"
        "${ANFL_DEPLOYMENT}"
        "${SECURITY_LOG}"
    )
    
    for path in "${critical_paths[@]}"; do
        validate_permissions "$path" 750 || {
            SECURITY_STATE=$SECURITY_STATES[INSECURE]
            return "${ERROR_CODES[SECURITY_ERROR]}"
        }
    done
    
    SECURITY_STATE=$SECURITY_STATES[SECURE]
    log_info "Security framework initialized successfully"
    return "${ERROR_CODES[SUCCESS]}"
}

# Get security status
function get_security_status() {
    print -P "%F{cyan}Security Status:%f"
    print -P "State: %F{green}${(k)SECURITY_STATES[(r)$SECURITY_STATE]}%f"
    print -P "User: %F{green}${USER}%f"
    print -P "Groups: %F{green}$(groups)%f"
    print -P "Log: %F{green}${SECURITY_LOG}%f"
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export security states
typeset -gx SECURITY_STATES SECURITY_STATE SECURITY_LOG

# Export functions
typeset -fx init_security get_security_status
typeset -fx validate_permissions validate_environment_security validate_integrity
typeset -fx check_access validate_user
typeset -fx log_security_event clean_security_logs

# Initialize security when sourced
init_security

# ----------------------------------------------------------------------------