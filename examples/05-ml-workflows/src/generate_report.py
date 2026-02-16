#!/usr/bin/env python3
"""
Generate ML Pipeline Report
Consolidated reporting script to avoid complex shell escaping in graph.json
"""

import json
import os
import sys
from pathlib import Path


def main():
    """Generate a comprehensive ML pipeline report."""
    print('\n🎉 ML Pipeline Completed Successfully!\n')
    
    # Check if directories exist
    models_dir = Path('data/models')
    results_dir = Path('data/results')
    plots_dir = Path('data/plots')
    
    # Report generated models
    print('📊 Generated Models:')
    if models_dir.exists():
        model_files = [f for f in os.listdir(models_dir) if f.endswith('.joblib')]
        if model_files:
            for f in sorted(model_files):
                print(f'   - {f}')
        else:
            print('   - No model files found')
    else:
        print('   - Models directory not found')
    
    # Report results
    print('\n📈 Results:')
    if results_dir.exists():
        result_files = [f for f in os.listdir(results_dir) if f.endswith('.json')]
        if result_files:
            for f in sorted(result_files):
                print(f'   - {f}')
        else:
            print('   - No result files found')
    else:
        print('   - Results directory not found')
    
    # Report summary from evaluation results
    print('\n📋 Summary:')
    if results_dir.exists():
        eval_files = [f for f in os.listdir(results_dir) 
                     if f.startswith('evaluation_') and f.endswith('.json')]
        
        if eval_files:
            for f in sorted(eval_files):
                try:
                    with open(results_dir / f, 'r') as file:
                        data = json.load(file)
                        dataset = data.get('dataset', 'unknown')
                        best_model = data.get('best_model', 'unknown')
                        best_score = data.get('best_score', 'N/A')
                        
                        # Handle the score formatting safely
                        if isinstance(best_score, (int, float)):
                            score_str = f"{best_score:.4f}"
                        else:
                            score_str = str(best_score)
                            
                        print(f'   Dataset: {dataset}, Best Model: {best_model}, Score: {score_str}')
                except Exception as e:
                    print(f'   Error reading {f}: {e}')
        else:
            print('   - No evaluation results found')
    else:
        print('   - Results directory not found')
    
    # Report plots
    print('\n📊 Generated Plots:')
    if plots_dir.exists():
        plot_files = []
        for root, dirs, files in os.walk(plots_dir):
            for file in files:
                if file.endswith(('.png', '.jpg', '.jpeg', '.svg', '.pdf')):
                    rel_path = os.path.relpath(os.path.join(root, file), plots_dir)
                    plot_files.append(rel_path)
        
        if plot_files:
            for f in sorted(plot_files):
                print(f'   - plots/{f}')
        else:
            print('   - No plot files found')
    else:
        print('   - Plots directory not found')
    
    print('\n🔧 Built with: gaffer-exec ML workflow orchestration\n')


if __name__ == '__main__':
    main()