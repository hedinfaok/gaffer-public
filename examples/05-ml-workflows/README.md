# Machine Learning Workflows

What this shows: a real scikit-learn and XGBoost pipeline, from raw data through training and evaluation to a consolidated report, orchestrated as a gaffer-exec task graph.

## What you'll learn

- Staged pipeline orchestration: each stage is a Make target with an explicit prerequisite.
- Dependency-aware scheduling: a stage runs only after the stage that produces its inputs.
- Content-based caching: unchanged stages are skipped on repeat runs.
- Running one stage in isolation (`make:feature-engineering`, `make:train-models`, `make:evaluate-models`).
- A training-only shortcut (`make:train-only`) that reuses existing prepared data.

## Prerequisites

- Python 3.9 or later
- `python3 -m venv` available
- gaffer-exec on your PATH

The `setup` target creates a virtual environment and installs everything in `requirements.txt` (pandas, numpy, scikit-learn, xgboost, matplotlib, seaborn, joblib, and more), so no manual install is required.

## Quick start

```bash
# Create the virtual environment and install dependencies
gaffer-exec --workspace-root . run make:setup

# Run the full pipeline
gaffer-exec --workspace-root . run make:pipeline
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `setup` | - | Creates `venv` and installs `requirements.txt` |
| `data-prep` | `setup` | Downloads and writes the raw datasets |
| `feature-engineering` | `data-prep` | Cleans, encodes, engineers, and scales features |
| `train-models` | `feature-engineering` | Trains candidate models per dataset |
| `evaluate-models` | `train-models` | Scores models and writes comparison plots |
| `report` | `evaluate-models` | Prints the consolidated pipeline report |
| `pipeline` | `report` | Full pipeline entry point (default goal) |
| `train-only` | `train-models`, `evaluate-models`, `report` | Reuses prepared data and skips data prep |
| `clean` | - | Removes generated data, models, results, and plots |

## How it works

```
setup -> data-prep -> feature-engineering -> train-models -> evaluate-models -> report -> pipeline
```

Each stage is a Python script under `src/`, and each one reads the previous stage's output:

| Stage | Script | Reads | Writes |
|-------|--------|-------|--------|
| Data prep | `src/data_prep.py` | scikit-learn built-in datasets | `data/raw/*.csv`, `data/raw/metadata.json` |
| Feature engineering | `src/feature_engineering.py` | `data/raw/*.csv` | `data/processed/*_processed.csv`, `*_metadata.json` |
| Training | `src/train_model.py` | `data/processed/*_processed.csv` | `data/models/*.joblib`, `data/results/training_results_*.json` |
| Evaluation | `src/evaluate_model.py` | models and processed data | `data/results/evaluation_results_*.json`, `data/plots/<dataset>/*.png` |
| Report | `src/generate_report.py` | `data/models`, `data/results`, `data/plots` | console summary |

Pattern: the classic ingest, prepare, engineer, train, evaluate, report pipeline expressed as Make prerequisites. Because gaffer-exec caches by content, re-running `make:pipeline` after editing only a training script skips data prep and feature engineering.

### Datasets

The pipeline processes three datasets bundled with scikit-learn, so it runs offline:

- `california_housing` - regression (predict median house value).
- `iris` - classification (three flower species).
- `wine` - classification (three wine cultivars).

`data_prep.py` writes each to `data/raw/` and records shapes, columns, null counts, and sizes in `data/raw/metadata.json`.

### Feature engineering

For every dataset the script:

1. Imputes missing values (mean for numeric, most frequent for categorical).
2. Encodes categoricals (label for binary, one-hot for low cardinality, label for high cardinality).
3. Adds domain features, for example `RoomsToBedrooms`, `PopulationDensity`, and `DistanceFromCenter` for housing, and interaction terms for iris and wine.
4. Adds aggregate features (`feature_sum`, `feature_mean`, `feature_std`).
5. Standard-scales numeric features.
6. Selects the top 15 features with `SelectKBest` when the frame has more than 15 columns.

### Models

Training auto-detects regression versus classification and builds the matching candidate set:

- Regression: `linear_regression`, `random_forest`, `svr`, and `xgboost` (when installed).
- Classification: `logistic_regression`, `random_forest`, `svc`, and `xgboost` (when installed).

Regression models report RMSE; classification models report accuracy. Each fitted model is saved with `joblib` to `data/models/{model}_{dataset}_model.joblib`.

## Expected output

Data prep and training log progress line by line:

```text
✓ California housing dataset saved: data/raw/california_housing.csv
✓ Iris dataset saved: data/raw/iris.csv
✓ Wine dataset saved: data/raw/wine.csv
✓ Metadata saved: data/raw/metadata.json
Summary: 3 datasets, 1200 total samples

Training random_forest...
✓ random_forest - RMSE: 0.4903
```

The final `report` stage prints a summary such as:

```text
ML Pipeline Completed Successfully!

Generated Models:
   - random_forest_california_housing_model.joblib
   - random_forest_iris_model.joblib
   - ...

Results:
   - evaluation_results_california_housing.json
   - training_results_california_housing.json
   - ...

Summary:
   Dataset: california_housing, Best Model: random_forest, Score: RMSE: 0.4903
   Dataset: iris, Best Model: random_forest, Score: Accuracy: 0.9667
   Dataset: wine, Best Model: random_forest, Score: Accuracy: 0.9722

Generated Plots:
   - plots/california_housing/rmse_comparison.png
   - plots/iris/accuracy_comparison.png
```

Model scores depend on the installed library versions and the random seed; the values above are from one local run (illustrative, not a benchmark).

## Testing

```bash
./test.sh
```

The suite checks that the Makefile declares the expected targets, runs the pipeline, and verifies the artifacts appear under `data/`.

## Troubleshooting

- **`venv` or `pip` errors**: confirm `python3 --version` is 3.9 or later and that the `venv` module is available.
- **XGBoost missing**: the pipeline logs a warning and trains the remaining models; install `xgboost` from `requirements.txt` to include it.
- **Pipeline reruns slowly**: use the cache. Only changed stages should execute; `gaffer-exec --workspace-root . run make:train-only` skips data prep entirely.
- **Start over**: run `gaffer-exec --workspace-root . run make:clean` to remove generated data, models, results, and plots.

## Next example

[06-local-dev-environment](../06-local-dev-environment/README.md) orchestrates long-running services, a database, an API, and a frontend, instead of a batch pipeline.
