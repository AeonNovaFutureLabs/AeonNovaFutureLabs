# ----------------------------------------------------------------------------
# File: 250208_FUNCTIONS_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Framework-compliant utility functions and helpers
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides common utility functions and helpers for ANFL framework operations

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Status Functions
# -------------------------------

# Get framework status
function get_framework_status() {
    print -P "%F{cyan}Framework Status Summary%f"
    print -P "Environment: %F{green}${ANFL_ENV}%f"
    print -P "Security: %F{green}${(k)SECURITY_STATES[(r)$SECURITY_STATE]}%f"
    print -P "Deployment: %F{green}${(k)DEPLOY_STATES[(r)$DEPLOY_STATE]}%f"
    print -P "Monitoring: %F{green}${(k)MONITOR_STATES[(r)$MONITOR_STATE]}%f"
    print -P "Vault: %F{green}${(k)VAULT_STATES[(r)$VAULT_STATE]}%f"
}

# Check framework health
function check_framework_health() {
    local issues=0
    
    # Check core services
    check_monitoring_health || ((issues++))
    check_security_health || ((issues++))
    check_vault_health || ((issues++))
    
    # Check file permissions
    check_file_permissions || ((issues++))
    
    # Check disk space
    check_disk_space || ((issues++))
    
    if (( issues > 0 )); then
        log_warning "Found $issues health issues"
        return 1
    fi
    
    log_info "All health checks passed"
    return 0
}

# -------------------------------
# 2. File Operations
# -------------------------------

# Check file permissions
function check_file_permissions() {
    local invalid_perms=()
    
    # Check critical directories
    for dir in "${ANFL_LOGS}" "${ANFL_DEPLOYMENT}"; do
        if [[ ! -d "$dir" ]]; then
            invalid_perms+=("$dir (missing)")
            continue
        fi
        
        local perms=$(stat -f "%Lp" "$dir")
        if [[ $perms -gt 750 ]]; then
            invalid_perms+=("$dir ($perms)")
        fi
    done
    
    # Check sensitive files
    for file in "${ANFL_LOGS}/security.log" "${VAULT_DATA_DIR}/init.txt"; do
        if [[ -f "$file" ]]; then
            local perms=$(stat -f "%Lp" "$file")
            if [[ $perms -gt 600 ]]; then
                invalid_perms+=("$file ($perms)")
            fi
        fi
    done
    
    if (( ${#invalid_perms} > 0 )); then
        log_error "Invalid permissions found: ${(j:, :)invalid_perms}"
        return 1
    fi
    
    return 0
}

# Clean framework logs
function clean_framework_logs() {
    local days=${1:-30}
    local cleaned=0
    
    # Clean component logs
    for dir in "${ANFL_LOGS}"/*(/); do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f -name "*.log*" -mtime "+$days" -delete
            ((cleaned += $?))
        fi
    done
    
    log_info "Cleaned $cleaned log files older than $days days"
    return 0
}

# -------------------------------
# 3. System Checks
# -------------------------------

# Check disk space
function check_disk_space() {
    local threshold=${1:-90}  # Default 90% threshold
    local usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d% -f1)
    
    if (( usage > threshold )); then
        log_error "Disk usage above threshold: ${usage}% (threshold: ${threshold}%)"
        return 1
    fi
    
    return 0
}

# Check memory usage
function check_memory_usage() {
    local threshold=${1:-90}  # Default 90% threshold
    local usage=$(vm_stat | awk '/free/ {free=$3} /active/ {active=$3} /inactive/ {inactive=$3} /speculative/ {speculative=$3} /wired/ {wired=$4} END {total=(active+inactive+speculative+wired)*4096/1024/1024; print int(total/16384*100)}')
    
    if (( usage > threshold )); then
        log_error "Memory usage above threshold: ${usage}% (threshold: ${threshold}%)"
        return 1
    fi
    
    return 0
}

# -------------------------------
# 4. Backup Functions
# -------------------------------

# Backup framework data
function backup_framework_data() {
    local backup_dir="${ANFL_ROOT}/backups/$(date +%Y%m%d_%H%M%S)"
    local backup_log="${ANFL_LOGS}/backup.log"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Backup configuration
    cp -R "${ANFL_ROOT}/config" "$backup_dir/"
    
    # Backup logs (last 7 days)
    find "${ANFL_LOGS}" -type f -mtime -7 -exec cp {} "$backup_dir/" \;
    
    # Create archive
    tar -czf "${backup_dir}.tar.gz" "$backup_dir"
    rm -rf "$backup_dir"
    
    log_info "Backup created: ${backup_dir}.tar.gz"
    return 0
}

# Restore framework data
function restore_framework_data() {
    local backup_file=$1
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    local temp_dir="/tmp/anfl_restore_$(date +%s)"
    mkdir -p "$temp_dir"
    
    # Extract backup
    tar -xzf "$backup_file" -C "$temp_dir"
    
    # Restore configuration
    cp -R "${temp_dir}"/*/config/* "${ANFL_ROOT}/config/"
    
    # Clean up
    rm -rf "$temp_dir"
    
    log_info "Restore completed from: $backup_file"
    return 0
}

# -------------------------------
# 5. Utility Functions
# -------------------------------

# Format timestamp
function format_timestamp() {
    local timestamp=${1:-$(date +%s)}
    date -r "$timestamp" '+%Y-%m-%d %H:%M:%S'
}

# Generate random string
function generate_random_string() {
    local length=${1:-32}
    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
}

# Check if running in container
function is_container() {
    [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export utility functions
typeset -fx get_framework_status check_framework_health
typeset -fx check_file_permissions clean_framework_logs
typeset -fx check_disk_space check_memory_usage
typeset -fx backup_framework_data restore_framework_data
typeset -fx format_timestamp generate_random_string is_container

# ----------------------------------------------------------------------------