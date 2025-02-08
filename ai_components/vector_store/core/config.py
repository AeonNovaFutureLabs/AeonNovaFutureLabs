"""Configuration for ANFL Vector Store."""

from typing import Dict, Optional
from pydantic import BaseModel, Field


class PostgresConfig(BaseModel):
    """PostgreSQL configuration."""
    host: str = Field(..., description="PostgreSQL host")
    port: int = Field(5432, description="PostgreSQL port")
    database: str = Field(..., description="Database name")
    user: str = Field(..., description="Database user")
    password: str = Field(..., description="Database password")
    min_size: int = Field(5, description="Minimum connection pool size")
    max_size: int = Field(20, description="Maximum connection pool size")


class RedisConfig(BaseModel):
    """Redis configuration for hot cache."""
    host: str = Field(..., description="Redis host")
    port: int = Field(6379, description="Redis port")
    db: int = Field(0, description="Redis database number")
    password: Optional[str] = Field(None, description="Redis password")
    ttl: int = Field(3600, description="Default TTL for cached items in seconds")


class AstraDBConfig(BaseModel):
    """AstraDB configuration for warm cache."""
    database_id: str = Field(..., description="AstraDB database identifier")
    region: str = Field(..., description="AstraDB region")
    keyspace: str = Field(..., description="AstraDB keyspace")
    application_token: str = Field(..., description="AstraDB application token")
    collection_name: str = Field("vector_store", description="Collection name for vectors")
    ttl: int = Field(86400, description="Default TTL for warm cache in seconds")  # 24 hours


class PineconeConfig(BaseModel):
    """Pinecone configuration for cold storage."""
    api_key: str = Field(..., description="Pinecone API key")
    environment: str = Field(..., description="Pinecone environment")
    index_name: str = Field(..., description="Pinecone index name")
    dimension: int = Field(3072, description="Vector dimension")
    metric: str = Field("cosine", description="Distance metric")


class VectorStoreConfig(BaseModel):
    """Main vector store configuration."""
    postgres: PostgresConfig = Field(..., description="PostgreSQL configuration")
    redis: RedisConfig = Field(..., description="Redis hot cache configuration")
    astradb: AstraDBConfig = Field(..., description="AstraDB warm cache configuration")
    pinecone: PineconeConfig = Field(..., description="Pinecone cold storage configuration")
    
    # Cache settings
    hot_cache_enabled: bool = Field(True, description="Enable Redis hot cache")
    warm_cache_enabled: bool = Field(True, description="Enable AstraDB warm cache")
    
    # Cache thresholds (days)
    hot_cache_threshold: int = Field(1, description="Days to keep in hot cache")
    warm_cache_threshold: int = Field(7, description="Days to keep in warm cache")
    
    # Batch processing
    batch_size: int = Field(100, description="Batch size for vector operations")
    max_retries: int = Field(3, description="Maximum retry attempts")
    retry_delay: int = Field(5, description="Delay between retries in seconds")

    class Config:
        """Pydantic config."""
        env_prefix = "ANFL_VECTOR_"
        case_sensitive = True


def load_config(config_dict: Optional[Dict] = None) -> VectorStoreConfig:
    """Load vector store configuration from environment or dict."""
    if config_dict:
        return VectorStoreConfig.parse_obj(config_dict)
    return VectorStoreConfig.parse_obj({})  # Will load from environment variables