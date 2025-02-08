# Aeon Nova Quick Reference Guide

## Common Tasks

### 1. Development Setup
```bash
# Initial setup
git clone git@github.com:AeonNovaFutureLabs/aeon-nova.git
cd aeon-nova
npm install

# Start development environment
docker-compose up -d
npm run dev

# Run tests
npm run test
```

### 2. Deployment Commands
```bash
# Deploy to staging
kubectl apply -k kubernetes/overlays/staging

# Deploy to production
kubectl apply -k kubernetes/overlays/production

# Check deployment status
kubectl get pods -n aeon-nova
```

### 3. Monitoring Commands
```bash
# Check logs
kubectl logs -l app=aeon-nova -n aeon-nova

# Get metrics
curl -X GET http://prometheus:9090/api/v1/query?query=aeon_nova_requests_total

# Access dashboards
open http://grafana.aeon-nova.ai
```

## Document Locations

### 1. Architecture Documents
- `/docs/architecture/`: System architecture diagrams
- `/docs/flows/`: Data flow documentation
- `/docs/decisions/`: Architecture decision records

### 2. Development Guides
- `/docs/setup/`: Environment setup guides
- `/docs/workflows/`: Development workflow guides
- `/docs/testing/`: Testing documentation

### 3. Infrastructure
- `/kubernetes/`: Kubernetes configurations
- `/terraform/`: Infrastructure as code
- `/monitoring/`: Monitoring configurations

## Common Links

### 1. Development Resources
- Documentation: https://docs.aeon-nova.ai
- API Reference: https://api.aeon-nova.ai/docs
- Component Library: https://components.aeon-nova.ai

### 2. Monitoring
- Grafana: https://grafana.aeon-nova.ai
- Prometheus: https://prometheus.aeon-nova.ai
- MLflow: https://mlflow.aeon-nova.ai

### 3. Project Management
- Linear: https://linear.app/aeon-nova
- GitHub: https://github.com/AeonNovaFutureLabs
- Notion: https://notion.so/aeon-nova

## Contact Information

### 1. Team Channels
- Engineering: #eng-team
- ML/AI: #ml-team
- DevOps: #devops-team
- General: #general

### 2. Emergency Contacts
- Platform Issues: platform-oncall@aeon-nova.ai
- Security Issues: security@aeon-nova.ai
- General Support: support@aeon-nova.ai