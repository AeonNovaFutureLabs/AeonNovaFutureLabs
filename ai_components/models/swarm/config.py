"""
Configuration for ANFL Swarm Optimization System.

This module defines the configuration settings for various swarm algorithms,
including PSO, Ant Colony, and Sakana implementations.
"""

from typing import Dict, List, Optional, Union
from pydantic import BaseModel, Field


class ParticleConfig(BaseModel):
    """Configuration for individual particles in PSO."""
    
    dimensions: int = Field(
        ...,
        description="Number of dimensions in the search space"
    )
    velocity_bounds: tuple[float, float] = Field(
        (-1.0, 1.0),
        description="Bounds for particle velocity"
    )
    position_bounds: tuple[float, float] = Field(
        (-10.0, 10.0),
        description="Bounds for particle position"
    )
    inertia_weight: float = Field(
        0.729,
        description="Inertia weight for velocity update"
    )
    cognitive_weight: float = Field(
        1.49445,
        description="Weight for particle's personal best"
    )
    social_weight: float = Field(
        1.49445,
        description="Weight for swarm's global best"
    )


class PSOConfig(BaseModel):
    """Configuration for Particle Swarm Optimization."""
    
    num_particles: int = Field(
        100,
        description="Number of particles in the swarm"
    )
    particle_config: ParticleConfig = Field(
        ...,
        description="Configuration for each particle"
    )
    topology: str = Field(
        "global",
        description="Swarm topology type (global, ring, local)"
    )
    neighborhood_size: int = Field(
        5,
        description="Size of local neighborhood if using local topology"
    )
    max_iterations: int = Field(
        1000,
        description="Maximum number of iterations"
    )
    convergence_threshold: float = Field(
        1e-6,
        description="Threshold for convergence"
    )


class AntConfig(BaseModel):
    """Configuration for individual ants in ACO."""
    
    alpha: float = Field(
        1.0,
        description="Pheromone importance factor"
    )
    beta: float = Field(
        2.0,
        description="Heuristic importance factor"
    )
    evaporation_rate: float = Field(
        0.1,
        description="Pheromone evaporation rate"
    )
    initial_pheromone: float = Field(
        0.1,
        description="Initial pheromone value"
    )


class ACOConfig(BaseModel):
    """Configuration for Ant Colony Optimization."""
    
    num_ants: int = Field(
        50,
        description="Number of ants in the colony"
    )
    ant_config: AntConfig = Field(
        default_factory=AntConfig,
        description="Configuration for each ant"
    )
    pheromone_bounds: tuple[float, float] = Field(
        (0.0, 1.0),
        description="Bounds for pheromone values"
    )
    local_search: bool = Field(
        True,
        description="Enable local search optimization"
    )
    max_iterations: int = Field(
        100,
        description="Maximum number of iterations"
    )


class SakanaConfig(BaseModel):
    """Configuration for Sakana swarm algorithm."""
    
    num_agents: int = Field(
        50,
        description="Number of Sakana agents"
    )
    vision_radius: float = Field(
        2.0,
        description="Vision radius for each agent"
    )
    separation_weight: float = Field(
        1.5,
        description="Weight for separation behavior"
    )
    alignment_weight: float = Field(
        1.0,
        description="Weight for alignment behavior"
    )
    cohesion_weight: float = Field(
        1.0,
        description="Weight for cohesion behavior"
    )
    max_speed: float = Field(
        2.0,
        description="Maximum speed of agents"
    )
    max_iterations: int = Field(
        500,
        description="Maximum number of iterations"
    )


class MonitoringConfig(BaseModel):
    """Configuration for swarm monitoring."""
    
    metrics_interval: int = Field(
        10,
        description="Interval for collecting metrics"
    )
    convergence_window: int = Field(
        50,
        description="Window size for convergence check"
    )
    visualization_enabled: bool = Field(
        True,
        description="Enable swarm visualization"
    )
    log_level: str = Field(
        "INFO",
        description="Logging level for swarm operations"
    )


class SwarmConfig(BaseModel):
    """Main configuration for the swarm system."""
    
    algorithm: str = Field(
        "pso",
        description="Selected swarm algorithm (pso, aco, sakana)"
    )
    pso_config: Optional[PSOConfig] = Field(
        None,
        description="PSO configuration if selected"
    )
    aco_config: Optional[ACOConfig] = Field(
        None,
        description="ACO configuration if selected"
    )
    sakana_config: Optional[SakanaConfig] = Field(
        None,
        description="Sakana configuration if selected"
    )
    monitoring: MonitoringConfig = Field(
        default_factory=MonitoringConfig,
        description="Monitoring configuration"
    )
    
    # System-wide settings
    random_seed: Optional[int] = Field(
        None,
        description="Random seed for reproducibility"
    )
    parallel_execution: bool = Field(
        True,
        description="Enable parallel execution"
    )
    num_threads: int = Field(
        4,
        description="Number of threads for parallel execution"
    )
    
    # Integration settings
    moe_integration: bool = Field(
        True,
        description="Enable integration with MoE system"
    )
    expert_feedback: bool = Field(
        True,
        description="Enable expert feedback for optimization"
    )
    
    class Config:
        """Pydantic config class."""
        validate_assignment = True
        extra = "forbid"


def load_swarm_config(
    algorithm: str = "pso",
    config_path: Optional[str] = None
) -> SwarmConfig:
    """Load swarm configuration based on selected algorithm."""
    if config_path:
        # Load from file
        pass
    
    # Default configurations based on algorithm
    configs = {
        "pso": SwarmConfig(
            algorithm="pso",
            pso_config=PSOConfig(
                particle_config=ParticleConfig(dimensions=10)
            )
        ),
        "aco": SwarmConfig(
            algorithm="aco",
            aco_config=ACOConfig()
        ),
        "sakana": SwarmConfig(
            algorithm="sakana",
            sakana_config=SakanaConfig()
        )
    }
    
    return configs.get(algorithm, configs["pso"])