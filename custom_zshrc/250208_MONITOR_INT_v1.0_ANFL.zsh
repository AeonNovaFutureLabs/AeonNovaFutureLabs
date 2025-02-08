# ----------------------------------------------------------------------------
# File: 250208_MONITOR_INT_v1.0_ANFL.zsh
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/custom_zshrc/
#
# Purpose: Monitoring system integration and metrics collection for ANFL framework
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
#
# References:
# - 250208_SHELL_MAIN_INT_v1.0_ANFL.zsh
# - 250208_ERROR_HANDLER_INT_v1.0_ANFL.zsh
# - 250208_LOGGING_INT_v1.0_ANFL.zsh
# ----------------------------------------------------------------------------

# BLUF: Provides monitoring integration, metrics collection, and health checks for ANFL framework

# Enable strict mode
emulate -L zsh
setopt ERR_RETURN PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS WARN_CREATE_GLOBAL

# -------------------------------
# 1. Monitoring Configuration
# -------------------------------

# Define monitoring states
typeset -gA MONITOR_STATES
MONITOR_STATES=(
    [STOPPED]=0
    [STARTING]=1
    [RUNNING]=2
    [ERROR]=3
    [DEGRADED]=4
)

# Current monitoring state
: ${MONITOR_STATE:=$MONITOR_STATES[STOPPED]}

# Monitoring configuration
: ${PROMETHEUS_PORT:=9090}
: ${GRAFANA_PORT:=3000}
: ${NODE_EXPORTER_PORT:=9100}

# -------------------------------
# 2. Health Checks
# -------------------------------

# Check Prometheus health
function check_prometheus() {
    if curl -s "http://localhost:${PROMETHEUS_PORT}/-/healthy" > /dev/null; then
        return "${ERROR_CODES[SUCCESS]}"
    else
        log_error "Prometheus health check failed"
        return "${ERROR_CODES[MONITORING_ERROR]}"
    fi
}

# Check Grafana health
function check_grafana() {
    if curl -s "http://localhost:${GRAFANA_PORT}/api/health" > /dev/null; then
        return "${ERROR_CODES[SUCCESS]}"
    else
        log_error "Grafana health check failed"
        return "${ERROR_CODES[MONITORING_ERROR]}"
    fi
}

# Check Node Exporter health
function check_node_exporter() {
    if curl -s "http://localhost:${NODE_EXPORTER_PORT}/metrics" > /dev/null; then
        return "${ERROR_CODES[SUCCESS]}"
    else
        log_error "Node Exporter health check failed"
        return "${ERROR_CODES[MONITORING_ERROR]}"
    fi
}

# -------------------------------
# 3. Metrics Collection
# -------------------------------

# Collect system metrics
function collect_system_metrics() {
    local output_file="${ANFL_LOGS}/monitoring/system_metrics.json"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Collect CPU metrics
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | cut -d% -f1)
    
    # Collect memory metrics
    local memory_usage=$(vm_stat | awk '/free/ {free=$3} /active/ {active=$3} /inactive/ {inactive=$3} /speculative/ {speculative=$3} /wired/ {wired=$4} END {total=(free+active+inactive+speculative+wired)*4096/1024/1024; print total}')
    
    # Collect disk metrics
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d% -f1)
    
    # Create metrics JSON
    cat > "$output_file" << EOF
{
    "timestamp": "${timestamp}",
    "metrics": {
        "cpu_usage": ${cpu_usage},
        "memory_usage_mb": ${memory_usage},
        "disk_usage_percent": ${disk_usage}
    }
}
EOF
}

# Collect framework metrics
function collect_framework_metrics() {
    local output_file="${ANFL_LOGS}/monitoring/framework_metrics.json"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Count active processes
    local process_count=$(ps aux | grep -i "anfl" | grep -v grep | wc -l)
    
    # Count open file descriptors
    local fd_count=$(lsof -u $USER | grep -i "anfl" | wc -l)
    
    # Create metrics JSON
    cat > "$output_file" << EOF
{
    "timestamp": "${timestamp}",
    "metrics": {
        "process_count": ${process_count},
        "file_descriptor_count": ${fd_count},
        "security_state": "${(k)SECURITY_STATES[(r)$SECURITY_STATE]}",
        "deploy_state": "${(k)DEPLOY_STATES[(r)$DEPLOY_STATE]}"
    }
}
EOF
}

# -------------------------------
# 4. Monitoring Operations
# -------------------------------

# Start monitoring services
function start_monitoring() {
    MONITOR_STATE=$MONITOR_STATES[STARTING]
    log_info "Starting monitoring services..."
    
    # Start Prometheus
    if ! pgrep prometheus > /dev/null; then
        prometheus \
            --config.file="${ANFL_ROOT}/infrastructure/monitoring/prometheus/prometheus-config.yaml" \
            --storage.tsdb.path="${ANFL_LOGS}/monitoring/prometheus" \
            --web.listen-address=":${PROMETHEUS_PORT}" \
            > "${ANFL_LOGS}/monitoring/prometheus.log" 2>&1 &
    fi
    
    # Start Grafana
    if ! pgrep grafana-server > /dev/null; then
        grafana-server \
            --config="${ANFL_ROOT}/infrastructure/monitoring/grafana/grafana-config.yaml" \
            --homepath="/usr/share/grafana" \
            > "${ANFL_LOGS}/monitoring/grafana.log" 2>&1 &
    fi
    
    # Start Node Exporter
    if ! pgrep node_exporter > /dev/null; then
        node_exporter \
            --web.listen-address=":${NODE_EXPORTER_PORT}" \
            > "${ANFL_LOGS}/monitoring/node_exporter.log" 2>&1 &
    fi
    
    # Wait for services to start
    sleep 5
    
    # Check health
    if check_prometheus && check_grafana && check_node_exporter; then
        MONITOR_STATE=$MONITOR_STATES[RUNNING]
        log_info "Monitoring services started successfully"
        return "${ERROR_CODES[SUCCESS]}"
    else
        MONITOR_STATE=$MONITOR_STATES[ERROR]
        log_error "Failed to start monitoring services"
        return "${ERROR_CODES[MONITORING_ERROR]}"
    fi
}

# Stop monitoring services
function stop_monitoring() {
    log_info "Stopping monitoring services..."
    
    pkill prometheus
    pkill grafana-server
    pkill node_exporter
    
    MONITOR_STATE=$MONITOR_STATES[STOPPED]
    log_info "Monitoring services stopped"
}

# Initialize monitoring
function init_monitoring() {
    log_info "Initializing monitoring system..."
    
    # Create monitoring directories
    mkdir -p "${ANFL_LOGS}/monitoring/prometheus"
    mkdir -p "${ANFL_LOGS}/monitoring/grafana"
    
    # Start monitoring services
    start_monitoring || return $?
    
    # Set up metric collection
    collect_system_metrics
    collect_framework_metrics
    
    log_info "Monitoring system initialized successfully"
    return "${ERROR_CODES[SUCCESS]}"
}

# Get monitoring status
function get_monitoring_status() {
    print -P "%F{cyan}Monitoring Status:%f"
    print -P "State: %F{green}${(k)MONITOR_STATES[(r)$MONITOR_STATE]}%f"
    print -P "Prometheus: %F{green}$(pgrep prometheus >/dev/null && echo "Running" || echo "Stopped")%f"
    print -P "Grafana: %F{green}$(pgrep grafana-server >/dev/null && echo "Running" || echo "Stopped")%f"
    print -P "Node Exporter: %F{green}$(pgrep node_exporter >/dev/null && echo "Running" || echo "Stopped")%f"
}

# -------------------------------
# 5. Exports
# -------------------------------

# Export monitoring states
typeset -gx MONITOR_STATES MONITOR_STATE

# Export functions
typeset -fx init_monitoring start_monitoring stop_monitoring
typeset -fx check_prometheus check_grafana check_node_exporter
typeset -fx collect_system_metrics collect_framework_metrics
typeset -fx get_monitoring_status

# ----------------------------------------------------------------------------