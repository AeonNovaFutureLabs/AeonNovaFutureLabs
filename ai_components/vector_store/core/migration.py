"""Migration manager for ANFL Vector Store."""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Set, Tuple

from .config import VectorStoreConfig
from .db_manager import DatabaseManager
from .exceptions import (
    StorageLayerUnavailableError,
    CacheConsistencyError,
    VectorNotFoundError
)

logger = logging.getLogger(__name__)


class MigrationManager:
    """Manages vector migrations between storage layers."""

    def __init__(
        self,
        config: VectorStoreConfig,
        db_manager: DatabaseManager
    ):
        """Initialize migration manager.
        
        Args:
            config: Vector store configuration
            db_manager: Database manager instance
        """
        self.config = config
        self.db_manager = db_manager
        self._migration_lock = asyncio.Lock()

    async def check_migrations(self) -> None:
        """Check and perform necessary migrations."""
        async with self._migration_lock:
            await self._migrate_expired_vectors()
            await self._optimize_cache_distribution()

    async def _migrate_expired_vectors(self) -> None:
        """Migrate vectors that have expired from their current cache layer."""
        try:
            # Check hot cache (Redis) expirations
            hot_expired = await self._get_expired_vectors("hot")
            if hot_expired:
                await self._migrate_to_warm_cache(hot_expired)

            # Check warm cache (AstraDB) expirations
            warm_expired = await self._get_expired_vectors("warm")
            if warm_expired:
                await self._migrate_to_cold_storage(warm_expired)

        except Exception as e:
            logger.error(f"Error during expired vectors migration: {str(e)}")
            raise

    async def _optimize_cache_distribution(self) -> None:
        """Optimize vector distribution across cache layers based on access patterns."""
        try:
            # Get access patterns from PostgreSQL
            access_patterns = await self._get_access_patterns()

            # Identify frequently accessed vectors in cold storage
            cold_frequent = await self._get_frequent_cold_vectors(access_patterns)
            if cold_frequent:
                await self._promote_to_warm_cache(cold_frequent)

            # Identify very frequently accessed vectors in warm cache
            warm_frequent = await self._get_frequent_warm_vectors(access_patterns)
            if warm_frequent:
                await self._promote_to_hot_cache(warm_frequent)

        except Exception as e:
            logger.error(f"Error during cache optimization: {str(e)}")
            raise

    async def _get_expired_vectors(self, cache_layer: str) -> List[str]:
        """Get list of expired vector IDs from a cache layer."""
        async with self.db_manager._pg_pool.acquire() as conn:
            results = await conn.fetch(
                """
                SELECT vector_id
                FROM cache_tracking
                WHERE cache_layer = $1
                AND expires_at < NOW()
                """,
                cache_layer
            )
            return [r['vector_id'] for r in results]

    async def _get_access_patterns(self) -> Dict[str, Dict[str, int]]:
        """Get vector access patterns from the last monitoring period."""
        async with self.db_manager._pg_pool.acquire() as conn:
            results = await conn.fetch(
                """
                SELECT vector_id, cache_layer, access_count
                FROM cache_tracking
                WHERE last_accessed > NOW() - INTERVAL '24 hours'
                """
            )
            
            patterns = {}
            for r in results:
                if r['vector_id'] not in patterns:
                    patterns[r['vector_id']] = {}
                patterns[r['vector_id']][r['cache_layer']] = r['access_count']
            
            return patterns

    async def _migrate_to_warm_cache(self, vector_ids: List[str]) -> None:
        """Migrate vectors from hot cache to warm cache."""
        for vector_id in vector_ids:
            try:
                # Get vector data from hot cache
                vector_data = await self._get_from_hot_cache(vector_id)
                if not vector_data:
                    continue

                # Store in warm cache
                await self.db_manager._store_warm_cache(
                    vector_id,
                    vector_data['vector'],
                    vector_data['metadata']
                )

                # Update tracking
                await self._update_migration_tracking(
                    vector_id,
                    'hot',
                    'warm',
                    'ttl_expired'
                )

                # Remove from hot cache
                await self._remove_from_hot_cache(vector_id)

            except Exception as e:
                logger.error(f"Error migrating vector {vector_id} to warm cache: {str(e)}")
                await self._record_failed_migration(
                    vector_id,
                    'hot',
                    'warm',
                    str(e)
                )

    async def _migrate_to_cold_storage(self, vector_ids: List[str]) -> None:
        """Migrate vectors from warm cache to cold storage."""
        for vector_id in vector_ids:
            try:
                # Get vector data from warm cache
                vector_data = await self._get_from_warm_cache(vector_id)
                if not vector_data:
                    continue

                # Store in cold storage
                await self.db_manager._store_cold_storage(
                    vector_id,
                    vector_data['vector'],
                    vector_data['metadata']
                )

                # Update tracking
                await self._update_migration_tracking(
                    vector_id,
                    'warm',
                    'cold',
                    'ttl_expired'
                )

                # Remove from warm cache
                await self._remove_from_warm_cache(vector_id)

            except Exception as e:
                logger.error(f"Error migrating vector {vector_id} to cold storage: {str(e)}")
                await self._record_failed_migration(
                    vector_id,
                    'warm',
                    'cold',
                    str(e)
                )

    async def _update_migration_tracking(
        self,
        vector_id: str,
        source_layer: str,
        target_layer: str,
        reason: str
    ) -> None:
        """Update migration tracking in PostgreSQL."""
        async with self.db_manager._pg_pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO vector_migrations (
                    vector_id, source_layer, target_layer,
                    reason, status, metadata
                ) VALUES ($1, $2, $3, $4, 'success', $5)
                """,
                vector_id,
                source_layer,
                target_layer,
                reason,
                {'migration_time': datetime.utcnow().isoformat()}
            )

    async def _record_failed_migration(
        self,
        vector_id: str,
        source_layer: str,
        target_layer: str,
        error: str
    ) -> None:
        """Record failed migration attempt."""
        async with self.db_manager._pg_pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO vector_migrations (
                    vector_id, source_layer, target_layer,
                    reason, status, error_message
                ) VALUES ($1, $2, $3, 'ttl_expired', 'failure', $4)
                """,
                vector_id,
                source_layer,
                target_layer,
                error
            )

    async def verify_cache_consistency(self) -> None:
        """Verify consistency across cache layers."""
        try:
            # Get vector IDs from each layer
            hot_vectors = await self._get_hot_cache_vectors()
            warm_vectors = await self._get_warm_cache_vectors()
            cold_vectors = await self._get_cold_storage_vectors()

            # Check for vectors that should be expired
            inconsistencies = await self._find_cache_inconsistencies(
                hot_vectors,
                warm_vectors,
                cold_vectors
            )

            if inconsistencies:
                logger.warning(f"Found {len(inconsistencies)} cache inconsistencies")
                await self._resolve_inconsistencies(inconsistencies)

        except Exception as e:
            logger.error(f"Error during cache consistency check: {str(e)}")
            raise

    async def _find_cache_inconsistencies(
        self,
        hot_vectors: Set[str],
        warm_vectors: Set[str],
        cold_vectors: Set[str]
    ) -> List[Dict]:
        """Find inconsistencies between cache layers."""
        inconsistencies = []

        async with self.db_manager._pg_pool.acquire() as conn:
            # Check each vector's expected location
            results = await conn.fetch(
                """
                SELECT vector_id, cache_layer
                FROM cache_tracking
                WHERE vector_id = ANY($1)
                """,
                list(hot_vectors | warm_vectors | cold_vectors)
            )

            for r in results:
                vector_id = r['vector_id']
                expected_layer = r['cache_layer']

                # Check if vector is in unexpected layers
                if expected_layer == 'hot' and vector_id not in hot_vectors:
                    inconsistencies.append({
                        'vector_id': vector_id,
                        'type': 'missing',
                        'expected_layer': 'hot'
                    })
                elif expected_layer == 'warm' and vector_id not in warm_vectors:
                    inconsistencies.append({
                        'vector_id': vector_id,
                        'type': 'missing',
                        'expected_layer': 'warm'
                    })
                elif expected_layer == 'cold' and vector_id not in cold_vectors:
                    inconsistencies.append({
                        'vector_id': vector_id,
                        'type': 'missing',
                        'expected_layer': 'cold'
                    })

        return inconsistencies

    async def _resolve_inconsistencies(self, inconsistencies: List[Dict]) -> None:
        """Resolve found cache inconsistencies."""
        for inconsistency in inconsistencies:
            vector_id = inconsistency['vector_id']
            expected_layer = inconsistency['expected_layer']

            try:
                # Get vector data from metadata
                metadata = await self.db_manager._get_metadata(vector_id)
                if not metadata:
                    continue

                # Restore vector to expected layer
                if expected_layer == 'hot':
                    await self.db_manager._store_hot_cache(
                        vector_id,
                        metadata['vector'],
                        metadata['metadata']
                    )
                elif expected_layer == 'warm':
                    await self.db_manager._store_warm_cache(
                        vector_id,
                        metadata['vector'],
                        metadata['metadata']
                    )
                elif expected_layer == 'cold':
                    await self.db_manager._store_cold_storage(
                        vector_id,
                        metadata['vector'],
                        metadata['metadata']
                    )

                logger.info(f"Resolved inconsistency for vector {vector_id}")

            except Exception as e:
                logger.error(
                    f"Failed to resolve inconsistency for vector {vector_id}: {str(e)}"
                )