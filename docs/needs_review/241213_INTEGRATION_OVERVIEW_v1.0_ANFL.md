# Integration Overview Diagram

```mermaid
sequenceDiagram
    participant User
    participant API as API Gateway
    participant Auth as Auth Service (Vault/JWT)
    participant RAG as RAG System
    participant VS as Vector Store
    participant Model as Model Registry (Blockchain Verified)
    participant Monitor as Monitoring (Prometheus/Grafana)

    User->>API: Request (NLP Query)
    API->>Auth: Authenticate (Vault Token/JWT)
    Auth-->>API: Token Valid

    API->>RAG: Retrieve Context
    RAG->>VS: Vector Query
    VS-->>RAG: Relevant Embeddings/Docs

    RAG->>Model: Fetch Model Version
    Model-->>RAG: Model + Metadata

    RAG->>API: Augmented Response

    API-->>User: Response with Context

    Note over Monitor: Metrics collected at each stage, alerts triggered if anomalies detected
