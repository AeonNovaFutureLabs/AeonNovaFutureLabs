# 241214_CONF_SEARCH_INT_v1.0_ANFL
# Framework-compliant search configuration
# Security Level: Internal
# Owner: Infrastructure Team

# Search categories mapping to implementation phases
SEARCH_CATEGORIES=(
  # Phase 1: Data Infrastructure
  "infrastructure:Infrastructure Components:*.tf,*.hcl,*.yaml,*.yml"
  "database:Database Scripts:*.sql,db_*.py,*_schema.py"
  "vector:Vector Store:*vector*.py,*pinecone*.py,*embedding*.py"
  "cache:Cache Layer:*redis*.py,*cache*.py"

  # Phase 2: Data Processing
  "processing:Processing Scripts:*processor*.py,*transform*.py"
  "pipeline:Data Pipelines:*pipeline*.py,*workflow*.py"
  "langchain:LangChain Integration:*chain*.py,*llm*.py,*agent*.py"
  "orchestrator:Orchestration:*orchestrator*.py,*scheduler*.py"

  # Phase 3: Monitoring & Management
  "monitoring:Monitoring Components:*monitor*.py,*metric*.py,*dashboard*.tsx"
  "logging:Logging System:*log*.py,*logger*.py"
  "security:Security Components:*auth*.py,*security*.py,*vault*.py"
  "backup:Backup Systems:*backup*.py,*archive*.py"

  # Phase 4: Integration Components
  "api:API Components:*api*.py,*service*.py,*endpoint*.py"
  "models:Model Management:*model*.py,*registry*.py"
  "scraping:Data Collection:*scraper*.py,*crawler*.py,*spider*.py"
  "testing:Test Components:*test*.py,*spec*.py"
)

# Framework-specific paths to search
FRAMEWORK_PATHS=(
  "$PROJECT_ROOT/infrastructure"
  "$PROJECT_ROOT/monitoring"
  "$PROJECT_ROOT/services"
  "$PROJECT_ROOT/scripts"
  "$PROJECT_ROOT/ai_model_testing"
  "$PROJECT_ROOT/company_docs"
  "$PROJECT_ROOT/terraform"
  "$PROJECT_ROOT/vault"
  "$PROJECT_ROOT/tests"
)

# Extended metadata collection configuration
METADATA_CONFIG='
{
  "collect": {
    "basic": [
      "filename",
      "path",
      "size",
      "modified",
      "extension"
    ],
    "content": [
      "imports",
      "class_definitions",
      "function_definitions"
    ],
    "security": [
      "permissions",
      "ownership",
      "sensitivity_level"
    ]
  },
  "analysis": {
    "code": [
      "langchain_usage",
      "database_connections",
      "api_endpoints",
      "model_references"
    ],
    "dependencies": [
      "external_imports",
      "internal_imports",
      "framework_references"
    ],
    "patterns": [
      "architectural_patterns",
      "design_patterns",
      "security_patterns"
    ]
  }
}'

# Extended report configuration
REPORT_CONFIG='
{
  "formats": {
    "json": {
      "path": "summary.json",
      "structure": "hierarchical"
    },
    "markdown": {
      "path": "report.md",
      "sections": [
        "overview",
        "categories",
        "statistics",
        "recommendations"
      ]
    },
    "mermaid": {
      "path": "architecture.mmd",
      "diagrams": [
        "component_relationships",
        "data_flow",
        "system_architecture"
      ]
    }
  },
  "visualizations": {
    "diagrams": true,
    "dependency_graphs": true,
    "component_maps": true
  },
  "metrics": {
    "code_stats": true,
    "dependencies": true,
    "coverage": true
  }
}'

# Search result processor configuration
PROCESSOR_CONFIG='
{
  "analysis": {
    "code": {
      "detect_frameworks": true,
      "find_dependencies": true,
      "identify_patterns": true
    },
    "architecture": {
      "map_relationships": true,
      "detect_components": true,
      "analyze_flow": true
    },
    "security": {
      "scan_secrets": true,
      "check_permissions": true,
      "validate_patterns": true
    }
  },
  "classification": {
    "by_component": true,
    "by_function": true,
    "by_dependency": true
  },
  "recommendations": {
    "consolidation": true,
    "optimization": true,
    "security": true
  }
}'

# Mermaid diagram configuration
DIAGRAM_CONFIG='
graph TB
    subgraph Collection["Data Collection"]
        FS[File Scanner]
        MT[Metadata Collector]
        DC[Data Classifier]
    end

    subgraph Analysis["Data Analysis"]
        CP[Code Parser]
        DP[Dependency Analyzer]
        SA[Security Analyzer]
    end

    subgraph Integration["Framework Integration"]
        LC[LangChain]
        VS[Vector Store]
        DB[Database]
    end

    Collection --> Analysis
    Analysis --> Integration
'
