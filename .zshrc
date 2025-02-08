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
export ANFL_ROOT="/Volumes/mattstack/VSCode/AeonNovaFutureLabs"
export ANFL_CUSTOM_ZSH="${ANFL_ROOT}/custom_zshrc"
export ANFL_DEPLOYMENT="${ANFL_ROOT}/deployment"
export ANFL_LOGS="${ANFL_ROOT}/logs"
export ANFL_ENV="development"

export AEON_TOOLS_ROOT="/Volumes/MattStack/Development/tools"
export ANACONDA_PATH="${AEON_TOOLS_ROOT}/anaconda3"
export LM_STUDIO_HOME="${AEON_TOOLS_ROOT}/lm-studio"

# Create required directories
mkdir -p "${ANFL_LOGS}"/{errors,deployment,monitoring}

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
source "${ANFL_CUSTOM_ZSH}/250208_SHELL_MAIN_INT_v1.0_ANFL.zsh"
source "${ANFL_CUSTOM_ZSH}/250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh"
source "${ANFL_CUSTOM_ZSH}/250208_LOGGING_INT_v1.0_ANFL.zsh"
source "${ANFL_CUSTOM_ZSH}/250208_CORE_ENV_INT_v1.0_ANFL.zsh"

# Security and deployment
source "${ANFL_CUSTOM_ZSH}/250208_SECURITY_INT_v1.0_ANFL.zsh"
source "${ANFL_CUSTOM_ZSH}/250208_DEPLOY_HANDLER_INT_v1.0_ANFL.zsh"

# Monitoring and management
source "${ANFL_CUSTOM_ZSH}/250208_MONITOR_INT_v1.0_ANFL.zsh"
source "${ANFL_CUSTOM_ZSH}/250208_VAULT_HANDLER_INT_v1.0_ANFL.zsh"

# Utilities
source "${ANFL_CUSTOM_ZSH}/250208_ALIASES_INT_v1.0_ANFL.zsh"
source "${ANFL_CUSTOM_ZSH}/250208_FUNCTIONS_INT_v1.0_ANFL.zsh"

# -------------------------------
# Environment Setup
# -------------------------------

# Load development environment if exists
if [[ -f "${ANFL_ROOT}/.env.development" ]]; then
    source "${ANFL_ROOT}/.env.development"
    print -P "%F{green}✨ Development environment loaded%f"
fi

# Initialize Conda
if [[ -f "${ANACONDA_PATH}/etc/profile.d/conda.sh" ]]; then
    source "${ANACONDA_PATH}/etc/profile.d/conda.sh"
    conda config --add channels defaults 2>/dev/null || true
    conda config --set auto_activate_base false 2>/dev/null || true
    print -P "%F{green}🐍 Conda ready%f"
fi

# Initialize Vault if configured
if [[ -n "${VAULT_ADDR:-}" && -n "${VAULT_TOKEN:-}" ]]; then
    print -P "%F{blue}🔐 Setting up Vault%f"
    for secret in grafana pinecone openai vector-store; do
        value=$(vault kv get -field=api_key "secret/$secret" 2>/dev/null) || true
        if [[ -n "$value" ]]; then
            export "${secret}_API_KEY=$value"
        fi
    done
    print -P "%F{green}✅ Vault ready%f"
fi

# -------------------------------
# Final Initialization
# -------------------------------

print -P "%F{cyan}🚀 Aeon Nova Framework initialized%f"
print -P "%F{blue}💡 Type 'aeon_nova_help' for available commands%f"

# ----------------------------------------------------------------------------
# End of .zshrc
# ----------------------------------------------------------------------------