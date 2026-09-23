#!/usr/bin/env python3
"""
Data Download and Preparation for ML Pipeline
Downloads real datasets for machine learning workflows
"""

import os
import pandas as pd
import numpy as np
import requests
from sklearn.datasets import fetch_california_housing, load_iris, load_wine
import logging

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def create_directories():
    """Create necessary directories for data storage."""
    directories = ['data/raw', 'data/processed', 'data/models', 'data/results']
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        logger.info(f"Created directory: {directory}")

def download_california_housing():
    """Download California housing dataset."""
    logger.info("Downloading California housing dataset...")
    
    # Use scikit-learn's built-in dataset
    housing = fetch_california_housing(as_frame=True)
    df = housing.frame
    
    # Save to CSV
    output_path = 'data/raw/california_housing.csv'
    df.to_csv(output_path, index=False)
    
    logger.info(f"✓ California housing dataset saved: {output_path}")
    logger.info(f"Shape: {df.shape}, Features: {list(housing.feature_names)}")
    
    return output_path

def download_iris_dataset():
    """Download Iris classification dataset."""
    logger.info("Downloading Iris dataset...")
    
    iris = load_iris(as_frame=True)
    df = iris.frame
    
    output_path = 'data/raw/iris.csv'
    df.to_csv(output_path, index=False)
    
    logger.info(f"✓ Iris dataset saved: {output_path}")
    logger.info(f"Shape: {df.shape}, Classes: {iris.target_names}")
    
    return output_path

def download_wine_dataset():
    """Download Wine quality dataset."""
    logger.info("Downloading Wine dataset...")
    
    wine = load_wine(as_frame=True)
    df = wine.frame
    
    output_path = 'data/raw/wine.csv'
    df.to_csv(output_path, index=False)
    
    logger.info(f"✓ Wine dataset saved: {output_path}")
    logger.info(f"Shape: {df.shape}, Classes: {wine.target_names}")
    
    return output_path

def download_external_dataset():
    """Download an external dataset from the web."""
    logger.info("External dataset download disabled for this demo...")
    logger.info("Skipping external dataset to maintain consistency with pipeline")
    logger.info("Using only scikit-learn built-in datasets: california_housing, iris, wine")
    
    return None  # No external dataset

def generate_dataset_metadata():
    """Generate metadata about downloaded datasets."""
    logger.info("Generating dataset metadata...")
    
    metadata = {
        'datasets': [],
        'download_timestamp': pd.Timestamp.now().isoformat(),
        'total_datasets': 0,
        'total_samples': 0,
        'total_features': 0
    }
    
    # Scan data/raw directory
    raw_data_path = 'data/raw'
    if os.path.exists(raw_data_path):
        for filename in os.listdir(raw_data_path):
            if filename.endswith('.csv'):
                filepath = os.path.join(raw_data_path, filename)
                try:
                    df = pd.read_csv(filepath)
                    dataset_info = {
                        'filename': filename,
                        'shape': df.shape,
                        'columns': list(df.columns),
                        'size_mb': round(os.path.getsize(filepath) / (1024 * 1024), 2),
                        'null_values': df.isnull().sum().sum(),
                        'datatypes': df.dtypes.to_dict()
                    }
                    metadata['datasets'].append(dataset_info)
                    metadata['total_samples'] += df.shape[0]
                    metadata['total_features'] += df.shape[1]
                    
                except Exception as e:
                    logger.warning(f"⚠ Could not process {filename}: {e}")
    
    metadata['total_datasets'] = len(metadata['datasets'])
    
    # Save metadata
    metadata_path = 'data/raw/metadata.json'
    import json
    with open(metadata_path, 'w') as f:
        # Convert numpy types to regular Python types for JSON serialization
        def convert_numpy_types(obj):
            if isinstance(obj, dict):
                return {k: convert_numpy_types(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                return [convert_numpy_types(item) for item in obj]
            elif isinstance(obj, np.integer):
                return int(obj)
            elif isinstance(obj, np.floating):
                return float(obj)
            elif isinstance(obj, np.ndarray):
                return obj.tolist()
            else:
                return obj
        
        json.dump(convert_numpy_types(metadata), f, indent=2, default=str)
    
    logger.info(f"✓ Metadata saved: {metadata_path}")
    logger.info(f"Summary: {metadata['total_datasets']} datasets, {metadata['total_samples']:,} total samples")
    
    return metadata_path

def main():
    """Main data download pipeline."""
    logger.info("Starting ML data download pipeline...")
    
    # Create directories
    create_directories()
    
    # Download datasets
    datasets = []
    
    try:
        datasets.append(download_california_housing())
    except Exception as e:
        logger.error(f"✗ Failed to download California housing: {e}")
    
    try:
        datasets.append(download_iris_dataset())
    except Exception as e:
        logger.error(f"✗ Failed to download Iris: {e}")
    
    try:
        datasets.append(download_wine_dataset())
    except Exception as e:
        logger.error(f"✗ Failed to download Wine: {e}")
    
    try:
        datasets.append(download_external_dataset())
    except Exception as e:
        logger.error(f"✗ Failed to download external dataset: {e}")
    
    # Generate metadata
    try:
        generate_dataset_metadata()
    except Exception as e:
        logger.error(f"✗ Failed to generate metadata: {e}")
    
    logger.info(f"✓ Data download completed! {len(datasets)} datasets ready for ML pipeline.")
    logger.info("Built with: gaffer-exec ML workflow orchestration")
    
    return 0

if __name__ == "__main__":
    exit(main())