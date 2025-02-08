"""Logging configuration for ANFL."""

import sys
from pathlib import Path
from typing import Optional

from loguru import logger

from .config import settings

# Remove default logger
logger.remove()

# Add console logger with appropriate level
logger.add(
    sys.stderr,
    level=settings.LOG_LEVEL,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>"
)

# Add file logger
logger.add(
    settings.get_log_file(),
    rotation="500 MB",
    retention="10 days",
    compression="zip",
    level=settings.LOG_LEVEL,
    format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}"
)


def get_logger(name: Optional[str] = None):
    """Get a logger instance with optional name."""
    if name:
        return logger.bind(name=name)
    return logger


def setup_module_logger(module_name: str, log_file: Optional[Path] = None):
    """Set up a logger for a specific module with optional separate log file."""
    module_logger = logger.bind(name=module_name)
    
    if log_file:
        logger.add(
            log_file,
            rotation="100 MB",
            retention="7 days",
            compression="zip",
            level=settings.LOG_LEVEL,
            format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
            filter=lambda record: record["extra"].get("name") == module_name
        )
    
    return module_logger


# Export the logger and utility functions
__all__ = ["logger", "get_logger", "setup_module_logger"]