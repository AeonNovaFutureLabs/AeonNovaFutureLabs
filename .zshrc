# ----------------------------------------------------------------------------
# File: .zshrc
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/.zshrc
#
# Purpose: Enterprise-grade ZSH configuration implementing quantum-secure
#          initialization, comprehensive state management, enhanced error handling,
#          visual enhancements, and full framework integration with systematic recovery mechanisms.
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 3.4
# Last Modified: 2025-02-08
# ----------------------------------------------------------------------------

# BLUF: Enterprise-grade ZSH configuration combining quantum-secure operations,
# visual enhancements, comprehensive environment management, and robust error handling.

# -------------------------------
# Core Path Management
# -------------------------------

# Define the base root directory
export AEON_NOVA_ROOT="/Volumes/mattstack/VSCode/AeonNovaFutureLabs"
export AEON_TOOLS_ROOT="/Volumes/MattStack/Development/tools"

# Define additional core paths
export AEON_NOVA_THEMES="${AEON_NOVA_ROOT}/custom_zshrc"
export AEON_CORE="${AEON_NOVA_ROOT}/custom_zshrc"

export ANACONDA_PATH="${AEON_TOOLS_ROOT}/anaconda3"
export LM_STUDIO_HOME="${AEON_TOOLS_ROOT}/lm-studio"

# Update PATH
path=(
    "${ANACONDA_PATH}/bin"
    "${LM_STUDIO_HOME}/bin"
    "/usr/local/bin"
    "$HOME/.cargo/bin"
    $path
)

# -------------------------------
# Source Custom ZSH Components
# -------------------------------

# Core components
source "${AEON_CORE}/250208_SHELL_MAIN_INT_v1.0_ANFL.zsh"
source "${AEON_CORE}/250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh"
source "${AEON_CORE}/250208_LOGGING_INT_v1.0_ANFL.zsh"
source "${AEON_CORE}/250208_CORE_ENV_INT_v1.0_ANFL.zsh"

# Security and deployment
source "${AEON_CORE}/250208_SECURITY_INT_v1.0_ANFL.zsh"
source "${AEON_CORE}/250208_DEPLOY_HANDLER_INT_v1.0_ANFL.zsh"

# Monitoring and management
source "${AEON_CORE}/250208_MONITOR_INT_v1.0_ANFL.zsh"
source "${AEON_CORE}/250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh"

# Utilities
source "${AEON_CORE}/250208_ALIASES_INT_v1.0_ANFL.zsh"
source "${AEON_CORE}/250208_FUNCTIONS_INT_v1.0_ANFL.zsh"

# -------------------------------
# Environment Setup
# -------------------------------

# Load development environment if exists
if [[ -f "${AEON_NOVA_ROOT}/.env.development" ]]; then
    source "${AEON_NOVA_ROOT}/.env.development"
    print -P "${__aeon_colors[green]}✨ Development environment loaded${__aeon_colors[reset]}"
fi

# Initialize Conda
if [[ -f "${ANACONDA_PATH}/etc/profile.d/conda.sh" ]]; then
    source "${ANACONDA_PATH}/etc/profile.d/conda.sh"
    conda config --add channels defaults 2>/dev/null || true
    conda config --set auto_activate_base false 2>/dev/null || true
    print -P "${__aeon_colors[green]}🐍 Conda ready${__aeon_colors[reset]}"
fi

# Initialize Vault if configured
if [[ -n "${VAULT_ADDR:-}" && -n "${VAULT_TOKEN:-}" ]]; then
    print -P "${__aeon_colors[blue]}🔐 Setting up Vault${__aeon_colors[reset]}"
    for secret in grafana pinecone openai vector-store; do
        value=$(vault kv get -field=api_key "secret/$secret" 2>/dev/null) || true
        if [[ -n "$value" ]]; then
            export "${secret}_API_KEY=$value"
        fi
    done
    print -P "${__aeon_colors[green]}✅ Vault ready${__aeon_colors[reset]}"
fi

# -------------------------------
# Final Initialization
# -------------------------------

print -P "${__aeon_colors[cyan]}🚀 Aeon Nova Framework initialized${__aeon_colors[reset]}"
print -P "${__aeon_colors[blue]}💡 Type 'aeon_nova_help' for available commands${__aeon_colors[reset]}"

# ----------------------------------------------------------------------------
# End of .zshrc
# ----------------------------------------------------------------------------