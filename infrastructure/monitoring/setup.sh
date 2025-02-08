#!/bin/bash
# ANFL Monitoring Setup Script
# Version: 1.0.0

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Base paths
PROJECT_ROOT="/Volumes/mattstack/VSCode/AeonNovaFutureLabs"
MONITORING_DIR="${PROJECT_ROOT}/infrastructure/monitoring"

# Verify environment variables
verify_env() {
    echo "Verifying environment variables..."
    
    required_vars=(
        "ANFL_GRAFANA_PORT"
        "ANFL_GRAFANA_ADMIN_USER"
        "ANFL_GRAFANA_ADMIN_PASSWORD"
        "ANFL_GRAFANA_SECRET_KEY"
        "ANFL_VAULT_ADDR"
        "ANFL_ENVIRONMENT"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "${RED}Error: Required environment variable $var is not set${NC}"
            exit 1
        fi
    done
    
    echo "${GREEN}Environment verification successful${NC}"
}

# Validate configurations
validate_configs() {
    echo "Validating configurations..."
    
    # Check Prometheus config
    if [ ! -f "${MONITORING_DIR}/prometheus/prometheus-config.yaml" ]; then
        echo "${RED}Error: Prometheus configuration not found${NC}"
        exit 1
    fi
    
    # Check Grafana config
    if [ ! -f "${MONITORING_DIR}/grafana/grafana-config.yaml" ]; then
        echo "${RED}Error: Grafana configuration not found${NC}"
        exit 1
    }
    
    # Check alert rules
    if [ ! -f "${MONITORING_DIR}/alerts/rules.yml" ]; then
        echo "${RED}Error: Alert rules not found${NC}"
        exit 1
    }
    
    echo "${GREEN}Configuration validation successful${NC}"
}

# Create necessary directories
setup_directories() {
    echo "Setting up log directories..."
    
    mkdir -p "${MONITORING_DIR}/logs/prometheus"
    mkdir -p "${MONITORING_DIR}/logs/grafana"
    
    echo "${GREEN}Directory setup successful${NC}"
}

# Start monitoring services
start_services() {
    echo "Starting monitoring services..."
    
    # Start Prometheus (assumes prometheus is installed)
    prometheus \
        --config.file="${MONITORING_DIR}/prometheus/prometheus-config.yaml" \
        --storage.tsdb.path="${MONITORING_DIR}/data/prometheus" \
        --web.listen-address=":9090" \
        --log.level="info" \
        > "${MONITORING_DIR}/logs/prometheus/prometheus.log" 2>&1 &
    
    # Start Grafana (assumes grafana is installed)
    grafana-server \
        --config="${MONITORING_DIR}/grafana/grafana-config.yaml" \
        --homepath="/usr/share/grafana" \
        > "${MONITORING_DIR}/logs/grafana/grafana.log" 2>&1 &
    
    echo "${GREEN}Services started successfully${NC}"
}

# Validate service health
validate_health() {
    echo "Validating service health..."
    
    # Wait for services to start
    sleep 5
    
    # Check Prometheus
    if ! curl -s "http://localhost:9090/-/healthy" > /dev/null; then
        echo "${RED}Error: Prometheus health check failed${NC}"
        exit 1
    fi
    
    # Check Grafana
    if ! curl -s "http://localhost:${ANFL_GRAFANA_PORT}/api/health" > /dev/null; then
        echo "${RED}Error: Grafana health check failed${NC}"
        exit 1
    fi
    
    echo "${GREEN}Health validation successful${NC}"
}

# Main execution
main() {
    echo "Starting ANFL monitoring setup..."
    
    verify_env
    validate_configs
    setup_directories
    start_services
    validate_health
    
    echo "${GREEN}Monitoring setup completed successfully!${NC}"
    echo -e "\nAccess Points:"
    echo "- Grafana: http://localhost:${ANFL_GRAFANA_PORT}"
    echo "- Prometheus: http://localhost:9090"
    echo -e "\nLog Files:"
    echo "- Prometheus: ${MONITORING_DIR}/logs/prometheus/prometheus.log"
    echo "- Grafana: ${MONITORING_DIR}/logs/grafana/grafana.log"
}

# Execute main function
main