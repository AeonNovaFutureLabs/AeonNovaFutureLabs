# AI Components Helm Chart

## Overview

This Helm chart deploys the ANFL AI components, including:
- Chat scraper for Claude and ChatGPT
- Vector store integration
- Monitoring and metrics
- Security policies

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Prometheus Operator (for monitoring)
- Persistent storage support
- Network policy support

## Installation

1. Add the ANFL Helm repository:
```bash
helm repo add anfl https://charts.aeonnovafuturelabs.com
helm repo update
```

2. Install the chart:
```bash
# For staging
helm install ai-components anfl/ai-components \
  --namespace anfl-staging \
  --create-namespace \
  --values values-staging.yaml \
  --set secrets.OPENWEATHER_API_KEY=<your-key>

# For production
helm install ai-components anfl/ai-components \
  --namespace anfl-production \
  --create-namespace \
  --values values-production.yaml \
  --set secrets.OPENWEATHER_API_KEY=<your-key>
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.environment` | Environment name | `development` |
| `global.imageRegistry` | Container registry | `ghcr.io/aeonnovafuturelabs` |
| `aiComponents.replicas` | Number of replicas | `3` |
| `aiComponents.resources` | Resource requests/limits | See `values.yaml` |
| `chatScraper.maxConcurrentSessions` | Max concurrent scraping sessions | `5` |
| `vectorStore.dimension` | Vector dimension | `1536` |
| `monitoring.enabled` | Enable monitoring | `true` |
| `security.networkPolicy.enabled` | Enable network policies | `true` |

### Environment-specific Values

- `values.yaml`: Default values
- `values-staging.yaml`: Staging environment
- `values-production.yaml`: Production environment

### Secrets

Required secrets:
- `OPENWEATHER_API_KEY`: API key for weather data
- `SNYK_TOKEN`: Token for security scanning

## Architecture

### Components

1. Chat Scraper
   - Puppeteer-based web scraping
   - Rate limiting and retry logic
   - Session management

2. Vector Store
   - High-dimensional vector storage
   - Multi-layer caching
   - Similarity search

3. Monitoring
   - Prometheus metrics
   - Grafana dashboards
   - Health checks

### Security

- Network policies for pod isolation
- Non-root container execution
- Read-only root filesystem
- Resource quotas and limits

## Monitoring

### Metrics

Available metrics:
- Scraping success rate
- Vector store latency
- Cache hit/miss ratio
- Resource utilization

### Dashboards

Pre-configured Grafana dashboards:
- System overview
- Scraper performance
- Vector store analytics
- Error tracking

## Scaling

### Horizontal Pod Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Resource Management

Production recommended settings:
```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 1000m
    memory: 2Gi
```

## Troubleshooting

### Common Issues

1. Pod startup failure
   - Check resource limits
   - Verify secret configuration
   - Check network policies

2. Scraping errors
   - Verify API keys
   - Check rate limits
   - Review browser logs

3. Vector store issues
   - Verify persistence configuration
   - Check cache settings
   - Monitor memory usage

### Debugging

```bash
# Get pod logs
kubectl logs -n anfl-production -l app.kubernetes.io/name=ai-components

# Check pod status
kubectl describe pod -n anfl-production -l app.kubernetes.io/name=ai-components

# Port forward for local access
kubectl port-forward -n anfl-production svc/ai-components-service 3000:80
```

## Development

### Local Testing

1. Install dependencies:
```bash
cd ai_components/scraper
npm install
```

2. Run tests:
```bash
npm test
```

3. Local deployment:
```bash
helm install ai-components . \
  --namespace anfl-dev \
  --create-namespace \
  --values values.yaml \
  --set global.environment=development
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Submit a pull request

## Support

For support:
1. Check documentation
2. Review issue tracker
3. Contact infrastructure team

## License

Confidential and proprietary. All rights reserved.
© 2025 Aeon Nova Future Labs