"""Core testing and validation framework for ML systems."""

import numpy as np
import tensorflow as tf
from typing import Dict, List, Optional, Tuple

class MLSystemValidator:
    """Validator for ML system implementations."""
    
    def __init__(self):
        self.random_seed = 42
        np.random.seed(self.random_seed)
        tf.random.set_seed(self.random_seed)

    def validate_init_loss(self, model, inputs, expected_loss: float, tolerance: float = 1e-2) -> bool:
        """Validate initial loss matches expected value."""
        init_loss = model.compute_loss(inputs)
        return abs(init_loss - expected_loss) < tolerance

    def overfit_batch_test(self, model, batch_size: int = 2, epochs: int = 100, 
                          target_loss: float = 1e-3) -> Dict:
        """Validate model can overfit tiny batch."""
        # Generate toy dataset
        X = np.random.randn(batch_size, model.input_dim) 
        y = np.random.randint(0, model.num_classes, batch_size)
        
        # Train
        losses = []
        for _ in range(epochs):
            loss = model.train_step(X, y)
            losses.append(loss)
            
        final_loss = losses[-1]
        succeeded = final_loss < target_loss
        
        return {
            "succeeded": succeeded,
            "losses": losses,
            "final_loss": final_loss
        }

    def validate_gradient_isolation(self, model, batch_size: int = 4) -> bool:
        """Validate gradients only affect relevant examples."""
        # Generate batch
        X = np.random.randn(batch_size, model.input_dim)
        
        # Compute gradients for one example
        target_idx = 0
        with tf.GradientTape() as tape:
            outputs = model(X)
            loss = outputs[target_idx].sum()
        
        grads = tape.gradient(loss, model.trainable_variables)
        
        # Validate gradients are zero for non-target examples
        other_example_grads = []
        for i in range(batch_size):
            if i != target_idx:
                example_grads = tf.gather(grads[0], i)
                other_example_grads.append(tf.reduce_sum(tf.abs(example_grads)))
                
        return all(g < 1e-6 for g in other_example_grads)

    def validate_training_improves(self, model, num_epochs: int = 10) -> Dict:
        """Validate training loss decreases with increased capacity."""
        # Train baseline
        base_losses = self._train_model(model, num_epochs)
        base_final = base_losses[-1]
        
        # Increase model capacity
        model.increase_capacity()
        increased_losses = self._train_model(model, num_epochs) 
        increased_final = increased_losses[-1]
        
        improved = increased_final < base_final
        
        return {
            "improved": improved,
            "base_losses": base_losses,
            "increased_losses": increased_losses
        }

    def validate_batch_norm(self, model) -> bool:
        """Validate batch norm layers configured correctly."""
        for layer in model.layers:
            if isinstance(layer, tf.keras.layers.BatchNormalization):
                # Check BN layer comes after Conv/Linear without bias
                prev_layer = layer.inbound_nodes[0].inbound_layers[0]
                if hasattr(prev_layer, 'use_bias') and prev_layer.use_bias:
                    return False
        return True

    def validate_learning_rate(self, model, min_lr: float = 1e-6, max_lr: float = 1.0) -> Dict:
        """Find optimal learning rate range."""
        lrs = np.logspace(np.log10(min_lr), np.log10(max_lr), 100)
        losses = []
        
        for lr in lrs:
            model.set_lr(lr)
            try:
                loss = self._train_model(model, epochs=5)[-1]
                losses.append(loss)
            except:
                break
                
        best_idx = np.argmin(losses)
        best_lr = lrs[best_idx]
        
        return {
            "best_lr": best_lr,
            "lrs_tested": lrs[:len(losses)],
            "losses": losses
        }

    def _train_model(self, model, epochs: int) -> List[float]:
        """Helper to train model and collect losses."""
        losses = []
        for _ in range(epochs):
            X, y = self._get_batch()
            loss = model.train_step(X, y)
            losses.append(loss)
        return losses

    def _get_batch(self, batch_size: int = 32):
        """Helper to get random training batch."""
        X = np.random.randn(batch_size, model.input_dim)
        y = np.random.randint(0, model.num_classes, batch_size)
        return X, y

"""Example usage:

validator = MLSystemValidator()

# Validate initialization
init_loss_ok = validator.validate_init_loss(
    model, 
    inputs,
    expected_loss=np.log(1/num_classes)
)

# Test overfitting
overfit_results = validator.overfit_batch_test(model)
if not overfit_results["succeeded"]:
    print(f"Failed to overfit batch, final loss: {overfit_results['final_loss']}")
    
# Validate gradients
grads_isolated = validator.validate_gradient_isolation(model)
if not grads_isolated:
    print("Gradient isolation test failed - check for data leakage")

# Find learning rate
lr_results = validator.validate_learning_rate(model)
print(f"Optimal learning rate: {lr_results['best_lr']}")
"""