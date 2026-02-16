#!/usr/bin/env python3
"""
Model Evaluation Component for ML Pipeline
Evaluates trained models with comprehensive metrics and visualizations
"""

import os
import sys
import pandas as pd
import numpy as np
import joblib
import json
import logging
from datetime import datetime
from sklearn.metrics import (
    mean_squared_error, mean_absolute_error, r2_score,
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, classification_report
)
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend for server environments
import matplotlib.pyplot as plt
import seaborn as sns

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class MLModelEvaluator:
    """Comprehensive model evaluation and comparison."""
    
    def __init__(self):
        self.evaluation_results = {}
        
    def load_model(self, model_path):
        """Load a trained model."""
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found: {model_path}")
        
        logger.info(f"📂 Loading model: {model_path}")
        return joblib.load(model_path)
    
    def load_training_results(self, dataset_name):
        """Load training results for a dataset."""
        results_path = f'data/results/training_results_{dataset_name}.json'
        
        if not os.path.exists(results_path):
            logger.warning(f"⚠️ Training results not found: {results_path}")
            return None
        
        logger.info(f"📂 Loading training results: {results_path}")
        with open(results_path, 'r') as f:
            return json.load(f)
    
    def load_test_data(self, dataset_name):
        """Load or create test data for evaluation."""
        # First try to load processed data
        processed_path = f'data/processed/{dataset_name}_processed.csv'
        
        if os.path.exists(processed_path):
            df = pd.read_csv(processed_path)
        else:
            # Load raw data
            raw_path = f'data/raw/{dataset_name}.csv'
            df = pd.read_csv(raw_path)
        
        logger.info(f"📂 Loaded evaluation data: {df.shape}")
        return df
    
    def evaluate_regression_model(self, y_true, y_pred, model_name):
        """Evaluate a regression model."""
        metrics = {
            'model_name': model_name,
            'mse': float(mean_squared_error(y_true, y_pred)),
            'rmse': float(np.sqrt(mean_squared_error(y_true, y_pred))),
            'mae': float(mean_absolute_error(y_true, y_pred)),
            'r2': float(r2_score(y_true, y_pred)),
            'samples': len(y_true)
        }
        
        logger.info(f"📊 {model_name} - RMSE: {metrics['rmse']:.4f}, R²: {metrics['r2']:.4f}")
        return metrics
    
    def evaluate_classification_model(self, y_true, y_pred, model_name):
        """Evaluate a classification model."""
        # Handle multiclass vs binary classification
        average = 'weighted' if len(np.unique(y_true)) > 2 else 'binary'
        
        metrics = {
            'model_name': model_name,
            'accuracy': float(accuracy_score(y_true, y_pred)),
            'precision': float(precision_score(y_true, y_pred, average=average)),
            'recall': float(recall_score(y_true, y_pred, average=average)),
            'f1': float(f1_score(y_true, y_pred, average=average)),
            'samples': len(y_true)
        }
        
        logger.info(f"📊 {model_name} - Accuracy: {metrics['accuracy']:.4f}, F1: {metrics['f1']:.4f}")
        return metrics
    
    def create_evaluation_plots(self, dataset_name, problem_type, metrics_list):
        """Create evaluation visualizations."""
        logger.info(f"📈 Creating evaluation plots for {dataset_name}...")
        
        # Create plots directory
        plots_dir = f'data/plots/{dataset_name}'
        os.makedirs(plots_dir, exist_ok=True)
        
        plt.style.use('seaborn-v0_8')
        
        if problem_type == 'regression':
            # RMSE comparison
            models = [m['model_name'] for m in metrics_list]
            rmse_scores = [m['rmse'] for m in metrics_list]
            
            plt.figure(figsize=(10, 6))
            bars = plt.bar(models, rmse_scores, color='skyblue', alpha=0.8)
            plt.title(f'Model RMSE Comparison - {dataset_name}', fontsize=14, fontweight='bold')
            plt.xlabel('Model')
            plt.ylabel('RMSE')
            plt.xticks(rotation=45)
            
            # Add value labels on bars
            for bar, score in zip(bars, rmse_scores):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.001,
                        f'{score:.3f}', ha='center', va='bottom')
            
            plt.tight_layout()
            plt.savefig(f'{plots_dir}/rmse_comparison.png', dpi=300, bbox_inches='tight')
            plt.close()
            
            # R² comparison
            r2_scores = [m['r2'] for m in metrics_list]
            
            plt.figure(figsize=(10, 6))
            bars = plt.bar(models, r2_scores, color='lightcoral', alpha=0.8)
            plt.title(f'Model R² Comparison - {dataset_name}', fontsize=14, fontweight='bold')
            plt.xlabel('Model')
            plt.ylabel('R² Score')
            plt.xticks(rotation=45)
            
            for bar, score in zip(bars, r2_scores):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.001,
                        f'{score:.3f}', ha='center', va='bottom')
            
            plt.tight_layout()
            plt.savefig(f'{plots_dir}/r2_comparison.png', dpi=300, bbox_inches='tight')
            plt.close()
            
        else:  # classification
            # Accuracy comparison
            models = [m['model_name'] for m in metrics_list]
            accuracy_scores = [m['accuracy'] for m in metrics_list]
            
            plt.figure(figsize=(10, 6))
            bars = plt.bar(models, accuracy_scores, color='lightgreen', alpha=0.8)
            plt.title(f'Model Accuracy Comparison - {dataset_name}', fontsize=14, fontweight='bold')
            plt.xlabel('Model')
            plt.ylabel('Accuracy')
            plt.xticks(rotation=45)
            plt.ylim(0, 1)
            
            for bar, score in zip(bars, accuracy_scores):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                        f'{score:.3f}', ha='center', va='bottom')
            
            plt.tight_layout()
            plt.savefig(f'{plots_dir}/accuracy_comparison.png', dpi=300, bbox_inches='tight')
            plt.close()
            
            # F1 Score comparison
            f1_scores = [m['f1'] for m in metrics_list]
            
            plt.figure(figsize=(10, 6))
            bars = plt.bar(models, f1_scores, color='orange', alpha=0.8)
            plt.title(f'Model F1-Score Comparison - {dataset_name}', fontsize=14, fontweight='bold')
            plt.xlabel('Model')
            plt.ylabel('F1 Score')
            plt.xticks(rotation=45)
            plt.ylim(0, 1)
            
            for bar, score in zip(bars, f1_scores):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                        f'{score:.3f}', ha='center', va='bottom')
            
            plt.tight_layout()
            plt.savefig(f'{plots_dir}/f1_comparison.png', dpi=300, bbox_inches='tight')
            plt.close()
        
        logger.info(f"✅ Evaluation plots saved to: {plots_dir}")
    
    def evaluate_dataset_models(self, dataset_name):
        """Evaluate all models for a dataset."""
        logger.info(f"📊 Evaluating models for {dataset_name}...")
        
        # Load training results
        training_results = self.load_training_results(dataset_name)
        if not training_results:
            logger.error(f"❌ No training results found for {dataset_name}")
            return False
        
        problem_type = training_results['problem_type']
        
        # Load evaluation data
        df = self.load_test_data(dataset_name)
        
        # Prepare data (same logic as training)
        target_candidates = ['target', 'label', 'class', 'y', 'price', 'MedHouseVal']
        target_column = None
        
        for candidate in target_candidates:
            if candidate in df.columns:
                target_column = candidate
                break
        
        if target_column is None:
            target_column = df.columns[-1]
        
        X = df.drop(columns=[target_column])
        y = df[target_column]
        
        # Split for consistent evaluation
        from sklearn.model_selection import train_test_split
        _, X_test, _, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        logger.info(f"🧪 Evaluating on {len(y_test)} test samples")
        
        # Evaluate each model
        metrics_list = []
        models_dir = 'data/models'
        
        for model_name in training_results['results'].keys():
            model_path = f'{models_dir}/{model_name}_{dataset_name}_model.joblib'
            
            try:
                # Load model
                model = self.load_model(model_path)
                
                # Make predictions
                if model_name in ['svr', 'svc', 'logistic_regression']:
                    # Scale features for models that need it
                    from sklearn.preprocessing import StandardScaler
                    scaler = StandardScaler()
                    X_scaled = scaler.fit_transform(X.iloc[:-len(y_test)])  # Fit on training set
                    X_test_scaled = scaler.transform(X_test)
                    y_pred = model.predict(X_test_scaled)
                else:
                    y_pred = model.predict(X_test)
                
                # Evaluate model
                if problem_type == 'regression':
                    metrics = self.evaluate_regression_model(y_test, y_pred, model_name)
                else:
                    metrics = self.evaluate_classification_model(y_test, y_pred, model_name)
                
                metrics_list.append(metrics)
                
            except Exception as e:
                logger.error(f"❌ Failed to evaluate {model_name}: {e}")
                continue
        
        if not metrics_list:
            logger.error(f"❌ No models could be evaluated for {dataset_name}")
            return False
        
        # Create evaluation summary
        evaluation_summary = {
            'dataset': dataset_name,
            'problem_type': problem_type,
            'evaluation_timestamp': datetime.now().isoformat(),
            'models_evaluated': len(metrics_list),
            'metrics': metrics_list,
            'built_with': 'gaffer-exec ML workflow orchestration'
        }
        
        # Find best model
        if problem_type == 'regression':
            best_model = min(metrics_list, key=lambda x: x['rmse'])
            evaluation_summary['best_model'] = best_model['model_name']
            evaluation_summary['best_score'] = f"RMSE: {best_model['rmse']:.4f}"
        else:
            best_model = max(metrics_list, key=lambda x: x['accuracy'])
            evaluation_summary['best_model'] = best_model['model_name']
            evaluation_summary['best_score'] = f"Accuracy: {best_model['accuracy']:.4f}"
        
        # Save evaluation results
        results_dir = 'data/results'
        evaluation_path = f'{results_dir}/evaluation_results_{dataset_name}.json'
        
        with open(evaluation_path, 'w') as f:
            json.dump(evaluation_summary, f, indent=2)
        
        logger.info(f"✅ Evaluation results saved: {evaluation_path}")
        logger.info(f"🏆 Best model: {evaluation_summary['best_model']} ({evaluation_summary['best_score']})")
        
        # Create visualizations
        self.create_evaluation_plots(dataset_name, problem_type, metrics_list)
        
        return True

def evaluate_dataset(dataset_name):
    """Evaluate models for a specific dataset."""
    logger.info(f"🎯 Evaluating models for {dataset_name} dataset...")
    
    evaluator = MLModelEvaluator()
    return evaluator.evaluate_dataset_models(dataset_name)

def main():
    """Main evaluation pipeline."""
    logger.info("🚀 Starting ML model evaluation pipeline...")
    
    # Available datasets
    datasets = ['california_housing', 'iris', 'wine']
    
    successful_evaluations = 0
    
    for dataset in datasets:
        logger.info(f"\n{'='*50}")
        logger.info(f"Evaluating models for {dataset}")
        logger.info(f"{'='*50}")
        
        if evaluate_dataset(dataset):
            successful_evaluations += 1
    
    logger.info(f"\n🎉 Evaluation pipeline completed!")
    logger.info(f"📊 Successfully evaluated {successful_evaluations}/{len(datasets)} datasets")
    logger.info("🔧 Built with: gaffer-exec ML workflow orchestration")
    
    if successful_evaluations > 0:
        return 0
    else:
        logger.error("❌ No models were successfully evaluated")
        return 1

if __name__ == "__main__":
    exit(main())