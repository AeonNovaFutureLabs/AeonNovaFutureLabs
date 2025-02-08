# ----------------------------------------------------------------------------
# File: 250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Vault integration and secrets management for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides Vault integration and secrets management for the ANFL framework

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Vault States
# -------------------------------

# Define vault states
declare -gA VAULT_STATES
VAULT_STATES=(
    [SEALED]=0
    [UNSEALING]=1
    [UNSEALED]=2
    [ERROR]=3
)

# Current vault state
: ${VAULT_STATE:=$VAULT_STATES[SEALED]}

# -------------------------------
# 2. Vault Configuration
# -------------------------------

# Define paths
: ${VAULT_CONFIG:="${ANFL_ROOT}/infrastructure/vault"}
: ${VAULT_LOGS:="${ANFL_LOGS}/vault"}

# Define default mount points
: ${VAULT_SECRET_PATH:="secret"}
: ${VAULT_KV_PATH:="kv"}

# -------------------------------
# 3. Core Functions
# -------------------------------

# Initialize Vault
init_vault() {
    # Check if vault is installed
    if ! command_exists vault; then
        log_error "Vault not installed"
        return 1
    }
    
    # Create required directories
    create_directory "$VAULT_LOGS" || return 1
    
    # Check Vault status
    if ! vault status >/dev/null 2>&1; then
        log_warning "Vault server not running"
        VAULT_STATE=$VAULT_STATES[SEALED]
        return 1
    }
    
    # Check if unsealed
    if vault status | grep -q "Sealed.*false"; then
        VAULT_STATE=$VAULT_STATES[UNSEALED]
        log_info "Vault ready"
    else
        VAULT_STATE=$VAULT_STATES[SEALED]
        log_warning "Vault sealed"
    fi
    
    return 0
}

# Unseal Vault
unseal_vault() {
    if [[ $VAULT_STATE == $VAULT_STATES[UNSEALED] ]]; then
        log_warning "Vault already unsealed"
        return 0
    fi
    
    VAULT_STATE=$VAULT_STATES[UNSEALING]
    
    # Check for unseal keys
    if [[ -z "$VAULT_UNSEAL_KEY" ]]; then
        log_error "VAULT_UNSEAL_KEY not set"
        VAULT_STATE=$VAULT_STATES[ERROR]
        return 1
    fi
    
    # Unseal vault
    vault operator unseal "$VAULT_UNSEAL_KEY" || {
        log_error "Failed to unseal vault"
        VAULT_STATE=$VAULT_STATES[ERROR]
        return 1
    }
    
    VAULT_STATE=$VAULT_STATES[UNSEALED]
    log_info "Vault unsealed"
    return 0
}

# -------------------------------
# 4. Secret Management
# -------------------------------

# Read secret
read_secret() {
    local path="$1"
    local key="${2:-value}"
    
    if [[ $VAULT_STATE != $VAULT_STATES[UNSEALED] ]]; then
        log_error "Vault not unsealed"
        return 1
    fi
    
    vault kv get -field="$key" "${VAULT_SECRET_PATH}/${path}" || {
        log_error "Failed to read secret: $path"
        return 1
    }
    
    return 0
}

# Write secret
write_secret() {
    local path="$1"
    local key="$2"
    local value="$3"
    
    if [[ $VAULT_STATE != $VAULT_STATES[UNSEALED] ]]; then
        log_error "Vault not unsealed"
        return 1
    fi
    
    vault kv put "${VAULT_SECRET_PATH}/${path}" "${key}=${value}" || {
        log_error "Failed to write secret: $path"
        return 1
    }
    
    log_info "Secret written: $path"
    return 0
}

# Delete secret
delete_secret() {
    local path="$1"
    
    if [[ $VAULT_STATE != $VAULT_STATES[UNSEALED] ]]; then
        log_error "Vault not unsealed"
        return 1
    fi
    
    vault kv delete "${VAULT_SECRET_PATH}/${path}" || {
        log_error "Failed to delete secret: $path"
        return 1
    }
    
    log_info "Secret deleted: $path"
    return 0
}

# -------------------------------
# 5. Utility Functions
# -------------------------------

# Check Vault status
check_vault() {
    if ! command_exists vault; then
        print -P "%F{red}Vault not installed%f"
        return 1
    fi
    
    print -P "%F{cyan}Vault Status:%f"
    vault status 2>/dev/null || {
        print -P "%F{red}Vault server not running%f"
        return 1
    }
    
    return 0
}

# List secrets
list_secrets() {
    local path="${1:-/}"
    
    if [[ $VAULT_STATE != $VAULT_STATES[UNSEALED] ]]; then
        log_error "Vault not unsealed"
        return 1
    fi
    
    vault kv list "${VAULT_SECRET_PATH}${path}" || {
        log_error "Failed to list secrets"
        return 1
    }
    
    return 0
}

# Rotate credentials
rotate_credentials() {
    local path="$1"
    local length="${2:-32}"
    
    if [[ $VAULT_STATE != $VAULT_STATES[UNSEALED] ]]; then
        log_error "Vault not unsealed"
        return 1
    fi
    
    # Generate new credential
    local new_value=$(generate_random_string "$length")
    
    # Write new credential
    write_secret "$path" "value" "$new_value" || return 1
    
    log_info "Credentials rotated: $path"
    return 0
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export vault states
export VAULT_STATES VAULT_STATE

# Export vault configuration
export VAULT_CONFIG VAULT_LOGS
export VAULT_SECRET_PATH VAULT_KV_PATH

# Export functions
export -f init_vault unseal_vault
export -f read_secret write_secret delete_secret
export -f check_vault list_secrets rotate_credentials

# ----------------------------------------------------------------------------