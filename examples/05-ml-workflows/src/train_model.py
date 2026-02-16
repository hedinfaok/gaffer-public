#!/usr/bin/env python3
"""
Model Training Component for ML Pipeline
Trains multiple ML models using scikit-learn and XGBoost
"""

import os
import sys
import pandas as pd
import numpy as np
import joblib
import json
import logging
from datetime import datetime
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.svm import SVR, SVC
from sklearn.metrics import mean_squared_error, accuracy_score, classification_report
from sklearn.preprocessing import StandardScaler

try:
    import xgboost as xgb
    XGBOOST_AVAILABLE = True
except ImportError:
    logger.warning("⚠️ XGBoost not available - skipping XGBoost models")
    XGBOOST_AVAILABLE = False

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class MLModelTrainer:
    """Handles training of multiple ML models."""
    
    def __init__(self, random_state=42):
        self.random_state = random_state
        self.models = {}
        self.results = {}
        self.scalers = {}
        
    def load_processed_data(self, dataset_name):
        """Load processed data from the data pipeline."""
        processed_path = f'data/processed/{dataset_name}_processed.csv'
        
        if not os.path.exists(processed_path):
            logger.warning(f"⚠️ Processed data not found: {processed_path}")
            # Try loading raw data instead
            raw_path = f'data/raw/{dataset_name}.csv'
            if os.path.exists(raw_path):
                logger.info(f"📂 Loading raw data: {raw_path}")
                return pd.read_csv(raw_path)
            else:
                raise FileNotFoundError(f"Neither processed nor raw data found for {dataset_name}")
        
        logger.info(f"📂 Loading processed data: {processed_path}")
        return pd.read_csv(processed_path)
    
    def prepare_data(self, df, target_column=None, problem_type='auto'):
        """Prepare data for training."""
        logger.info(f"🔧 Preparing data for training...")
        
        # Auto-detect target column if not specified
        if target_column is None:
            # Common target column names
            target_candidates = ['target', 'label', 'class', 'y', 'price', 'MedHouseVal']
            for candidate in target_candidates:
                if candidate in df.columns:
                    target_column = candidate
                    break
            
            if target_column is None:
                # Use last column as target
                target_column = df.columns[-1]
                logger.info(f"🎯 Using last column as target: {target_column}")
        
        logger.info(f"🎯 Target column: {target_column}")
        
        # Separate features and target
        X = df.drop(columns=[target_column])
        y = df[target_column]
        
        # Auto-detect problem type
        if problem_type == 'auto':
            if y.dtype == 'object' or len(y.unique()) < 20:
                problem_type = 'classification'
            else:
                problem_type = 'regression'
        
        logger.info(f"📊 Problem type: {problem_type}")
        logger.info(f"📏 Features: {X.shape[1]}, Samples: {X.shape[0]}")
        
        return X, y, problem_type
    
    def create_models(self, problem_type):
        """Create model instances based on problem type."""
        models = {}
        
        if problem_type == 'regression':
            models = {
                'linear_regression': LinearRegression(),
                'random_forest': RandomForestRegressor(
                    n_estimators=100, 
                    random_state=self.random_state,
                    n_jobs=-1
                ),
                'svr': SVR(kernel='rbf'),
            }
            
            if XGBOOST_AVAILABLE:
                models['xgboost'] = xgb.XGBRegressor(
                    random_state=self.random_state,
                    n_jobs=-1
                )
                
        else:  # classification
            models = {
                'logistic_regression': LogisticRegression(
                    random_state=self.random_state,
                    max_iter=1000
                ),
                'random_forest': RandomForestClassifier(
                    n_estimators=100,
                    random_state=self.random_state,
                    n_jobs=-1
                ),
                'svc': SVC(kernel='rbf', random_state=self.random_state),
            }
            
            if XGBOOST_AVAILABLE:
                models['xgboost'] = xgb.XGBClassifier(
                    random_state=self.random_state,
                    n_jobs=-1
                )
        
        logger.info(f"🤖 Created {len(models)} models: {list(models.keys())}")
        return models
    
    def train_models(self, X, y, problem_type, dataset_name):
        """Train all models and evaluate performance."""
        logger.info("🚀 Starting model training...")
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=self.random_state
        )
        
        logger.info(f"📊 Training set: {X_train.shape}, Test set: {X_test.shape}")
        
        # Scale features for models that need it
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)
        
        self.scalers['standard'] = scaler
        
        # Get models
        models = self.create_models(problem_type)
        results = {}
        
        for model_name, model in models.items():
            logger.info(f"🔄 Training {model_name}...")
            
            try:
                # Use scaled features for SVM and logistic regression
                if model_name in ['svr', 'svc', 'logistic_regression']:
                    model.fit(X_train_scaled, y_train)
                    y_pred = model.predict(X_test_scaled)
                else:
                    model.fit(X_train, y_train)
                    y_pred = model.predict(X_test)
                
                # Evaluate model
                if problem_type == 'regression':
                    mse = mean_squared_error(y_test, y_pred)
                    score = np.sqrt(mse)  # RMSE
                    metric_name = 'RMSE'
                    logger.info(f"✅ {model_name} - {metric_name}: {score:.4f}")
                else:
                    score = accuracy_score(y_test, y_pred)
                    metric_name = 'Accuracy'
                    logger.info(f"✅ {model_name} - {metric_name}: {score:.4f}")
                
                results[model_name] = {
                    'model': model,
                    'score': score,
                    'metric': metric_name,
                    'predictions': y_pred.tolist() if hasattr(y_pred, 'tolist') else list(y_pred),
                    'training_time': datetime.now().isoformat()
                }
                
                # Ensure models directory exists
                os.makedirs('data/models', exist_ok=True)
                
                # Save individual model with dataset-specific naming
                model_path = f'data/models/{model_name}_{dataset_name}_model.joblib'
                joblib.dump(model, model_path)
                logger.info(f"💾 Saved model: {model_path}")
                
            except Exception as e:
                logger.error(f"❌ Failed to train {model_name}: {e}")
                continue
        
        return results, X_test, y_test
    
    def save_training_results(self, results, dataset_name, problem_type):
        """Save training results and model comparison."""
        logger.info("💾 Saving training results...")
        
        # Prepare results for JSON serialization
        json_results = {}
        for model_name, result in results.items():
            json_results[model_name] = {
                'score': float(result['score']),
                'metric': result['metric'],
                'training_time': result['training_time']
            }
        
        # Add metadata
        training_summary = {
            'dataset': dataset_name,
            'problem_type': problem_type,
            'models_trained': len(results),
            'best_model': min(results.keys(), key=lambda x: results[x]['score']) if problem_type == 'regression' else max(results.keys(), key=lambda x: results[x]['score']),
            'training_timestamp': datetime.now().isoformat(),
            'results': json_results,
            'built_with': 'gaffer-exec ML workflow orchestration'
        }
        
        # Save results
        results_path = f'data/results/training_results_{dataset_name}.json'
        os.makedirs('data/results', exist_ok=True)
        
        with open(results_path, 'w') as f:
            json.dump(training_summary, f, indent=2)
        
        logger.info(f"✅ Training results saved: {results_path}")
        logger.info(f"🏆 Best model: {training_summary['best_model']} ({training_summary['problem_type']})")
        
        return results_path

def train_dataset(dataset_name):
    """Train models on a specific dataset."""
    logger.info(f"🎯 Training models on {dataset_name} dataset...")
    
    trainer = MLModelTrainer()
    
    try:
        # Load data
        df = trainer.load_processed_data(dataset_name)
        
        # Prepare data
        X, y, problem_type = trainer.prepare_data(df)
        
        # Train models
        results, X_test, y_test = trainer.train_models(X, y, problem_type, dataset_name)
        
        # Save results
        trainer.save_training_results(results, dataset_name, problem_type)
        
        logger.info(f"✅ Training completed for {dataset_name}")
        return True
        
    except Exception as e:
        logger.error(f"❌ Training failed for {dataset_name}: {e}")
        return False

def main():
    """Main training pipeline."""
    logger.info("🚀 Starting ML model training pipeline...")
    
    # Available datasets
    datasets = ['california_housing', 'iris', 'wine']
    
    successful_trainings = 0
    
    for dataset in datasets:
        logger.info(f"\n{'='*50}")
        logger.info(f"Training models on {dataset}")
        logger.info(f"{'='*50}")
        
        if train_dataset(dataset):
            successful_trainings += 1
    
    logger.info(f"\n🎉 Training pipeline completed!")
    logger.info(f"📊 Successfully trained models on {successful_trainings}/{len(datasets)} datasets")
    logger.info("🔧 Built with: gaffer-exec ML workflow orchestration")
    
    if successful_trainings > 0:
        return 0
    else:
        logger.error("❌ No models were successfully trained")
        return 1

if __name__ == "__main__":
    exit(main())