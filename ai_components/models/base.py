"""Base model class for ANFL."""

import abc
from pathlib import Path
from typing import Any, Dict, Optional, Union

from ..core.config import settings
from ..core.exceptions import ModelLoadError, ModelNotFoundError
from ..core.logging import get_logger

logger = get_logger(__name__)


class BaseModel(abc.ABC):
    """Abstract base class for all ANFL models."""

    def __init__(
        self,
        model_name: str,
        model_path: Optional[Union[str, Path]] = None,
        config: Optional[Dict[str, Any]] = None
    ):
        """Initialize the model.
        
        Args:
            model_name: Name of the model
            model_path: Optional path to model files. If not provided, uses default path
            config: Optional configuration dictionary
        """
        self.model_name = model_name
        self.model_path = Path(model_path) if model_path else settings.get_model_path(model_name)
        self.config = config or {}
        self._is_loaded = False
        self._model: Any = None
        
        logger.info(f"Initializing model: {model_name}")
        logger.debug(f"Model path: {self.model_path}")
        logger.debug(f"Model config: {self.config}")

    @property
    def is_loaded(self) -> bool:
        """Check if the model is loaded."""
        return self._is_loaded

    @abc.abstractmethod
    async def load(self) -> None:
        """Load the model into memory.
        
        This method should be implemented by subclasses to handle model loading.
        """
        if not self.model_path.exists():
            raise ModelNotFoundError(
                f"Model path does not exist: {self.model_path}",
                details={"model_name": self.model_name}
            )

    @abc.abstractmethod
    async def unload(self) -> None:
        """Unload the model from memory.
        
        This method should be implemented by subclasses to handle model cleanup.
        """
        self._is_loaded = False
        self._model = None

    @abc.abstractmethod
    async def predict(self, input_data: Any) -> Any:
        """Make predictions using the model.
        
        Args:
            input_data: Input data for prediction
            
        Returns:
            Model predictions
        """
        if not self.is_loaded:
            raise ModelLoadError(
                "Model is not loaded",
                details={"model_name": self.model_name}
            )

    async def __aenter__(self):
        """Async context manager entry."""
        await self.load()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        await self.unload()

    def __repr__(self) -> str:
        """String representation of the model."""
        return f"{self.__class__.__name__}(model_name='{self.model_name}', loaded={self.is_loaded})"


class ModelRegistry:
    """Registry for managing model instances."""

    def __init__(self):
        """Initialize the model registry."""
        self._models: Dict[str, BaseModel] = {}
        logger.info("Initializing model registry")

    async def register(self, model: BaseModel) -> None:
        """Register a model instance.
        
        Args:
            model: Model instance to register
        """
        self._models[model.model_name] = model
        logger.info(f"Registered model: {model.model_name}")

    async def unregister(self, model_name: str) -> None:
        """Unregister a model instance.
        
        Args:
            model_name: Name of the model to unregister
        """
        if model_name in self._models:
            model = self._models[model_name]
            if model.is_loaded:
                await model.unload()
            del self._models[model_name]
            logger.info(f"Unregistered model: {model_name}")

    async def get_model(self, model_name: str) -> BaseModel:
        """Get a registered model instance.
        
        Args:
            model_name: Name of the model to retrieve
            
        Returns:
            Registered model instance
            
        Raises:
            ModelNotFoundError: If model is not registered
        """
        if model_name not in self._models:
            raise ModelNotFoundError(
                f"Model not found: {model_name}",
                details={"available_models": list(self._models.keys())}
            )
        return self._models[model_name]

    def list_models(self) -> Dict[str, bool]:
        """List all registered models and their loaded status.
        
        Returns:
            Dictionary mapping model names to their loaded status
        """
        return {name: model.is_loaded for name, model in self._models.items()}


# Create global model registry instance
model_registry = ModelRegistry()

# Export classes and registry
__all__ = ["BaseModel", "ModelRegistry", "model_registry"]