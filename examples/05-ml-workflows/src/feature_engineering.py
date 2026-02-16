#!/usr/bin/env python3
"""
Feature Engineering Component for ML Pipeline
Transforms and enriches raw data using scikit-learn preprocessing
"""

import os
import sys
import pandas as pd
import numpy as np
import json
import logging
from datetime import datetime
from sklearn.preprocessing import (
    StandardScaler, MinMaxScaler, RobustScaler,
    LabelEncoder, OneHotEncoder,
    PolynomialFeatures, PowerTransformer
)
from sklearn.feature_selection import SelectKBest, f_regression, f_classif
from sklearn.decomposition import PCA
from sklearn.impute import SimpleImputer

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class FeatureEngineer:
    """Handles feature engineering and preprocessing."""
    
    def __init__(self):
        self.transformers = {}
        self.feature_info = {}
        
    def load_raw_data(self, dataset_name):
        """Load raw data for feature engineering."""
        raw_path = f'data/raw/{dataset_name}.csv'
        
        if not os.path.exists(raw_path):
            raise FileNotFoundError(f"Raw data not found: {raw_path}")
        
        logger.info(f"📂 Loading raw data: {raw_path}")
        df = pd.read_csv(raw_path)
        
        logger.info(f"📊 Raw data shape: {df.shape}")
        logger.info(f"📋 Columns: {list(df.columns)}")
        
        return df
    
    def analyze_data(self, df):
        """Analyze data characteristics for feature engineering decisions."""
        logger.info("🔍 Analyzing data characteristics...")
        
        analysis = {
            'shape': df.shape,
            'columns': list(df.columns),
            'dtypes': df.dtypes.to_dict(),
            'missing_values': df.isnull().sum().to_dict(),
            'numeric_columns': df.select_dtypes(include=[np.number]).columns.tolist(),
            'categorical_columns': df.select_dtypes(include=['object']).columns.tolist(),
        }
        
        # Statistical summary for numeric columns
        if analysis['numeric_columns']:
            analysis['numeric_summary'] = df[analysis['numeric_columns']].describe().to_dict()
        
        logger.info(f"🔢 Numeric columns: {len(analysis['numeric_columns'])}")
        logger.info(f"🏷️ Categorical columns: {len(analysis['categorical_columns'])}")
        logger.info(f"❓ Missing values: {sum(analysis['missing_values'].values())}")
        
        return analysis
    
    def handle_missing_values(self, df, strategy='mean'):
        """Handle missing values in the dataset."""
        logger.info(f"🔧 Handling missing values with strategy: {strategy}")
        
        missing_counts = df.isnull().sum()
        columns_with_missing = missing_counts[missing_counts > 0].index.tolist()
        
        if not columns_with_missing:
            logger.info("✅ No missing values found")
            return df
        
        logger.info(f"🔧 Columns with missing values: {columns_with_missing}")
        
        df_imputed = df.copy()
        
        # Handle numeric columns
        numeric_missing = [col for col in columns_with_missing if df[col].dtype in [np.number]]
        if numeric_missing:
            imputer = SimpleImputer(strategy=strategy)
            df_imputed[numeric_missing] = imputer.fit_transform(df_imputed[numeric_missing])
            self.transformers['numeric_imputer'] = imputer
        
        # Handle categorical columns
        categorical_missing = [col for col in columns_with_missing if df[col].dtype == 'object']
        if categorical_missing:
            imputer = SimpleImputer(strategy='most_frequent')
            df_imputed[categorical_missing] = imputer.fit_transform(df_imputed[categorical_missing])
            self.transformers['categorical_imputer'] = imputer
        
        logger.info(f"✅ Missing values handled for {len(columns_with_missing)} columns")
        return df_imputed
    
    def encode_categorical_features(self, df):
        """Encode categorical features."""
        categorical_cols = df.select_dtypes(include=['object']).columns.tolist()
        
        if not categorical_cols:
            logger.info("✅ No categorical features to encode")
            return df
        
        logger.info(f"🔤 Encoding categorical features: {categorical_cols}")
        
        df_encoded = df.copy()
        
        for col in categorical_cols:
            unique_values = df[col].nunique()
            
            if unique_values <= 2:
                # Binary encoding for binary variables
                le = LabelEncoder()
                df_encoded[col] = le.fit_transform(df_encoded[col])
                self.transformers[f'{col}_label_encoder'] = le
                logger.info(f"🏷️ Binary encoded: {col} ({unique_values} values)")
                
            elif unique_values <= 10:
                # One-hot encoding for low cardinality
                encoder = OneHotEncoder(sparse=False, drop='first')
                encoded_features = encoder.fit_transform(df_encoded[[col]])
                feature_names = [f"{col}_{category}" for category in encoder.categories_[0][1:]]
                
                # Add encoded features
                for i, feature_name in enumerate(feature_names):
                    df_encoded[feature_name] = encoded_features[:, i]
                
                # Remove original column
                df_encoded = df_encoded.drop(columns=[col])
                self.transformers[f'{col}_onehot_encoder'] = encoder
                logger.info(f"🎯 One-hot encoded: {col} ({unique_values} values → {len(feature_names)} features)")
                
            else:
                # Label encoding for high cardinality
                le = LabelEncoder()
                df_encoded[col] = le.fit_transform(df_encoded[col])
                self.transformers[f'{col}_label_encoder'] = le
                logger.info(f"🔢 Label encoded: {col} ({unique_values} values)")
        
        return df_encoded
    
    def engineer_features(self, df, dataset_name):
        """Create new features based on domain knowledge."""
        logger.info(f"⚙️ Engineering features for {dataset_name}...")
        
        df_engineered = df.copy()
        
        # Dataset-specific feature engineering
        if dataset_name == 'california_housing':
            # California housing specific features
            if all(col in df.columns for col in ['AveRooms', 'AveBedrms']):
                df_engineered['RoomsToBedrooms'] = df_engineered['AveRooms'] / (df_engineered['AveBedrms'] + 1e-8)
                logger.info("🏠 Created RoomsToBedrooms ratio feature")
            
            if all(col in df.columns for col in ['Population', 'AveOccup']):
                df_engineered['PopulationDensity'] = df_engineered['Population'] / (df_engineered['AveOccup'] + 1e-8)
                logger.info("👥 Created PopulationDensity feature")
                
            if all(col in df.columns for col in ['Latitude', 'Longitude']):
                # Distance from center of California (approximate)
                center_lat, center_lon = 36.7783, -119.4179
                df_engineered['DistanceFromCenter'] = np.sqrt(
                    (df_engineered['Latitude'] - center_lat)**2 + 
                    (df_engineered['Longitude'] - center_lon)**2
                )
                logger.info("🗺️ Created DistanceFromCenter feature")
        
        elif dataset_name in ['iris', 'wine']:
            # For classification datasets, create interaction features
            numeric_cols = df_engineered.select_dtypes(include=[np.number]).columns.tolist()
            
            # Remove target column if present
            target_candidates = ['target', 'label', 'class']
            for target in target_candidates:
                if target in numeric_cols:
                    numeric_cols.remove(target)
            
            if len(numeric_cols) >= 2:
                # Create polynomial features (degree 2)
                poly = PolynomialFeatures(degree=2, include_bias=False, interaction_only=True)
                poly_features = poly.fit_transform(df_engineered[numeric_cols])
                poly_feature_names = poly.get_feature_names_out(numeric_cols)
                
                # Add only interaction terms (not squared terms)
                interaction_indices = [i for i, name in enumerate(poly_feature_names) 
                                     if ' ' in name and name.count(' ') == 1]
                
                if interaction_indices:
                    interaction_features = poly_features[:, interaction_indices]
                    interaction_names = [poly_feature_names[i] for i in interaction_indices]
                    
                    for i, name in enumerate(interaction_names):
                        clean_name = name.replace(' ', '_')
                        df_engineered[f'interaction_{clean_name}'] = interaction_features[:, i]
                    
                    self.transformers['polynomial_features'] = poly
                    logger.info(f"🔗 Created {len(interaction_names)} interaction features")
        
        # General feature engineering
        numeric_cols = df_engineered.select_dtypes(include=[np.number]).columns.tolist()
        if len(numeric_cols) > 2:
            # Create aggregate features
            df_engineered['feature_sum'] = df_engineered[numeric_cols].sum(axis=1)
            df_engineered['feature_mean'] = df_engineered[numeric_cols].mean(axis=1)
            df_engineered['feature_std'] = df_engineered[numeric_cols].std(axis=1)
            logger.info("📊 Created aggregate statistical features")
        
        logger.info(f"✅ Feature engineering completed: {df_engineered.shape[1]} features")
        return df_engineered
    
    def scale_features(self, df, method='standard'):
        """Scale features using specified method."""
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        # Remove target column if present
        target_candidates = ['target', 'label', 'class']
        for target in target_candidates:
            if target in numeric_cols:
                numeric_cols.remove(target)
        
        if not numeric_cols:
            logger.info("✅ No numeric features to scale")
            return df
        
        logger.info(f"📏 Scaling features using {method} scaling...")
        
        df_scaled = df.copy()
        
        if method == 'standard':
            scaler = StandardScaler()
        elif method == 'minmax':
            scaler = MinMaxScaler()
        elif method == 'robust':
            scaler = RobustScaler()
        else:
            logger.warning(f"⚠️ Unknown scaling method: {method}, using standard")
            scaler = StandardScaler()
        
        df_scaled[numeric_cols] = scaler.fit_transform(df_scaled[numeric_cols])
        self.transformers[f'{method}_scaler'] = scaler
        
        logger.info(f"✅ Scaled {len(numeric_cols)} numeric features")
        return df_scaled
    
    def select_features(self, df, target_column=None, k=10):
        """Select top k features using statistical tests."""
        if target_column is None:
            # Auto-detect target column
            target_candidates = ['target', 'label', 'class', 'y', 'price', 'MedHouseVal']
            for candidate in target_candidates:
                if candidate in df.columns:
                    target_column = candidate
                    break
            
            if target_column is None:
                logger.info("⚠️ No target column found, skipping feature selection")
                return df
        
        logger.info(f"🎯 Selecting top {k} features using target: {target_column}")
        
        X = df.drop(columns=[target_column])
        y = df[target_column]
        
        # Determine problem type
        if y.dtype == 'object' or len(y.unique()) < 20:
            score_func = f_classif
            problem_type = 'classification'
        else:
            score_func = f_regression
            problem_type = 'regression'
        
        logger.info(f"📊 Problem type: {problem_type}")
        
        # Select features
        k = min(k, X.shape[1])  # Can't select more features than available
        selector = SelectKBest(score_func=score_func, k=k)
        X_selected = selector.fit_transform(X, y)
        
        # Get selected feature names
        selected_features = X.columns[selector.get_support()].tolist()
        self.transformers['feature_selector'] = selector
        
        # Create output dataframe
        df_selected = pd.DataFrame(X_selected, columns=selected_features, index=df.index)
        df_selected[target_column] = y
        
        logger.info(f"✅ Selected {len(selected_features)} features: {selected_features}")
        return df_selected
    
    def save_processed_data(self, df, dataset_name):
        """Save processed data and feature information."""
        logger.info(f"💾 Saving processed data for {dataset_name}...")
        
        # Save processed data
        processed_dir = 'data/processed'
        os.makedirs(processed_dir, exist_ok=True)
        
        processed_path = f'{processed_dir}/{dataset_name}_processed.csv'
        df.to_csv(processed_path, index=False)
        
        # Save feature engineering metadata
        metadata = {
            'dataset': dataset_name,
            'original_shape': self.feature_info.get('original_shape', df.shape),
            'processed_shape': df.shape,
            'columns': list(df.columns),
            'dtypes': df.dtypes.to_dict(),
            'transformers_applied': list(self.transformers.keys()),
            'processing_timestamp': datetime.now().isoformat(),
            'built_with': 'gaffer-exec ML workflow orchestration'
        }
        
        metadata_path = f'{processed_dir}/{dataset_name}_metadata.json'
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2, default=str)
        
        logger.info(f"✅ Processed data saved: {processed_path}")
        logger.info(f"📋 Metadata saved: {metadata_path}")
        logger.info(f"📊 Shape: {metadata['original_shape']} → {metadata['processed_shape']}")
        
        return processed_path, metadata_path

def process_dataset(dataset_name):
    """Process a specific dataset through the feature engineering pipeline."""
    logger.info(f"🎯 Processing {dataset_name} dataset...")
    
    engineer = FeatureEngineer()
    
    try:
        # Load raw data
        df = engineer.load_raw_data(dataset_name)
        engineer.feature_info['original_shape'] = df.shape
        
        # Analyze data
        analysis = engineer.analyze_data(df)
        
        # Feature engineering pipeline
        logger.info("\n🔧 Starting feature engineering pipeline...")
        
        # 1. Handle missing values
        df = engineer.handle_missing_values(df)
        
        # 2. Encode categorical features
        df = engineer.encode_categorical_features(df)
        
        # 3. Engineer domain-specific features
        df = engineer.engineer_features(df, dataset_name)
        
        # 4. Scale features
        df = engineer.scale_features(df, method='standard')
        
        # 5. Feature selection (optional)
        if df.shape[1] > 15:  # Only if we have many features
            df = engineer.select_features(df, k=15)
        
        # Save processed data
        engineer.save_processed_data(df, dataset_name)
        
        logger.info(f"✅ Feature engineering completed for {dataset_name}")
        return True
        
    except Exception as e:
        logger.error(f"❌ Feature engineering failed for {dataset_name}: {e}")
        return False

def main():
    """Main feature engineering pipeline."""
    logger.info("🚀 Starting ML feature engineering pipeline...")
    
    # Available datasets
    datasets = ['california_housing', 'iris', 'wine']
    
    successful_processing = 0
    
    for dataset in datasets:
        logger.info(f"\n{'='*50}")
        logger.info(f"Processing {dataset}")
        logger.info(f"{'='*50}")
        
        if process_dataset(dataset):
            successful_processing += 1
    
    logger.info(f"\n🎉 Feature engineering pipeline completed!")
    logger.info(f"📊 Successfully processed {successful_processing}/{len(datasets)} datasets")
    logger.info("🔧 Built with: gaffer-exec ML workflow orchestration")
    
    if successful_processing > 0:
        return 0
    else:
        logger.error("❌ No datasets were successfully processed")
        return 1

if __name__ == "__main__":
    exit(main())