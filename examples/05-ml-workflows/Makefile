# ML Workflows Pipeline Orchestration
#
# Task graph for the machine learning pipeline. gaffer-exec reads this Makefile
# and runs the targets with dependency-aware parallelism and caching:
#
#   gaffer-exec --workspace-root . run make:pipeline
#
# The same targets also work with plain make:
#
#   make pipeline

.PHONY: setup data-prep feature-engineering train-models evaluate-models report pipeline train-only clean

.DEFAULT_GOAL := pipeline

# Create the virtual environment and install dependencies
setup:
	@python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && echo 'Virtual environment created and dependencies installed'

# Download and preprocess the raw datasets
data-prep: setup
	@source venv/bin/activate && python3 src/data_prep.py

# Extract and engineer features
feature-engineering: data-prep
	@source venv/bin/activate && python3 src/feature_engineering.py

# Train the model candidates
train-models: feature-engineering
	@source venv/bin/activate && python3 src/train_model.py

# Evaluate and compare trained models
evaluate-models: train-models
	@source venv/bin/activate && python3 src/evaluate_model.py

# Generate the consolidated pipeline report
report: evaluate-models
	@source venv/bin/activate && python3 src/generate_report.py

# Full pipeline entry point
pipeline: report
	@echo '✓ Complete ML pipeline finished successfully'

# Training-only workflow (training through reporting)
train-only: train-models evaluate-models report
	@echo '✓ Training pipeline completed'

# Remove generated data and model artifacts
clean:
	@rm -rf data/raw data/processed data/models data/results data/plots
