"""Custom exceptions for ANFL."""

from typing import Any, Dict, Optional


class ANFLException(Exception):
    """Base exception for all ANFL exceptions."""
    
    def __init__(
        self,
        message: str,
        code: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.code = code or self.__class__.__name__
        self.details = details or {}
        super().__init__(self.message)


class ConfigurationError(ANFLException):
    """Raised when there is a configuration error."""
    pass


class ValidationError(ANFLException):
    """Raised when data validation fails."""
    pass


class ModelError(ANFLException):
    """Base exception for model-related errors."""
    pass


class ModelNotFoundError(ModelError):
    """Raised when a requested model is not found."""
    pass


class ModelLoadError(ModelError):
    """Raised when a model fails to load."""
    pass


class OrchestratorError(ANFLException):
    """Base exception for orchestrator-related errors."""
    pass


class TaskExecutionError(OrchestratorError):
    """Raised when task execution fails."""
    pass


class ResourceNotFoundError(ANFLException):
    """Raised when a requested resource is not found."""
    pass


class AuthenticationError(ANFLException):
    """Raised when authentication fails."""
    pass


class AuthorizationError(ANFLException):
    """Raised when authorization fails."""
    pass


class APIError(ANFLException):
    """Base exception for API-related errors."""
    pass


class ExternalServiceError(ANFLException):
    """Raised when an external service call fails."""
    
    def __init__(
        self,
        message: str,
        service_name: str,
        response: Optional[Any] = None,
        **kwargs
    ):
        super().__init__(
            message,
            details={
                "service_name": service_name,
                "response": response,
                **kwargs
            }
        )


class RateLimitError(APIError):
    """Raised when rate limit is exceeded."""
    pass


# Export all exceptions
__all__ = [
    "ANFLException",
    "ConfigurationError",
    "ValidationError",
    "ModelError",
    "ModelNotFoundError",
    "ModelLoadError",
    "OrchestratorError",
    "TaskExecutionError",
    "ResourceNotFoundError",
    "AuthenticationError",
    "AuthorizationError",
    "APIError",
    "ExternalServiceError",
    "RateLimitError",
]