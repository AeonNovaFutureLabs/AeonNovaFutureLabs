# ----------------------------------------------------------------------------
# File: 250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Secure secrets management using HashiCorp Vault for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_SECURITY_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides secure secrets management and access control using HashiCorp Vault

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Vault Configuration
# -------------------------------

# Define vault states
typeset -gA VAULT_STATES
VAULT_STATES=(
    [SEALED]=0
    [UNSEALING]=1
    [UNSEALED]=2
    [ERROR]=3
)

# Current vault state
: ${VAULT_STATE:=$VAULT_STATES[SEALED]}

# Vault configuration
: ${VAULT_ADDR:="http://127.0.0.1:8200"}
: ${VAULT_CONFIG_DIR:="${ANFL_ROOT}/infrastructure/vault"}
: ${VAULT_DATA_DIR:="${ANFL_LOGS}/vault"}

# Export Vault address
export VAULT_ADDR

# -------------------------------
# 2. Vault Operations
# -------------------------------

# Initialize Vault
function init_vault() {
    log_info "Initializing Vault..."
    
    # Create Vault directories
    mkdir -p "${VAULT_CONFIG_DIR}" "${VAULT_DATA_DIR}"
    chmod 750 "${VAULT_CONFIG_DIR}" "${VAULT_DATA_DIR}"
    
    # Check if Vault is already initialized
    if vault status >/dev/null 2>&1; then
        log_info "Vault is already initialized"
        return "${ERROR_CODES[SUCCESS]}"
    fi
    
    # Initialize Vault
    local init_output=$(vault operator init -key-shares=5 -key-threshold=3)
    if [[ $? -ne 0 ]]; then
        log_error "Failed to initialize Vault"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Store initialization output securely
    echo "$init_output" > "${VAULT_DATA_DIR}/init.txt"
    chmod 600 "${VAULT_DATA_DIR}/init.txt"
    
    log_info "Vault initialized successfully"
    return "${ERROR_CODES[SUCCESS]}"
}

# Unseal Vault
function unseal_vault() {
    VAULT_STATE=$VAULT_STATES[UNSEALING]
    log_info "Unsealing Vault..."
    
    # Check if already unsealed
    if vault status 2>/dev/null | grep -q "Sealed.*false"; then
        VAULT_STATE=$VAULT_STATES[UNSEALED]
        log_info "Vault is already unsealed"
        return "${ERROR_CODES[SUCCESS]}"
    fi
    
    # Read unseal keys
    if [[ ! -f "${VAULT_DATA_DIR}/init.txt" ]]; then
        log_error "Vault initialization file not found"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Extract unseal keys (first three)
    local keys=($(grep "Unseal Key" "${VAULT_DATA_DIR}/init.txt" | head -3 | awk '{print $4}'))
    
    # Unseal with each key
    for key in "${keys[@]}"; do
        vault operator unseal "$key" || {
            log_error "Failed to unseal Vault with key"
            return "${ERROR_CODES[VAULT_ERROR]}"
        }
    done
    
    VAULT_STATE=$VAULT_STATES[UNSEALED]
    log_info "Vault unsealed successfully"
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 3. Secret Management
# -------------------------------

# Store secret
function store_secret() {
    local path=$1
    local key=$2
    local value=$3
    
    # Validate input
    if [[ -z "$path" || -z "$key" || -z "$value" ]]; then
        log_error "Missing required parameters for store_secret"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Store secret
    if ! vault kv put "secret/$path" "$key=$value"; then
        log_error "Failed to store secret at path: $path"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    log_info "Secret stored successfully at: $path"
    return "${ERROR_CODES[SUCCESS]}"
}

# Retrieve secret
function get_secret() {
    local path=$1
    local key=$2
    
    # Validate input
    if [[ -z "$path" || -z "$key" ]]; then
        log_error "Missing required parameters for get_secret"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Retrieve secret
    local value=$(vault kv get -field="$key" "secret/$path" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        log_error "Failed to retrieve secret from path: $path"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    echo "$value"
    return "${ERROR_CODES[SUCCESS]}"
}

# Delete secret
function delete_secret() {
    local path=$1
    
    # Validate input
    if [[ -z "$path" ]]; then
        log_error "Missing path parameter for delete_secret"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Delete secret
    if ! vault kv delete "secret/$path"; then
        log_error "Failed to delete secret at path: $path"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    log_info "Secret deleted successfully from: $path"
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 4. Policy Management
# -------------------------------

# Create policy
function create_policy() {
    local name=$1
    local policy_file=$2
    
    # Validate input
    if [[ ! -f "$policy_file" ]]; then
        log_error "Policy file not found: $policy_file"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Create policy
    if ! vault policy write "$name" "$policy_file"; then
        log_error "Failed to create policy: $name"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    log_info "Policy created successfully: $name"
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 5. Token Management
# -------------------------------

# Create token
function create_token() {
    local policy=$1
    local ttl=${2:-"24h"}
    
    # Create token
    local token_info=$(vault token create -policy="$policy" -ttl="$ttl" -format=json)
    if [[ $? -ne 0 ]]; then
        log_error "Failed to create token with policy: $policy"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    echo "$token_info" | jq -r '.auth.client_token'
    return "${ERROR_CODES[SUCCESS]}"
}

# Revoke token
function revoke_token() {
    local token=$1
    
    # Revoke token
    if ! vault token revoke "$token"; then
        log_error "Failed to revoke token"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    log_info "Token revoked successfully"
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 6. Initialization
# -------------------------------

# Initialize Vault environment
function init_vault_env() {
    log_info "Initializing Vault environment..."
    
    # Check Vault installation
    if ! command -v vault >/dev/null; then
        log_error "Vault not installed"
        return "${ERROR_CODES[VAULT_ERROR]}"
    }
    
    # Initialize and unseal
    init_vault || return $?
    unseal_vault || return $?
    
    log_info "Vault environment initialized successfully"
    return "${ERROR_CODES[SUCCESS]}"
}

# -------------------------------
# 7. Exports
# -------------------------------

# Export vault states
typeset -gx VAULT_STATES VAULT_STATE

# Export functions
typeset -fx init_vault_env init_vault unseal_vault
typeset -fx store_secret get_secret delete_secret
typeset -fx create_policy create_token revoke_token

# ----------------------------------------------------------------------------