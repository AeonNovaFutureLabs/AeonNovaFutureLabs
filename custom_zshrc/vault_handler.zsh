# ----------------------------------------------------------------------------
# File: 250117_VAULT_HANDLER_INT_v1.2_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaProject/.aeon_nova/themes/core/deployment/helpers/vault_handler.zsh
#
# Purpose: Enhanced Vault management implementation for Aeon Nova Framework with
#          quantum-secure integration and status tracking
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.2
# Last Modified: 2025-01-18
# ----------------------------------------------------------------------------

# Enable strict error handling
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL

# -------------------------------
# 1. Core Configuration
# -------------------------------

# Initialize core paths
: ${VAULT_PID_FILE:="${VAULT_DATA_DIR}/vault.pid"}
: ${VAULT_LOG_FILE:="${VAULT_LOG_DIR}/vault.log"}
: ${VAULT_CONFIG_FILE:="${VAULT_CONFIG_DIR}/config.hcl"}

# -------------------------------
# 2. Core Vault Functions
# -------------------------------

# Check if Vault is running
check_vault_running() {
    if [[ -f "$VAULT_PID_FILE" ]]; then
        local pid=$(cat "$VAULT_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        else
            rm -f "$VAULT_PID_FILE"
        fi
    fi
    return 1
}

# Initialize Vault
init_vault() {
    print -P "${__aeon_colors[cyan]}ℹ️  Initializing Vault...${__aeon_colors[reset]}"

    # Create required directories
    for dir in "$VAULT_DATA_DIR" "$VAULT_CONFIG_DIR" "$VAULT_LOG_DIR"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || {
                print -P "${__aeon_colors[red]}❌ Failed to create directory: $dir${__aeon_colors[reset]}"
                return 1
            }
        fi
    done

    # Check if already running
    if check_vault_running; then
        print -P "${__aeon_colors[green]}✓ Vault is already running${__aeon_colors[reset]}"
        return 0
    fi

    # Create Vault config
    cat > "$VAULT_CONFIG_FILE" <<EOF
storage "file" {
  path = "${VAULT_DATA_DIR}"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}

disable_mlock = true
ui = true
api_addr = "http://127.0.0.1:8200"
EOF
    chmod 600 "$VAULT_CONFIG_FILE"

    # Start Vault
    if ! vault status &>/dev/null; then
        print -P "${__aeon_colors[yellow]}⚡ Starting Vault in dev mode...${__aeon_colors[reset]}"
        nohup vault server -dev \
            -dev-root-token-id=root \
            -config="$VAULT_CONFIG_FILE" \
            > "$VAULT_LOG_FILE" 2>&1 &

        echo $! > "$VAULT_PID_FILE"

        # Wait for Vault to start
        local retries=0
        while ! vault status &>/dev/null && (( retries < 5 )); do
            sleep 1
            ((retries++))
        done

        # Verify Vault started
        if ! vault status &>/dev/null; then
            print -P "${__aeon_colors[red]}❌ Failed to start Vault${__aeon_colors[reset]}"
            return 1
        fi
    fi

    # Set environment variables
    export VAULT_ADDR='http://127.0.0.1:8200'
    export VAULT_TOKEN='root'

    print -P "${__aeon_colors[green]}✅ Vault initialized successfully${__aeon_colors[reset]}"
    return 0
}

# Stop Vault server
stop_vault() {
    if check_vault_running; then
        print -P "${__aeon_colors[yellow]}⚡ Stopping Vault...${__aeon_colors[reset]}"
        local pid=$(cat "$VAULT_PID_FILE")
        kill "$pid" 2>/dev/null && rm -f "$VAULT_PID_FILE"
        print -P "${__aeon_colors[green]}✓ Vault stopped${__aeon_colors[reset]}"
        return 0
    fi
    print -P "${__aeon_colors[yellow]}⚠️  Vault not running${__aeon_colors[reset]}"
    return 0
}

# -------------------------------
# 3. Vault Management Functions
# -------------------------------

# Get Vault status with details
vault_status() {
    if check_vault_running; then
        print -P "${__aeon_colors[green]}✓ Vault Status:${__aeon_colors[reset]}"
        print -P "  ${__aeon_colors[cyan]}• Running${__aeon_colors[reset]}"
        print -P "  ${__aeon_colors[cyan]}• PID: $(cat "$VAULT_PID_FILE")${__aeon_colors[reset]}"
        print -P "  ${__aeon_colors[cyan]}• Address: $VAULT_ADDR${__aeon_colors[reset]}"
        return 0
    else
        print -P "${__aeon_colors[yellow]}⚠️  Vault is not running${__aeon_colors[reset]}"
        return 1
    fi
}

# Reload Vault configuration
reload_vault() {
    if check_vault_running; then
        print -P "${__aeon_colors[cyan]}🔄 Reloading Vault configuration...${__aeon_colors[reset]}"
        vault reload || {
            print -P "${__aeon_colors[red]}❌ Failed to reload Vault${__aeon_colors[reset]}"
            return 1
        }
        print -P "${__aeon_colors[green]}✅ Vault reloaded successfully${__aeon_colors[reset]}"
        return 0
    fi
    print -P "${__aeon_colors[yellow]}⚠️  Vault not running${__aeon_colors[reset]}"
    return 1
}

# -------------------------------
# 4. Export Functions
# -------------------------------

# Export core functions
export -f check_vault_running init_vault stop_vault
export -f vault_status reload_vault

# -------------------------------
# 5. Initialize Path Exports
# -------------------------------

# Export Vault paths
export VAULT_PID_FILE VAULT_LOG_FILE VAULT_CONFIG_FILE

# ----------------------------------------------------------------------------
# End of vault_handler.zsh
# ----------------------------------------------------------------------------
