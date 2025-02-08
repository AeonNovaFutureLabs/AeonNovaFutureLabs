# Development Environment Setup Guide

## Prerequisites

### Required Software
```yaml
core_requirements:
  - Node.js >= 18.0.0
  - Docker Desktop
  - Kubernetes (via Docker Desktop)
  - Git
  - VSCode
  - Python >= 3.8

package_managers:
  - npm/yarn
  - pip
  - homebrew (for macOS)
```

## VSCode Setup

### 1. Extensions
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-azuretools.vscode-docker",
    "GraphQL.vscode-graphql",
    "christian-kohler.path-intellisense",
    "GitHub.copilot",
    "eamodio.gitlens"
  ]
}
```

### 2. Workspace Settings
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true
}
```

## Project Setup

### 1. Clone Repository
```bash
# Clone the repository
git clone https://github.com/AeonNovaFutureLabs/aeon-nova-ai.git
cd aeon-nova-ai

# Install dependencies
npm install
```

### 2. Environment Configuration
```bash
# Create environment file
cp .env.example .env

# Configure environment variables
cat << EOF > .env
ASTRA_DB_ID=your_db_id
ASTRA_DB_REGION=your_region
ASTRA_DB_KEYSPACE=your_keyspace
ASTRA_DB_APPLICATION_TOKEN=your_token

LINEAR_API_KEY=your_linear_key
NOTION_API_KEY=your_notion_key

GITHUB_TOKEN=your_github_token
EOF
```

### 3. Local Development Setup
```bash
# Start development environment
npm run dev

# Start with Docker
docker-compose up -d

# Access development environment
http://localhost:3000
```

## Docker Configuration

### 1. Development Container
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000
CMD ["npm", "run", "dev"]
```

### 2. Docker Compose Setup
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
  
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
```

## Kubernetes Setup

### 1. Local Cluster Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  NODE_ENV: development
  API_URL: http://localhost:8080

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aeon-nova-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aeon-nova
  template:
    metadata:
      labels:
        app: aeon-nova
    spec:
      containers:
      - name: app
        image: aeon-nova-dev
        ports:
        - containerPort: 3000
```

## Development Workflow

### 1. Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push changes
git push origin feature/new-feature
```

### 2. Testing
```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration

# Run e2e tests
npm run test:e2e
```

### 3. Code Quality
```bash
# Run linter
npm run lint

# Run type checking
npm run type-check

# Run all checks
npm run verify
```

## Platform Integration Setup

### 1. Linear Integration
```typescript
// Configure Linear client
import { LinearClient } from "@linear/sdk";

const linearClient = new LinearClient({
  apiKey: process.env.LINEAR_API_KEY
});
```

### 2. Notion Integration
```typescript
// Configure Notion client
import { Client } from "@notionhq/client";

const notion = new Client({
  auth: process.env.NOTION_API_KEY
});
```

### 3. Figma Integration
```typescript
// Configure Figma API access
const figmaAccessToken = process.env.FIGMA_ACCESS_TOKEN;
const figmaFileKey = 'your-file-key';
```

## Troubleshooting Guide

### Common Issues

1. Node Module Issues
```bash
# Clear node modules and reinstall
rm -rf node_modules
npm install
```

2. Docker Issues
```bash
# Reset Docker environment
docker-compose down -v
docker-compose up --build
```

3. Kubernetes Issues
```bash
# Reset Kubernetes deployment
kubectl delete deployment aeon-nova-dev
kubectl apply -f k8s/development
```

### Performance Optimization

1. Development Performance
```yaml
optimization:
  - Use development containers
  - Enable hot reloading
  - Implement efficient caching
  - Use development-specific configurations
```

2. Resource Management
```yaml
resource_limits:
  development:
    cpu: "1"
    memory: "2Gi"
  testing:
    cpu: "2"
    memory: "4Gi"
```

## Security Considerations

### Local Security Setup
```yaml
security:
  - Use environment variables for secrets
  - Implement proper CORS settings
  - Enable security headers
  - Use secure connections for APIs
```

### Development Guidelines
```yaml
guidelines:
  - Never commit sensitive data
  - Use .gitignore properly
  - Implement proper access controls
  - Regular security updates
```