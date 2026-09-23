#!/bin/bash

# ML Workflows Example Test Script
# Tests the complete ML pipeline orchestration with gaffer-exec

set -e

echo "Testing ML Workflows Example..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"
    
    echo -e "\n${BLUE}Test: $test_name${NC}"
    echo "Command: $command"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    # Replace 'python' with 'python3' in commands for better compatibility
    local fixed_command="${command//python /python3 }"
    
    if output=$(eval "$fixed_command" 2>&1); then
        if [[ "$output" =~ $expected_pattern ]]; then
            echo -e "${GREEN}✓ PASS${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ FAIL - Output doesn't match expected pattern${NC}"
            echo "Expected pattern: $expected_pattern"
            echo "Actual output: $output"
        fi
    else
        echo -e "${RED}✗ FAIL - Command failed${NC}"
        echo "Error output: $output"
    fi
}

# Cleanup from any previous runs
echo -e "\n${YELLOW}Cleaning up previous runs...${NC}"
rm -rf data/ || true

# Test 1: Validate Makefile target graph
run_test "Makefile target validation" \
    "python3 -c \"import re; targets=re.findall(r'^([a-zA-Z][a-zA-Z0-9_-]*):', open('Makefile').read(), re.M); print('Valid Makefile with', len(targets), 'targets')\"" \
    "Valid Makefile with [0-9]+ targets"

# Test 2: Check dependencies are installable
run_test "Dependencies installation" \
    "gaffer-exec --workspace-root . run make:setup 2>&1" \
    "Virtual environment created and dependencies installed|Requirement already satisfied"

# Test 3: Run data preparation step
run_test "Data preparation step" \
    "gaffer-exec --workspace-root . run make:data-prep 2>&1" \
    "Data download completed"

# Test 4: Verify datasets were created
run_test "Raw datasets created" \
    "ls data/raw/ | wc -l" \
    "[3-9]"

# Test 5: Check CSV files are valid
run_test "California housing dataset validity" \
    "source venv/bin/activate && python3 -c \"import pandas as pd; df=pd.read_csv('data/raw/california_housing.csv'); print(f'Dataset: {df.shape}')\" 2>&1" \
    "Dataset: \\([0-9]+, [0-9]+\\)"

# Test 6: Run feature engineering
run_test "Feature engineering step" \
    "gaffer-exec --workspace-root . run make:feature-engineering 2>&1" \
    "Feature engineering.*completed"

# Test 7: Check processed data
run_test "Processed datasets created" \
    "ls data/processed/ | grep -c '\\.csv$'" \
    "[3-9]"

# Test 8: Run model training 
run_test "Model training step" \
    "gaffer-exec --workspace-root . run make:train-models 2>&1" \
    "Training.*completed"

# Test 9: Check models were created
run_test "ML models created" \
    "ls data/models/ | grep -c '\\.joblib$'" \
    "[5-9]|1[0-9]"

# Test 10: Verify training results
run_test "Training results generated" \
    "python -c \"import json; r=json.load(open('data/results/training_results_iris.json')); print(f'Trained {r[\\\"models_trained\\\"]} models')\" 2>&1" \
    "Trained [2-9] models"

# Test 11: Run model evaluation
run_test "Model evaluation step" \
    "gaffer-exec --workspace-root . run make:evaluate-models 2>&1" \
    "Evaluation.*completed"

# Test 12: Check evaluation results
run_test "Evaluation results generated" \
    "python3 -c \"import json; r=json.load(open('data/results/evaluation_results_wine.json')); print(f'Evaluated {r[\\\"models_evaluated\\\"]} models, best: {r[\\\"best_model\\\"]}')\" 2>&1" \
    "Evaluated [2-9] models.*best:"

# Test 13: Run complete pipeline
run_test "Complete pipeline execution" \
    "gaffer-exec --workspace-root . run make:pipeline 2>&1" \
    "Complete ML pipeline finished successfully"

# Test 14: Validate pipeline output structure
run_test "Pipeline output validation" \
    "source venv/bin/activate && python3 -c \"
import os, json
models = len([f for f in os.listdir('data/models') if f.endswith('.joblib')])
results = len([f for f in os.listdir('data/results') if f.endswith('.json')])
plots_exist = os.path.exists('data/plots')
print(f'Pipeline output: {models} models, {results} results, plots: {plots_exist}')
\"" \
    "Pipeline output: [5-9]|1[0-9] models, [3-9] results, plots: True"

# Test 15: Check specific model performance
run_test "Model performance validation" \
    "source venv/bin/activate && python3 -c \"
import json
results = json.load(open('data/results/evaluation_results_iris.json'))
accuracy = max([m['accuracy'] for m in results['metrics']])
print(f'Best accuracy: {accuracy:.3f}')
assert accuracy > 0.8, f'Accuracy too low: {accuracy}'
print('✓ Model performance acceptable')
\"" \
    "Model performance acceptable"

# Test 16: Validate data pipeline integrity
run_test "Data pipeline integrity" \
    "source venv/bin/activate && python3 -c \"
import pandas as pd, os
raw_files = [f for f in os.listdir('data/raw') if f.endswith('.csv')]
processed_files = [f for f in os.listdir('data/processed') if f.endswith('.csv')]
print(f'Data integrity: {len(raw_files)} raw → {len(processed_files)} processed')
assert len(raw_files) == len(processed_files), 'Mismatch in data files'
print('✓ Data pipeline integrity verified')
\"" \
    "Data pipeline integrity verified"

# Test 17: Test workflow commands
run_test "Train workflow command" \
    "gaffer-exec --workspace-root . run make:train-only 2>&1" \
    "Training pipeline completed"

# Test 18: Test individual component execution
run_test "Individual component test" \
    "source venv/bin/activate && python3 src/data_prep.py 2>&1" \
    "Data download completed"

# Summary
echo -e "\n${BLUE}=================================="
echo "Test Results Summary"
echo -e "==================================${NC}"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}ALL TESTS PASSED! ($TESTS_PASSED/$TESTS_RUN)${NC}"
    echo -e "\n${GREEN}✓ ML Workflows Example is working correctly!${NC}"
    echo -e "   • Data preparation: Downloads real datasets"
    echo -e "   • Feature engineering: Scikit-learn preprocessing"
    echo -e "   • Model training: Multiple ML algorithms"  
    echo -e "   • Model evaluation: Comprehensive metrics"
    echo -e "   • gaffer-exec orchestration: Full pipeline"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED ($TESTS_PASSED/$TESTS_RUN passed)${NC}"
    echo -e "\n${YELLOW}The ML workflows example has issues that need to be addressed.${NC}"
    exit 1
fi