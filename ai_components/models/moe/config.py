"""
Configuration for ANFL Mixture of Experts (MoE) system.

This module defines the configuration settings for the MoE architecture,
including expert routing, load balancing, and monitoring parameters.
"""

from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class ExpertConfig(BaseModel):
    """Configuration for individual experts in the MoE system."""
    
    name: str = Field(..., description="Unique identifier for the expert")
    model_type: str = Field(..., description="Type of model this expert uses")
    specialization: List[str] = Field(
        ...,
        description="List of tasks this expert specializes in"
    )
    capacity: int = Field(
        1000,
        description="Maximum number of concurrent requests this expert can handle"
    )
    warm_up_samples: int = Field(
        100,
        description="Number of samples to warm up the expert"
    )
    batch_size: int = Field(
        32,
        description="Optimal batch size for this expert"
    )
    timeout_ms: int = Field(
        5000,
        description="Maximum time in milliseconds for expert processing"
    )


class RouterConfig(BaseModel):
    """Configuration for the MoE router."""
    
    routing_strategy: str = Field(
        "weighted_random",
        description="Strategy for routing requests to experts"
    )
    load_balancing: bool = Field(
        True,
        description="Enable load balancing across experts"
    )
    max_retries: int = Field(
        3,
        description="Maximum number of routing retries"
    )
    fallback_expert: Optional[str] = Field(
        None,
        description="Expert to use when others fail"
    )
    routing_cache_size: int = Field(
        10000,
        description="Size of the routing cache"
    )


class MonitoringConfig(BaseModel):
    """Configuration for MoE monitoring."""
    
    metrics_interval_ms: int = Field(
        1000,
        description="Interval for collecting metrics"
    )
    expert_health_check_ms: int = Field(
        5000,
        description="Interval for expert health checks"
    )
    performance_window_size: int = Field(
        1000,
        description="Window size for performance metrics"
    )
    alert_thresholds: Dict[str, float] = Field(
        default_factory=lambda: {
            "error_rate": 0.01,
            "latency_ms": 1000,
            "load_imbalance": 0.2
        },
        description="Thresholds for monitoring alerts"
    )


class MoEConfig(BaseModel):
    """Main configuration for the MoE system."""
    
    experts: Dict[str, ExpertConfig] = Field(
        ...,
        description="Configuration for each expert"
    )
    router: RouterConfig = Field(
        default_factory=RouterConfig,
        description="Router configuration"
    )
    monitoring: MonitoringConfig = Field(
        default_factory=MonitoringConfig,
        description="Monitoring configuration"
    )
    
    # System-wide settings
    num_experts: int = Field(
        8,
        description="Total number of experts in the system"
    )
    input_dim: int = Field(
        768,
        description="Input dimension for the MoE system"
    )
    hidden_dim: int = Field(
        3072,
        description="Hidden dimension for expert processing"
    )
    dropout: float = Field(
        0.1,
        description="Dropout rate for expert networks"
    )
    
    # Training settings
    training_strategy: str = Field(
        "distributed",
        description="Training strategy for the MoE system"
    )
    expert_update_frequency: int = Field(
        1000,
        description="Steps between expert updates"
    )
    load_balance_coefficient: float = Field(
        0.01,
        description="Coefficient for load balancing loss"
    )
    
    # Resource management
    max_memory_gb: float = Field(
        32.0,
        description="Maximum memory usage in GB"
    )
    gpu_allocation_strategy: str = Field(
        "dynamic",
        description="Strategy for GPU allocation"
    )
    
    class Config:
        """Pydantic config class."""
        validate_assignment = True
        extra = "forbid"


def load_moe_config(config_path: Optional[str] = None) -> MoEConfig:
    """Load MoE configuration from file or environment."""
    if config_path:
        # Load from file
        pass
    
    # Default configuration
    return MoEConfig(
        experts={
            "general": ExpertConfig(
                name="general",
                model_type="transformer",
                specialization=["general_purpose"],
                capacity=1000
            ),
            "math": ExpertConfig(
                name="math",
                model_type="transformer",
                specialization=["mathematics", "logic"],
                capacity=500
            ),
            "nlp": ExpertConfig(
                name="nlp",
                model_type="transformer",
                specialization=["text_processing", "language_understanding"],
                capacity=800
            ),
            "vision": ExpertConfig(
                name="vision",
                model_type="cnn",
                specialization=["image_processing", "visual_understanding"],
                capacity=400
            )
        }
    )