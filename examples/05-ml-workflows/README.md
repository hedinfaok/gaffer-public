# Machine Learning Workflows

This example demonstrates **real ML pipeline orchestration** using popular data science tools, similar to patterns used in production ML systems.

## Real Open Source Project Pattern

This follows ML workflow patterns used by:
- **Apache Airflow** (ML pipeline orchestration)
- **Kubeflow** (Kubernetes-native ML workflows)  
- **MLflow** (ML lifecycle management)
- **DVC** (Data Version Control pipelines)

## Project Structure

```
05-ml-workflows/
├── data/
│   ├── raw/                 # Raw input data
│   ├── processed/           # Processed datasets
│   └── models/              # Trained model artifacts
├── src/
│   ├── data_prep.py         # Data preprocessing
│   ├── feature_engineering.py # Feature extraction
│   ├── train_model.py       # Model training
│   ├── evaluate_model.py    # Model evaluation
│   └── deploy_model.py      # Model deployment
├── notebooks/
│   └── explore_data.ipynb   # Jupyter notebook for EDA
├── requirements.txt         # Python dependencies
├── Makefile                 # gaffer-exec ML pipeline targets
└── mlflow_tracking.py      # MLflow experiment tracking
```

## ML Pipeline Dependency Graph

```
data-download ──> data-validation ──> data-preprocessing
                                            │
feature-engineering ←─────────────────────────
         │
model-training ──> model-evaluation ──> model-deployment
    │                      │                    │
hyperparameter-tuning      │              model-serving
         │                 │                    │
model-comparison ←─────────┴─────> model-registry
                                        │
                            monitoring-setup
```

**Key Features:**
- Real scikit-learn, pandas, numpy ML pipeline
- Hyperparameter tuning with multiple parallel jobs
- Model evaluation and comparison
- MLflow experiment tracking integration
- Realistic data processing workflows

## How to Run

```bash
# Install ML dependencies (runs automatically as dependency, but can run standalone)
gaffer-exec --workspace-root . run make:setup

# Run full ML pipeline
gaffer-exec --workspace-root . run make:pipeline

# Run just data preparation
gaffer-exec --workspace-root . run make:data-prep

# Run training and evaluation only (skips data prep if already done)
gaffer-exec --workspace-root . run make:train-only

# Run individual pipeline stages
gaffer-exec --workspace-root . run make:feature-engineering  # Feature engineering only
gaffer-exec --workspace-root . run make:train-models         # Model training only
gaffer-exec --workspace-root . run make:evaluate-models      # Model evaluation only

# Clean up generated data
gaffer-exec --workspace-root . run make:clean
```

## Expected Output

**Complete ML workflow execution:**
- Downloads dataset (e.g., California housing, iris)
- Preprocesses and validates data quality
- Engineers features in parallel
- Trains multiple models (Random Forest, XGBoost, SVM)
- Evaluates and compares model performance
- Deploys best model with monitoring

## Real Implementation

Each pipeline step uses production ML tools:
- **pandas/numpy** for data manipulation
- **scikit-learn** for preprocessing and modeling  
- **xgboost** for gradient boosting
- **mlflow** for experiment tracking
- **joblib** for model persistence
- **matplotlib/seaborn** for visualization

## Data Sources

Uses real open datasets:
- California housing prices (regression)
- Iris flower classification  
- Wine quality dataset
- Boston housing (regression)