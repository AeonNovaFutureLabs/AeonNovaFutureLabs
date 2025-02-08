"""
Base integration interface for ANFL AI components.

This module defines the core interfaces for integrating different AI components,
particularly the Mixture of Experts (MoE) and Swarm Optimization systems.
"""

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Tuple, Union
from pydantic import BaseModel

from .moe.config import MoEConfig
from .swarm.config import SwarmConfig


class OptimizationMetrics(BaseModel):
    """Metrics for optimization performance."""
    
    iteration: int
    fitness_value: float
    convergence_rate: float
    diversity_metric: float
    execution_time_ms: float
    resource_usage: Dict[str, float]


class ExpertMetrics(BaseModel):
    """Metrics for expert performance."""
    
    expert_id: str
    load: float
    success_rate: float
    response_time_ms: float
    specialization_score: float
    resource_usage: Dict[str, float]


class IntegrationMetrics(BaseModel):
    """Combined metrics for the integrated system."""
    
    timestamp: float
    optimization_metrics: OptimizationMetrics
    expert_metrics: List[ExpertMetrics]
    overall_performance: float
    system_health: Dict[str, Any]


class AIComponent(ABC):
    """Base interface for AI components."""
    
    @abstractmethod
    async def initialize(self) -> bool:
        """Initialize the component."""
        pass
    
    @abstractmethod
    async def shutdown(self) -> bool:
        """Shutdown the component."""
        pass
    
    @abstractmethod
    async def health_check(self) -> Dict[str, Any]:
        """Check component health."""
        pass


class SwarmOptimizer(AIComponent):
    """Base interface for swarm optimization components."""
    
    @abstractmethod
    async def optimize(
        self,
        objective_function: callable,
        constraints: Dict[str, Any],
        initial_state: Optional[Dict[str, Any]] = None
    ) -> Tuple[Dict[str, Any], OptimizationMetrics]:
        """Run optimization process."""
        pass
    
    @abstractmethod
    async def update_parameters(
        self,
        parameters: Dict[str, Any]
    ) -> bool:
        """Update optimization parameters."""
        pass


class ExpertSystem(AIComponent):
    """Base interface for expert system components."""
    
    @abstractmethod
    async def process(
        self,
        input_data: Any,
        context: Optional[Dict[str, Any]] = None
    ) -> Tuple[Any, ExpertMetrics]:
        """Process input through expert system."""
        pass
    
    @abstractmethod
    async def update_experts(
        self,
        expert_updates: Dict[str, Any]
    ) -> bool:
        """Update expert configurations."""
        pass


class IntegrationManager:
    """Manager for MoE and Swarm system integration."""
    
    def __init__(
        self,
        moe_config: MoEConfig,
        swarm_config: SwarmConfig
    ):
        """Initialize integration manager."""
        self.moe_config = moe_config
        self.swarm_config = swarm_config
        self.metrics_history: List[IntegrationMetrics] = []
    
    async def initialize_systems(self) -> bool:
        """Initialize both MoE and Swarm systems."""
        try:
            # Initialize components
            moe_success = await self.initialize_moe()
            swarm_success = await self.initialize_swarm()
            
            # Verify integration
            if moe_success and swarm_success:
                await self.verify_integration()
                return True
            return False
            
        except Exception as e:
            logger.error(f"Integration initialization failed: {str(e)}")
            return False
    
    async def optimize_experts(
        self,
        optimization_criteria: Dict[str, Any]
    ) -> Tuple[Dict[str, Any], IntegrationMetrics]:
        """Use swarm optimization to improve expert performance."""
        try:
            # Define objective function for swarm optimization
            def objective_function(params: Dict[str, Any]) -> float:
                return self._evaluate_expert_performance(params)
            
            # Run optimization
            optimal_params, opt_metrics = await self.swarm_optimizer.optimize(
                objective_function,
                optimization_criteria
            )
            
            # Update expert system
            await self.expert_system.update_experts(optimal_params)
            
            # Collect and return metrics
            metrics = await self._collect_integration_metrics(opt_metrics)
            self.metrics_history.append(metrics)
            
            return optimal_params, metrics
            
        except Exception as e:
            logger.error(f"Expert optimization failed: {str(e)}")
            raise
    
    async def process_with_optimization(
        self,
        input_data: Any,
        context: Optional[Dict[str, Any]] = None
    ) -> Tuple[Any, IntegrationMetrics]:
        """Process input using optimized expert system."""
        try:
            # Process through expert system
            output, expert_metrics = await self.expert_system.process(
                input_data,
                context
            )
            
            # Collect integration metrics
            metrics = await self._collect_integration_metrics(None, expert_metrics)
            self.metrics_history.append(metrics)
            
            # Trigger optimization if needed
            if self._should_optimize(metrics):
                await self.optimize_experts({
                    "target_metric": "performance",
                    "min_improvement": 0.1
                })
            
            return output, metrics
            
        except Exception as e:
            logger.error(f"Optimized processing failed: {str(e)}")
            raise
    
    def _should_optimize(self, metrics: IntegrationMetrics) -> bool:
        """Determine if optimization should be triggered."""
        if len(self.metrics_history) < 2:
            return False
            
        # Check performance degradation
        current_perf = metrics.overall_performance
        avg_perf = sum(m.overall_performance for m in self.metrics_history[-10:]) / 10
        
        return current_perf < avg_perf * 0.9  # 10% degradation threshold
    
    async def _collect_integration_metrics(
        self,
        opt_metrics: Optional[OptimizationMetrics] = None,
        expert_metrics: Optional[List[ExpertMetrics]] = None
    ) -> IntegrationMetrics:
        """Collect and combine metrics from both systems."""
        return IntegrationMetrics(
            timestamp=time.time(),
            optimization_metrics=opt_metrics or OptimizationMetrics(
                iteration=0,
                fitness_value=0.0,
                convergence_rate=0.0,
                diversity_metric=0.0,
                execution_time_ms=0.0,
                resource_usage={}
            ),
            expert_metrics=expert_metrics or [],
            overall_performance=self._calculate_overall_performance(),
            system_health=await self._check_system_health()
        )
    
    async def _check_system_health(self) -> Dict[str, Any]:
        """Check health of both systems."""
        moe_health = await self.expert_system.health_check()
        swarm_health = await self.swarm_optimizer.health_check()
        
        return {
            "moe": moe_health,
            "swarm": swarm_health,
            "integration": {
                "metrics_history_size": len(self.metrics_history),
                "last_optimization": self.metrics_history[-1].timestamp if self.metrics_history else None
            }
        }