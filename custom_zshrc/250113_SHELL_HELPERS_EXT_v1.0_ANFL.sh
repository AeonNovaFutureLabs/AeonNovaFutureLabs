# ----------------------------------------------------------------------------
# File: 250113_SHELL_HELPERS_EXT_v1.1_ANFL.sh
# Location: /Volumes/mattstack/VSCode/AeonNovaProject/.aeon_nova/themes/core/deployment/helpers/250113_SHELL_HELPERS_EXT_v1.1_ANFL.sh
#
# Purpose: Shell helper functions for emoji-enhanced development environment,
#          providing enhanced command feedback and visual indicators
# Security Level: Public-facing
# Owner: Matt Stack
# Version: 1.1
# Last Modified: 2025-01-18
# ----------------------------------------------------------------------------

# Enable strict ZSH compatibility
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL

# Ensure AEON_NOVA_ROOT is set
if [[ -z "${AEON_NOVA_ROOT}" ]]; then
    echo "❌ ERROR: AEON_NOVA_ROOT is not set. Please configure the environment." >&2
    return 1
fi

# Load logging script
LOGGING_SCRIPT="${AEON_NOVA_ROOT}/.aeon_nova/themes/core/deployment/helpers/logging.zsh"
if [[ -f "$LOGGING_SCRIPT" ]]; then
    source "$LOGGING_SCRIPT" || {
        echo "❌ ERROR: Logging script failed to load." >&2
        return 1
    }
else
    echo "❌ ERROR: Logging script not found at $LOGGING_SCRIPT." >&2
    return 1
fi

# Emoji mapping script
EMOJI_HELPER="${AEON_NOVA_ROOT}/.aeon_nova/themes/extensions/emoji/250113_EMOJI_HELPER_EXT_v1.0_ANFL.py"
if [[ ! -f "$EMOJI_HELPER" ]]; then
    echo "❌ ERROR: Emoji helper script not found at $EMOJI_HELPER." >&2
    return 1
fi

# -------------------------------
# Emoji-enhanced Shell Functions
# -------------------------------

# Fetch emoji from helper script
get_emoji() {
    local type="$1"
    local key="$2"
    python3 "$EMOJI_HELPER" get_emoji "$type" "$key" || echo "❓"
}

# Enhanced file listing with emojis
ls_emoji() {
    command ls -la "$@" | while IFS= read -r line; do
        local emoji
        if [[ "$line" =~ ^d ]]; then
            emoji="📁"
        elif [[ "$line" =~ ^l ]]; then
            emoji="🔗"
        elif [[ "$line" =~ \.(sh|zsh)$ ]]; then
            emoji="⚡"
        else
            emoji="📄"
        fi
        echo "$emoji $line"
    done
}

# Enhanced Git status with emojis
git_status_emoji() {
    if ! git rev-parse --git-dir &>/dev/null; then
        log_error "Not a git repository"
        return 1
    fi

    echo "🔍 Git Status:"
    git status --porcelain | while IFS= read -r line; do
        local status="${line:0:2}"
        local file="${line:3}"
        case "$status" in
            "M ") echo "📝 Modified: $file" ;;
            "A ") echo "➕ Added: $file" ;;
            "D ") echo "➖ Deleted: $file" ;;
            "R ") echo "♻️  Renamed: $file" ;;
            "C ") echo "📋 Copied: $file" ;;
            "??") echo "❓ Untracked: $file" ;;
            "UU") echo "💥 Conflict: $file" ;;
            *) echo "❗ Unknown status: $file" ;;
        esac
    done

    echo "🌿 Current branch: $(git branch --show-current)"
}

# Enhanced directory navigation with emojis
cd_emoji() {
    cd "$@" || return 1
    local files=$(ls -1A | wc -l)
    local git_status=""
    if git rev-parse --git-dir &>/dev/null; then
        if [[ -z "$(git status --porcelain)" ]]; then
            git_status="✨"
        else
            git_status="📝"
        fi
    fi
    echo "📂 Now in: $PWD"
    echo "📊 Contains: $files files/folders $git_status"
}

# Enhanced process management with emojis
ps_emoji() {
    ps "$@" | while read -r line; do
        if [[ "$line" =~ ^[[:space:]]*PID ]]; then
            echo "🔄 $line"
        else
            echo "💻 $line"
        fi
    done
}

# Enhanced network status with emojis
net_status_emoji() {
    echo "🌐 Network Status:"
    ifconfig | while read -r line; do
        if [[ "$line" =~ ^[[:alpha:]] ]]; then
            echo "🔌 $line"
        else
            echo "   $line"
        fi
    done
}

# Command history with emojis
history_emoji() {
    history | while read -r line; do
        local cmd="${line#*  }"
        case "$cmd" in
            git*) echo "🌿 $line" ;;
            cd*) echo "📂 $line" ;;
            python*) echo "🐍 $line" ;;
            docker*) echo "🐳 $line" ;;
            npm*) echo "📦 $line" ;;
            *) echo "💻 $line" ;;
        esac
    done
}

# -------------------------------
# Error Handling and Progress
# -------------------------------

# Error handling with emojis
handle_error() {
    local exit_code=$?
    local command="$1"
    if [[ $exit_code -ne 0 ]]; then
        echo "❌ Command failed: $command"
        echo "⚠️  Exit code: $exit_code"
    fi
    return $exit_code
}

# Progress indicator with emojis
show_progress() {
    local message="$1"
    local emojis=("⏳" "⌛")
    local i=0
    while kill -0 $! 2>/dev/null; do
        echo -ne "\r${emojis[i]} $message"
        i=$(( (i + 1) % 2 ))
        sleep 0.5
    done
    echo -ne "\r✅ $message - Complete\n"
}

# Trap setup for error handling
trap 'handle_error "$BASH_COMMAND"' ERR

# Export functions
export -f get_emoji ls_emoji git_status_emoji cd_emoji ps_emoji net_status_emoji history_emoji show_progress handle_error
