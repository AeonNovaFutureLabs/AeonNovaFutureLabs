"""Base interfaces for ANFL Vector Store."""

from abc import ABC, abstractmethod
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple

from pydantic import BaseModel


class VectorMetadata(BaseModel):
    """Metadata for stored vectors."""
    vector_id: str
    created_at: datetime
    updated_at: datetime
    embedding_model: str
    dimension: int
    namespace: Optional[str] = None
    custom_metadata: Dict[str, Any] = {}


class QueryResult(BaseModel):
    """Result from vector similarity search."""
    vector_id: str
    score: float
    metadata: Optional[VectorMetadata] = None
    vector: Optional[List[float]] = None


class VectorStorageBase(ABC):
    """Base interface for vector storage implementations."""

    @abstractmethod
    async def initialize(self) -> None:
        """Initialize the storage layer."""
        pass

    @abstractmethod
    async def store_vectors(
        self,
        vectors: List[Tuple[str, List[float]]],
        metadata: Optional[List[VectorMetadata]] = None,
        namespace: Optional[str] = None
    ) -> bool:
        """Store vectors with metadata.
        
        Args:
            vectors: List of (id, vector) tuples
            metadata: Optional list of metadata for each vector
            namespace: Optional namespace for vectors
            
        Returns:
            bool: Success status
        """
        pass

    @abstractmethod
    async def query_similar(
        self,
        query_vector: List[float],
        top_k: int = 5,
        namespace: Optional[str] = None,
        include_vectors: bool = False,
        include_metadata: bool = True,
        filter_criteria: Optional[Dict[str, Any]] = None
    ) -> List[QueryResult]:
        """Query similar vectors.
        
        Args:
            query_vector: Vector to find similarities for
            top_k: Number of results to return
            namespace: Optional namespace to search in
            include_vectors: Whether to include vector values in results
            include_metadata: Whether to include metadata in results
            filter_criteria: Optional filtering criteria
            
        Returns:
            List of query results
        """
        pass

    @abstractmethod
    async def delete_vectors(
        self,
        vector_ids: List[str],
        namespace: Optional[str] = None
    ) -> bool:
        """Delete vectors by ID.
        
        Args:
            vector_ids: List of vector IDs to delete
            namespace: Optional namespace
            
        Returns:
            bool: Success status
        """
        pass

    @abstractmethod
    async def update_metadata(
        self,
        vector_id: str,
        metadata: VectorMetadata,
        namespace: Optional[str] = None
    ) -> bool:
        """Update vector metadata.
        
        Args:
            vector_id: Vector ID
            metadata: New metadata
            namespace: Optional namespace
            
        Returns:
            bool: Success status
        """
        pass

    @abstractmethod
    async def get_metadata(
        self,
        vector_id: str,
        namespace: Optional[str] = None
    ) -> Optional[VectorMetadata]:
        """Get vector metadata.
        
        Args:
            vector_id: Vector ID
            namespace: Optional namespace
            
        Returns:
            Optional metadata
        """
        pass


class VectorCacheBase(VectorStorageBase):
    """Base interface for vector cache implementations."""

    @abstractmethod
    async def set_ttl(
        self,
        vector_ids: List[str],
        ttl_seconds: int,
        namespace: Optional[str] = None
    ) -> bool:
        """Set time-to-live for cached vectors.
        
        Args:
            vector_ids: List of vector IDs
            ttl_seconds: TTL in seconds
            namespace: Optional namespace
            
        Returns:
            bool: Success status
        """
        pass

    @abstractmethod
    async def extend_ttl(
        self,
        vector_ids: List[str],
        extend_seconds: int,
        namespace: Optional[str] = None
    ) -> bool:
        """Extend TTL for cached vectors.
        
        Args:
            vector_ids: List of vector IDs
            extend_seconds: Seconds to extend TTL by
            namespace: Optional namespace
            
        Returns:
            bool: Success status
        """
        pass

    @abstractmethod
    async def get_ttl(
        self,
        vector_id: str,
        namespace: Optional[str] = None
    ) -> Optional[int]:
        """Get remaining TTL for cached vector.
        
        Args:
            vector_id: Vector ID
            namespace: Optional namespace
            
        Returns:
            Remaining TTL in seconds, if any
        """
        pass