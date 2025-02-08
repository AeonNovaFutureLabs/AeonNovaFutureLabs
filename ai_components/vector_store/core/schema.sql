-- ANFL Vector Store Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Vector metadata table
CREATE TABLE IF NOT EXISTS vector_metadata (
    vector_id TEXT PRIMARY KEY,
    metadata JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    embedding_model TEXT,
    dimension INTEGER,
    namespace TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Create index on namespace for faster queries
CREATE INDEX IF NOT EXISTS idx_vector_metadata_namespace ON vector_metadata(namespace);
CREATE INDEX IF NOT EXISTS idx_vector_metadata_updated ON vector_metadata(updated_at);

-- Cache tracking table
CREATE TABLE IF NOT EXISTS cache_tracking (
    vector_id TEXT REFERENCES vector_metadata(vector_id),
    cache_layer TEXT NOT NULL, -- 'hot', 'warm', or 'cold'
    cached_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    last_accessed TIMESTAMP WITH TIME ZONE,
    access_count INTEGER DEFAULT 0,
    PRIMARY KEY (vector_id, cache_layer)
);

-- Create index for cache expiration queries
CREATE INDEX IF NOT EXISTS idx_cache_tracking_expires ON cache_tracking(expires_at);

-- Vector operations log
CREATE TABLE IF NOT EXISTS vector_operations (
    operation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vector_id TEXT REFERENCES vector_metadata(vector_id),
    operation_type TEXT NOT NULL, -- 'insert', 'update', 'delete', 'query'
    operation_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cache_layer TEXT NOT NULL,
    status TEXT NOT NULL, -- 'success', 'failure'
    error_message TEXT,
    metadata JSONB
);

-- Create index for operation tracking
CREATE INDEX IF NOT EXISTS idx_vector_operations_time ON vector_operations(operation_time);
CREATE INDEX IF NOT EXISTS idx_vector_operations_type ON vector_operations(operation_type);

-- Vector similarity queries log
CREATE TABLE IF NOT EXISTS similarity_queries (
    query_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    query_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    namespace TEXT,
    top_k INTEGER NOT NULL,
    query_vector_dimension INTEGER NOT NULL,
    filter_criteria JSONB,
    execution_time_ms INTEGER,
    cache_hits JSONB, -- Track which cache layers were hit
    num_results INTEGER,
    metadata JSONB
);

-- Create index for query analysis
CREATE INDEX IF NOT EXISTS idx_similarity_queries_time ON similarity_queries(query_time);
CREATE INDEX IF NOT EXISTS idx_similarity_queries_namespace ON similarity_queries(namespace);

-- Cache performance metrics
CREATE TABLE IF NOT EXISTS cache_metrics (
    metric_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cache_layer TEXT NOT NULL,
    hit_count INTEGER DEFAULT 0,
    miss_count INTEGER DEFAULT 0,
    eviction_count INTEGER DEFAULT 0,
    total_vectors INTEGER DEFAULT 0,
    total_size_bytes BIGINT DEFAULT 0,
    avg_query_time_ms FLOAT,
    metadata JSONB
);

-- Create index for metrics analysis
CREATE INDEX IF NOT EXISTS idx_cache_metrics_time ON cache_metrics(timestamp, cache_layer);

-- Vector migrations log
CREATE TABLE IF NOT EXISTS vector_migrations (
    migration_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vector_id TEXT REFERENCES vector_metadata(vector_id),
    source_layer TEXT NOT NULL,
    target_layer TEXT NOT NULL,
    migration_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL, -- 'ttl_expired', 'manual', 'policy'
    status TEXT NOT NULL, -- 'success', 'failure'
    error_message TEXT,
    metadata JSONB
);

-- Create index for migration tracking
CREATE INDEX IF NOT EXISTS idx_vector_migrations_time ON vector_migrations(migration_time);

-- Functions

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for vector_metadata
CREATE TRIGGER update_vector_metadata_modtime
    BEFORE UPDATE ON vector_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update cache access tracking
CREATE OR REPLACE FUNCTION update_cache_access()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE cache_tracking
    SET last_accessed = CURRENT_TIMESTAMP,
        access_count = access_count + 1
    WHERE vector_id = NEW.vector_id
    AND cache_layer = NEW.cache_layer;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for cache tracking
CREATE TRIGGER update_cache_access_trigger
    AFTER INSERT ON vector_operations
    FOR EACH ROW
    WHEN (NEW.operation_type = 'query')
    EXECUTE FUNCTION update_cache_access();