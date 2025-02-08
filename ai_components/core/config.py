"""Configuration management for ANFL."""

from pathlib import Path
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field, validator
from pydantic.networks import HttpUrl
from pydantic_settings import BaseSettings, SettingsConfigDict

# Base directory of the project
BASE_DIR = Path(__file__).parent.parent.parent.resolve()


class DatabaseConfig(BaseModel):
    """Database configuration."""
    postgres: Dict[str, Any]
    redis: Dict[str, Any]
    pinecone: Dict[str, Any]
    monitoring: Dict[str, Any]

    @validator('postgres')
    def validate_postgres(cls, v):
        required = {'host', 'port', 'database', 'user', 'min_size', 'max_size'}
        if not all(k in v for k in required):
            raise ValueError(f"Missing required Postgres config: {required - v.keys()}")
        return v

    @validator('redis')
    def validate_redis(cls, v):
        required = {'host', 'port', 'db'}
        if not all(k in v for k in required):
            raise ValueError(f"Missing required Redis config: {required - v.keys()}")
        return v

    @validator('pinecone')
    def validate_pinecone(cls, v):
        required = {'dimension', 'metric', 'index_name'}
        if not all(k in v for k in required):
            raise ValueError(f"Missing required Pinecone config: {required - v.keys()}")
        return v


class SecurityConfig(BaseSettings):
    """Security configuration."""
    ENCRYPTION_KEY: str = Field(..., env="ANFL_ENCRYPTION_KEY")
    ALLOWED_ORIGINS: List[HttpUrl] = Field(..., env="ANFL_ALLOWED_ORIGINS")
    VAULT_ADDR: str = Field(..., env="ANFL_VAULT_ADDR")
    VAULT_TOKEN: str = Field(..., env="ANFL_VAULT_TOKEN")

    @validator('ALLOWED_ORIGINS', pre=True)
    def split_allowed_origins(cls, v):
        if isinstance(v, str):
            return [HttpUrl(o.strip()) for o in v.split(',') if o.strip()]
        return v

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


class MonitoringConfig(BaseSettings):
    """Monitoring configuration."""
    PROMETHEUS_PORT: int = Field(9090, env="ANFL_PROMETHEUS_PORT")
    GRAFANA_PORT: int = Field(3000, env="ANFL_GRAFANA_PORT")
    METRICS_PATH: str = Field("/metrics", env="ANFL_METRICS_PATH")
    COLLECTION_INTERVAL: str = Field("15s", env="ANFL_COLLECTION_INTERVAL")
    RETENTION_DAYS: int = Field(15, env="ANFL_RETENTION_DAYS")

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


class Settings(BaseSettings):
    """Base settings for the application."""
    
    # Environment
    ENV: str = Field(default="development", env="ANFL_ENV")
    DEBUG: bool = Field(default=False, env="ANFL_DEBUG")
    
    # Paths
    MODEL_PATH: Path = Field(
        default=BASE_DIR / "ai_components" / "models",
        env="ANFL_MODEL_PATH"
    )
    LOG_PATH: Path = Field(
        default=BASE_DIR / "logs",
        env="ANFL_LOG_PATH"
    )
    
    # Logging
    LOG_LEVEL: str = Field(default="INFO", env="ANFL_LOG_LEVEL")
    
    class Config:
        """Pydantic config class."""
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True

    def get_model_path(self, model_name: str) -> Path:
        """Get the path for a specific model."""
        return self.MODEL_PATH / model_name

    def get_log_file(self, name: Optional[str] = None) -> Path:
        """Get the path for a log file."""
        self.LOG_PATH.mkdir(parents=True, exist_ok=True)
        if name:
            return self.LOG_PATH / f"{name}.log"
        return self.LOG_PATH / "anfl.log"

    def get_environment_dict(self) -> Dict[str, Any]:
        """Get all settings as a dictionary."""
        return {
            key: str(value) if isinstance(value, Path) else value
            for key, value in self.dict().items()
        }


# Create global settings instances
settings = Settings()
database_config = DatabaseConfig
security_config = SecurityConfig()
monitoring_config = MonitoringConfig()

# Ensure required directories exist
settings.LOG_PATH.mkdir(parents=True, exist_ok=True)
settings.MODEL_PATH.mkdir(parents=True, exist_ok=True)

# Export settings instances
__all__ = ["settings", "database_config", "security_config", "monitoring_config"]