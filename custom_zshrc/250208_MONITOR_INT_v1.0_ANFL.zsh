# ----------------------------------------------------------------------------
# File: 250208_MONITOR_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Monitoring and metrics functions for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides monitoring and metrics functionality for the ANFL framework

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Monitor States
# -------------------------------

# Define monitor states
declare -gA MONITOR_STATES
MONITOR_STATES=(
    [STOPPED]=0
    [STARTING]=1
    [RUNNING]=2
    [ERROR]=3
)

# Current monitor state
: ${MONITOR_STATE:=$MONITOR_STATES[STOPPED]}

# -------------------------------
# 2. Monitor Configuration
# -------------------------------

# Define paths
: ${MONITOR_CONFIG:="${ANFL_ROOT}/infrastructure/monitoring"}
: ${MONITOR_LOGS:="${ANFL_LOGS}/monitoring"}

# Define ports
: ${PROMETHEUS_PORT:=9090}
: ${GRAFANA_PORT:=3000}

# -------------------------------
# 3. Core Functions
# -------------------------------

# Initialize monitoring
init_monitoring() {
    local monitor_state
    monitor_state=$MONITOR_STATES[STARTING]
    MONITOR_STATE=$monitor_state
    
    # Create required directories
    if ! create_directory "$MONITOR_LOGS"; then
        monitor_state=$MONITOR_STATES[ERROR]
        MONITOR_STATE=$monitor_state
        return 1
    fi
    
    # Verify configuration
    if [[ ! -d "$MONITOR_CONFIG" ]]; then
        log_error "Monitoring configuration not found"
        monitor_state=$MONITOR_STATES[ERROR]
        MONITOR_STATE=$monitor_state
        return 1
    fi
    
    # Initialize state
    monitor_state=$MONITOR_STATES[RUNNING]
    MONITOR_STATE=$monitor_state
    log_info "Monitoring initialized"
    return 0
}

# Start monitoring stack
start_monitoring() {
    if [[ $MONITOR_STATE == $MONITOR_STATES[RUNNING] ]]; then
        log_warning "Monitoring already running"
        return 0
    fi
    
    log_info "Starting monitoring stack..."
    
    # Start Prometheus
    if ! pgrep prometheus >/dev/null; then
        cd "$MONITOR_CONFIG/prometheus" && {
            docker-compose up -d || {
                log_error "Failed to start Prometheus"
                return 1
            }
        }
    fi
    
    # Start Grafana
    if ! pgrep grafana-server >/dev/null; then
        cd "$MONITOR_CONFIG/grafana" && {
            docker-compose up -d || {
                log_error "Failed to start Grafana"
                return 1
            }
        }
    fi
    
    MONITOR_STATE=$MONITOR_STATES[RUNNING]
    log_info "Monitoring stack started"
    return 0
}

# Stop monitoring stack
stop_monitoring() {
    if [[ $MONITOR_STATE == $MONITOR_STATES[STOPPED] ]]; then
        log_warning "Monitoring already stopped"
        return 0
    fi
    
    log_info "Stopping monitoring stack..."
    
    # Stop Prometheus
    cd "$MONITOR_CONFIG/prometheus" && {
        docker-compose down || log_warning "Failed to stop Prometheus"
    }
    
    # Stop Grafana
    cd "$MONITOR_CONFIG/grafana" && {
        docker-compose down || log_warning "Failed to stop Grafana"
    }
    
    MONITOR_STATE=$MONITOR_STATES[STOPPED]
    log_info "Monitoring stack stopped"
    return 0
}

# -------------------------------
# 4. Metric Functions
# -------------------------------

# Check monitoring status
check_monitoring() {
    local prometheus_status="Stopped"
    local grafana_status="Stopped"
    
    # Check Prometheus
    if pgrep prometheus >/dev/null; then
        prometheus_status="Running"
    fi
    
    # Check Grafana
    if pgrep grafana-server >/dev/null; then
        grafana_status="Running"
    fi
    
    print -P "%F{cyan}Monitoring Status:%f"
    print -P "  Prometheus: %F{yellow}${prometheus_status}%f"
    print -P "  Grafana: %F{yellow}${grafana_status}%f"
    
    return 0
}

# Get system metrics
get_system_metrics() {
    print -P "%F{cyan}System Metrics:%f"
    
    # CPU Load
    print -P "  CPU Load: %F{yellow}$(get_load_avg)%f"
    
    # Memory Usage
    print -P "  Memory Usage:"
    get_memory_info | while read -r line; do
        print -P "    %F{yellow}${line}%f"
    done
    
    # Disk Usage
    print -P "  Disk Usage:"
    df -h | grep -v "^Filesystem" | while read -r line; do
        print -P "    %F{yellow}${line}%f"
    done
    
    return 0
}

# -------------------------------
# 5. Utility Functions
# -------------------------------

# Open monitoring dashboard
open_monitoring() {
    if [[ $MONITOR_STATE != $MONITOR_STATES[RUNNING] ]]; then
        log_error "Monitoring not running"
        return 1
    fi
    
    # Open Grafana
    open "http://localhost:${GRAFANA_PORT}" || {
        log_error "Failed to open Grafana dashboard"
        return 1
    }
    
    return 0
}

# View monitoring logs
view_monitor_logs() {
    local component="${1:-all}"
    
    case "$component" in
        prometheus)
            docker logs -f prometheus
            ;;
        grafana)
            docker logs -f grafana
            ;;
        all)
            docker logs -f prometheus & docker logs -f grafana
            ;;
        *)
            log_error "Invalid component: $component"
            return 1
            ;;
    esac
    
    return 0
}

# -------------------------------
# 6. Exports
# -------------------------------

# Export monitor states
export MONITOR_STATES MONITOR_STATE

# Export monitor configuration
export MONITOR_CONFIG MONITOR_LOGS
export PROMETHEUS_PORT GRAFANA_PORT

# Export functions
functions[init_monitoring]=$functions[init_monitoring]
functions[start_monitoring]=$functions[start_monitoring]
functions[stop_monitoring]=$functions[stop_monitoring]
functions[check_monitoring]=$functions[check_monitoring]
functions[get_system_metrics]=$functions[get_system_metrics]
functions[open_monitoring]=$functions[open_monitoring]
functions[view_monitor_logs]=$functions[view_monitor_logs]

# ----------------------------------------------------------------------------