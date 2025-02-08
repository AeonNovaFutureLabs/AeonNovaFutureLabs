# ----------------------------------------------------------------------------
# File: 250208_FUNCTIONS_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Core utility functions for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides core utility functions for the ANFL framework

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Path Functions
# -------------------------------

# Get clean path (replace $HOME with ~)
clean_path() {
    local path="${1:-$PWD}"
    echo "${path/#$HOME/~}"
}

# Verify path exists
verify_path() {
    local path="$1"
    local type="${2:-any}"  # file, directory, or any
    
    case "$type" in
        file)
            [[ -f "$path" ]] && return 0
            ;;
        directory)
            [[ -d "$path" ]] && return 0
            ;;
        any)
            [[ -e "$path" ]] && return 0
            ;;
        *)
            log_error "Invalid type: $type"
            return 1
            ;;
    esac
    
    return 1
}

# -------------------------------
# 2. File Functions
# -------------------------------

# Get file size in human-readable format
get_file_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        du -h "$file" | cut -f1
    else
        echo "0B"
    fi
}

# Get file modification time
get_file_mtime() {
    local file="$1"
    if [[ -f "$file" ]]; then
        stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file"
    else
        echo "N/A"
    fi
}

# Create directory with proper permissions
create_directory() {
    local dir="$1"
    local perms="${2:-750}"
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            return 1
        }
        chmod "$perms" "$dir" || {
            log_error "Failed to set permissions on directory: $dir"
            return 1
        }
    fi
    
    return 0
}

# -------------------------------
# 3. String Functions
# -------------------------------

# Trim whitespace
trim() {
    local str="$1"
    echo "${str#"${str%%[![:space:]]*}"}"
    echo "${str%"${str##*[![:space:]]}"}"
}

# Check if string contains substring
contains() {
    local str="$1"
    local substr="$2"
    [[ "$str" == *"$substr"* ]]
}

# -------------------------------
# 4. Array Functions
# -------------------------------

# Join array elements with delimiter
join_by() {
    local d="${1:-,}"
    shift
    echo -n "$1"
    shift
    printf "%s" "${@/#/$d}"
}

# Check if array contains element
array_contains() {
    local needle="$1"
    shift
    local haystack=("$@")
    printf '%s\n' "${haystack[@]}" | grep -q "^${needle}$"
}

# -------------------------------
# 5. System Functions
# -------------------------------

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Get system memory info
get_memory_info() {
    local total free used
    if [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f GB\n", "$1:", $2 * $size / 1024/1024/1024);'
    else
        free -h
    fi
}

# Get system load average
get_load_avg() {
    uptime | awk -F'load averages:' '{ print $2 }'
}

# -------------------------------
# 6. Development Functions
# -------------------------------

# Create Python virtual environment
create_venv() {
    local venv_path="${1:-venv}"
    if [[ ! -d "$venv_path" ]]; then
        python3 -m venv "$venv_path" || {
            log_error "Failed to create virtual environment"
            return 1
        }
        log_info "Created virtual environment at $venv_path"
    else
        log_warning "Virtual environment already exists at $venv_path"
    fi
    return 0
}

# Run tests with coverage
run_tests() {
    local path="${1:-.}"
    local coverage_min="${2:-80}"
    
    if ! command_exists pytest; then
        log_error "pytest not found"
        return 1
    fi
    
    pytest --cov="$path" --cov-fail-under="$coverage_min" || {
        log_error "Tests failed or coverage below ${coverage_min}%"
        return 1
    }
    
    return 0
}

# -------------------------------
# 7. Utility Functions
# -------------------------------

# Get timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Generate random string
generate_random_string() {
    local length="${1:-32}"
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
}

# -------------------------------
# 8. Exports
# -------------------------------

# Export utility functions
functions[clean_path]=$functions[clean_path]
functions[verify_path]=$functions[verify_path]
functions[get_file_size]=$functions[get_file_size]
functions[get_file_mtime]=$functions[get_file_mtime]
functions[create_directory]=$functions[create_directory]
functions[trim]=$functions[trim]
functions[contains]=$functions[contains]
functions[join_by]=$functions[join_by]
functions[array_contains]=$functions[array_contains]
functions[command_exists]=$functions[command_exists]
functions[get_memory_info]=$functions[get_memory_info]
functions[get_load_avg]=$functions[get_load_avg]
functions[create_venv]=$functions[create_venv]
functions[run_tests]=$functions[run_tests]
functions[get_timestamp]=$functions[get_timestamp]
functions[generate_random_string]=$functions[generate_random_string]

# ----------------------------------------------------------------------------