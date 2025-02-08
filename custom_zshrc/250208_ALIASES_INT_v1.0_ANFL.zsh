# ----------------------------------------------------------------------------
# File: 250208_ALIASES_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Framework-compliant aliases for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides convenient aliases for common ANFL framework operations

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Navigation Aliases
# -------------------------------

# Core directories
alias cdanfl="cd $ANFL_ROOT"
alias cdai="cd $ANFL_ROOT/ai_components"
alias cdinfra="cd $ANFL_ROOT/infrastructure"
alias cddocs="cd $ANFL_ROOT/docs"
alias cdlogs="cd $ANFL_LOGS"

# -------------------------------
# 2. Framework Aliases
# -------------------------------

# Core operations
alias anfl-init="init_anfl_framework"
alias anfl-status="check_security && anfl_status"
alias anfl-help="anfl_help"

# Development
alias anfl-dev="cd $ANFL_ROOT && source .env.development"
alias anfl-test="cd $ANFL_ROOT && python -m pytest"
alias anfl-lint="cd $ANFL_ROOT && black . && isort ."

# Monitoring
alias anfl-metrics="cd $ANFL_ROOT/infrastructure/monitoring && docker-compose up -d"
alias anfl-grafana="open http://localhost:3000"
alias anfl-prometheus="open http://localhost:9090"

# -------------------------------
# 3. Utility Aliases
# -------------------------------

# Logs
alias anfl-logs="tail -f $ANFL_LOGS/anfl.log"
alias anfl-errors="tail -f $ANFL_LOGS/errors/error.log"
alias anfl-clear-logs="clear_logs"

# Security
alias anfl-secure="init_security"
alias anfl-verify="verify_permissions"
alias anfl-check="check_security"

# Environment
alias anfl-env="env | grep ANFL_"
alias anfl-path="echo $PATH | tr ':' '\n'"
alias anfl-reload="source $ANFL_ROOT/.zshrc"

# -------------------------------
# 4. Git Aliases
# -------------------------------

# Common operations
alias gst="git status"
alias gpl="git pull"
alias gps="git push"
alias gco="git checkout"
alias gcm="git commit -m"
alias gaa="git add -A"
alias glog="git log --oneline --graph --decorate"

# Branch operations
alias gbr="git branch"
alias gbd="git branch -d"
alias gbn="git checkout -b"

# -------------------------------
# 5. Docker Aliases
# -------------------------------

# Container operations
alias dps="docker ps"
alias dpa="docker ps -a"
alias dst="docker stats"
alias dlg="docker logs"

# Compose operations
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcl="docker-compose logs -f"

# -------------------------------
# 6. Python Aliases
# -------------------------------

# Virtual environment
alias venv="python -m venv venv"
alias activate="source venv/bin/activate"
alias deactivate="deactivate"

# Package management
alias pi="pip install"
alias pir="pip install -r requirements.txt"
alias pf="pip freeze > requirements.txt"

# Testing
alias pt="pytest"
alias ptv="pytest -v"
alias ptc="pytest --cov"

# -------------------------------
# 7. Monitoring Aliases
# -------------------------------

# Resource monitoring
alias cpu="top -o cpu"
alias mem="top -o rsize"
alias disk="df -h"
alias space="du -sh *"

# Process monitoring
alias ports="lsof -i -P -n | grep LISTEN"
alias procs="ps aux | grep"
alias kills="kill -9"

# -------------------------------
# 8. Exports
# -------------------------------

# Export all aliases to subshells
export ANFL_ALIASES_LOADED=true

# ----------------------------------------------------------------------------