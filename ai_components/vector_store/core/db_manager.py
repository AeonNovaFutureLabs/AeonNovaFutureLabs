"""Database manager for ANFL Vector Store."""

import asyncio
import logging
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple

import aioredis
import pinecone
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
from asyncpg import create_pool

from .config import VectorStoreConfig
from .exceptions import (
    HotCacheError,
    WarmCacheError,
    ColdStorageError,
    MetadataError,
    StorageLayerUnavailableError
)

logger = logging.getLogger(__name__)


class DatabaseManager:
    """Manages connections and operations across all storage layers."""

    def __init__(self, config: VectorStoreConfig):
        """Initialize database manager.
        
        Args:
            config: Vector store configuration
        """
        self.config = config
        self._pg_pool = None
        self._redis = None
        self._astra = None
        self._pinecone_index = None
        self.initialized = False

    async def initialize(self) -> None:
        """Initialize all database connections."""
        try:
            # Initialize PostgreSQL
            self._pg_pool = await create_pool(
                host=self.config.postgres.host,
                port=self.config.postgres.port,
                user=self.config.postgres.user,
                password=self.config.postgres.password,
                database=self.config.postgres.database,
                min_size=self.config.postgres.min_size,
                max_size=self.config.postgres.max_size
            )
            
            # Initialize Redis
            if self.config.hot_cache_enabled:
                self._redis = await aioredis.create_redis_pool(
                    f'redis://{self.config.redis.host}:{self.config.redis.port}',
                    db=self.config.redis.db,
                    password=self.config.redis.password,
                    encoding='utf-8'
                )
            
            # Initialize AstraDB
            if self.config.warm_cache_enabled:
                auth_provider = PlainTextAuthProvider(
                    username='token',
                    password=self.config.astradb.application_token
                )
                self._astra = Cluster(
                    cloud={
                        'secure_connect_bundle': 'path/to/bundle'  # TODO: Add to config
                    },
                    auth_provider=auth_provider
                )
            
            # Initialize Pinecone
            pinecone.init(
                api_key=self.config.pinecone.api_key,
                environment=self.config.pinecone.environment
            )
            self._pinecone_index = pinecone.Index(self.config.pinecone.index_name)
            
            self.initialized = True
            logger.info("Database manager initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize database manager: {str(e)}")
            raise

    async def close(self) -> None:
        """Close all database connections."""
        if self._pg_pool:
            await self._pg_pool.close()
        
        if self._redis:
            self._redis.close()
            await self._redis.wait_closed()
            
        if self._astra:
            self._astra.shutdown()
            
        self.initialized = False
        logger.info("Database connections closed")

    async def store_vector(
        self,
        vector_id: str,
        vector: List[float],
        metadata: Dict[str, Any],
        namespace: Optional[str] = None
    ) -> bool:
        """Store vector across all layers.
        
        Args:
            vector_id: Unique vector identifier
            vector: Vector data
            metadata: Vector metadata
            namespace: Optional namespace
            
        Returns:
            bool: Success status
        """
        try:
            # Store in PostgreSQL
            await self._store_metadata(vector_id, metadata)
            
            # Store in Redis (hot cache)
            if self.config.hot_cache_enabled:
                await self._store_hot_cache(vector_id, vector, metadata)
            
            # Store in AstraDB (warm cache)
            if self.config.warm_cache_enabled:
                await self._store_warm_cache(vector_id, vector, metadata)
            
            # Store in Pinecone (cold storage)
            await self._store_cold_storage(vector_id, vector, metadata, namespace)
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to store vector {vector_id}: {str(e)}")
            raise

    async def _store_metadata(self, vector_id: str, metadata: Dict[str, Any]) -> None:
        """Store vector metadata in PostgreSQL."""
        try:
            async with self._pg_pool.acquire() as conn:
                await conn.execute(
                    """
                    INSERT INTO vector_metadata (
                        vector_id, metadata, created_at, updated_at
                    ) VALUES ($1, $2, $3, $3)
                    ON CONFLICT (vector_id) 
                    DO UPDATE SET metadata = $2, updated_at = $3
                    """,
                    vector_id,
                    metadata,
                    datetime.utcnow()
                )
        except Exception as e:
            raise MetadataError("Failed to store metadata", "insert", {"error": str(e)})

    async def _store_hot_cache(
        self,
        vector_id: str,
        vector: List[float],
        metadata: Dict[str, Any]
    ) -> None:
        """Store vector in Redis hot cache."""
        try:
            key = f"vector:{vector_id}"
            data = {
                "vector": vector,
                "metadata": metadata,
                "cached_at": datetime.utcnow().isoformat()
            }
            await self._redis.set(
                key,
                str(data),
                expire=self.config.redis.ttl
            )
        except Exception as e:
            raise HotCacheError("Failed to store in hot cache", "set", {"error": str(e)})

    async def _store_warm_cache(
        self,
        vector_id: str,
        vector: List[float],
        metadata: Dict[str, Any]
    ) -> None:
        """Store vector in AstraDB warm cache."""
        try:
            session = self._astra.connect()
            session.execute(
                f"""
                INSERT INTO {self.config.astradb.keyspace}.{self.config.astradb.collection_name}
                (vector_id, vector_data, metadata, cached_at)
                VALUES (%s, %s, %s, %s)
                """,
                (vector_id, vector, metadata, datetime.utcnow())
            )
        except Exception as e:
            raise WarmCacheError(
                "Failed to store in warm cache",
                "insert",
                {"error": str(e)}
            )

    async def _store_cold_storage(
        self,
        vector_id: str,
        vector: List[float],
        metadata: Dict[str, Any],
        namespace: Optional[str] = None
    ) -> None:
        """Store vector in Pinecone cold storage."""
        try:
            self._pinecone_index.upsert(
                vectors=[(vector_id, vector, metadata)],
                namespace=namespace
            )
        except Exception as e:
            raise ColdStorageError(
                "Failed to store in cold storage",
                "upsert",
                {"error": str(e)}
            )

    async def __aenter__(self):
        """Async context manager entry."""
        await self.initialize()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        await self.close()