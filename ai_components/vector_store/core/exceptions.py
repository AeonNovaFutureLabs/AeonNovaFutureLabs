"""Exceptions for ANFL Vector Store."""

from typing import Any, Dict, Optional

from ...core.exceptions import ANFLException


class VectorStoreError(ANFLException):
    """Base exception for vector store errors."""
    pass


class StorageLayerError(VectorStoreError):
    """Base exception for storage layer errors."""
    
    def __init__(
        self,
        message: str,
        layer: str,
        operation: str,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message,
            code=f"{layer.upper()}_STORAGE_ERROR",
            details={
                "layer": layer,
                "operation": operation,
                **(details or {})
            }
        )


class HotCacheError(StorageLayerError):
    """Redis hot cache errors."""
    
    def __init__(
        self,
        message: str,
        operation: str,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(message, "hot_cache", operation, details)


class WarmCacheError(StorageLayerError):
    """AstraDB warm cache errors."""
    
    def __init__(
        self,
        message: str,
        operation: str,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(message, "warm_cache", operation, details)


class ColdStorageError(StorageLayerError):
    """Pinecone cold storage errors."""
    
    def __init__(
        self,
        message: str,
        operation: str,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(message, "cold_storage", operation, details)


class MetadataError(StorageLayerError):
    """PostgreSQL metadata storage errors."""
    
    def __init__(
        self,
        message: str,
        operation: str,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(message, "metadata", operation, details)


class VectorNotFoundError(VectorStoreError):
    """Raised when a vector is not found in any storage layer."""
    
    def __init__(
        self,
        vector_id: str,
        namespace: Optional[str] = None,
        searched_layers: Optional[List[str]] = None
    ):
        super().__init__(
            f"Vector not found: {vector_id}",
            code="VECTOR_NOT_FOUND",
            details={
                "vector_id": vector_id,
                "namespace": namespace,
                "searched_layers": searched_layers or []
            }
        )


class InvalidVectorError(VectorStoreError):
    """Raised when vector data is invalid."""
    
    def __init__(
        self,
        message: str,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message,
            code="INVALID_VECTOR",
            details=details
        )


class StorageLayerUnavailableError(VectorStoreError):
    """Raised when a storage layer is unavailable."""
    
    def __init__(
        self,
        layer: str,
        message: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message or f"Storage layer unavailable: {layer}",
            code=f"{layer.upper()}_UNAVAILABLE",
            details=details
        )


class CacheConsistencyError(VectorStoreError):
    """Raised when inconsistency is detected between cache layers."""
    
    def __init__(
        self,
        message: str,
        layers: List[str],
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message,
            code="CACHE_INCONSISTENCY",
            details={
                "affected_layers": layers,
                **(details or {})
            }
        )


class VectorStorageFullError(VectorStoreError):
    """Raised when storage capacity is exceeded."""
    
    def __init__(
        self,
        layer: str,
        current_size: int,
        max_size: int,
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            f"Storage capacity exceeded in {layer}",
            code="STORAGE_FULL",
            details={
                "layer": layer,
                "current_size": current_size,
                "max_size": max_size,
                **(details or {})
            }
        )