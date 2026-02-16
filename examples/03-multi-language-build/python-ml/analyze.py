#!/usr/bin/env python3
"""
Python ML Analysis Component for Multi-Language Application

This script demonstrates:
- Integration with Rust backend API
- Data analysis of API responses
- ML-style processing patterns
- Integration within gaffer-exec polyglot build
"""

import json
import time
import sys
from datetime import datetime
from typing import Dict, Any, List

try:
    import requests
    import numpy as np
    import pandas as pd
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("💡 Run: pip install -r requirements.txt")
    sys.exit(1)

BACKEND_URL = "http://localhost:8080"

def analyze_api_response(data: Dict[str, Any]) -> Dict[str, Any]:
    """Analyze API response data using ML-style processing."""
    
    print("🐍 Python ML - Analyzing API response...")
    
    # Extract metrics
    api_data = data.get('data', {})
    timestamp = data.get('timestamp', time.time())
    
    # Simulate ML analysis
    analysis = {
        'response_analysis': {
            'data_quality_score': np.random.uniform(0.85, 0.98),
            'completeness': len(api_data) / 10.0,  # Assuming 10 expected fields
            'freshness_score': max(0, 1 - (time.time() - timestamp) / 3600),
        },
        'predictions': {
            'next_request_time': timestamp + np.random.exponential(30),
            'load_forecast': np.random.uniform(0.3, 0.8),
            'health_confidence': np.random.uniform(0.9, 0.99),
        },
        'recommendations': []
    }
    
    # Add recommendations based on analysis
    if analysis['response_analysis']['data_quality_score'] > 0.9:
        analysis['recommendations'].append("✅ High data quality - system performing well")
    
    if analysis['response_analysis']['freshness_score'] > 0.8:
        analysis['recommendations'].append("⚡ Data is fresh - real-time processing possible")
        
    if analysis['predictions']['health_confidence'] > 0.95:
        analysis['recommendations'].append("🎯 System health excellent - scale up recommended")
        
    return analysis

def fetch_and_analyze_metrics() -> Dict[str, Any]:
    """Fetch metrics from Rust backend and perform analysis."""
    
    try:
        print(f"🔗 Connecting to Rust backend at {BACKEND_URL}...")
        response = requests.get(f"{BACKEND_URL}/metrics", timeout=5)
        response.raise_for_status()
        
        api_data = response.json()
        print("✅ Successfully fetched metrics from Rust backend")
        
        # Perform ML analysis
        analysis = analyze_api_response(api_data)
        
        return {
            'success': True,
            'raw_data': api_data,
            'ml_analysis': analysis,
            'processed_at': datetime.now().isoformat(),
            'component': 'python-ml',
            'backend_language': api_data.get('language', 'unknown'),
        }
        
    except requests.exceptions.ConnectionError:
        return {
            'success': False,
            'error': 'Backend connection failed',
            'message': 'Rust backend may not be running',
            'suggestion': 'Start backend with: gaffer-exec run rust-backend',
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'component': 'python-ml',
        }

def analyze_build_metrics() -> Dict[str, Any]:
    """Analyze multi-language build performance."""
    
    print("🐍 Python ML - Analyzing build performance...")
    
    # Simulate build metrics analysis
    languages = ['Rust', 'Go', 'Node.js', 'Python']
    build_times = np.random.normal(loc=[3.2, 1.8, 4.5, 2.1], scale=[0.5, 0.3, 0.8, 0.4])
    
    # Create performance DataFrame
    df = pd.DataFrame({
        'language': languages,
        'build_time_seconds': np.maximum(build_times, 0.1),  # No negative times
        'complexity_score': np.random.uniform(0.3, 0.9, len(languages)),
        'cache_hit_rate': np.random.uniform(0.6, 0.95, len(languages)),
    })
    
    # Calculate performance metrics
    total_time = df['build_time_seconds'].sum()
    parallel_time = df['build_time_seconds'].max()  # Max since builds run in parallel
    efficiency = 1 - (parallel_time / total_time)
    
    analysis = {
        'build_performance': {
            'total_sequential_time': round(total_time, 2),
            'parallel_execution_time': round(parallel_time, 2),
            'parallel_efficiency': round(efficiency, 3),
            'time_saved_seconds': round(total_time - parallel_time, 2),
        },
        'language_rankings': df.sort_values('build_time_seconds').to_dict('records'),
        'recommendations': [
            f"🚀 Parallel execution saves {round(total_time - parallel_time, 1)} seconds",
            f"⚡ Best performer: {df.loc[df['build_time_seconds'].idxmin(), 'language']}",
            f"🎯 gaffer-exec efficiency: {round(efficiency * 100, 1)}%",
        ]
    }
    
    return analysis

def display_results(results: Dict[str, Any]) -> None:
    """Pretty print analysis results."""
    
    print("\n" + "="*60)
    print("🐍 PYTHON ML ANALYSIS RESULTS")
    print("="*60)
    
    if not results.get('success', True):
        print(f"❌ Error: {results.get('error', 'Unknown error')}")
        if 'suggestion' in results:
            print(f"💡 Suggestion: {results['suggestion']}")
        return
    
    # API Analysis
    if 'ml_analysis' in results:
        ml = results['ml_analysis']
        print(f"\n🔍 API Response Analysis:")
        print(f"   Data Quality Score: {ml['response_analysis']['data_quality_score']:.3f}")
        print(f"   Freshness Score: {ml['response_analysis']['freshness_score']:.3f}")
        print(f"   Health Confidence: {ml['predictions']['health_confidence']:.3f}")
        
        print(f"\n💡 Recommendations:")
        for rec in ml['recommendations']:
            print(f"   {rec}")
    
    # Build Analysis
    if 'build_performance' in results:
        bp = results['build_performance']
        print(f"\n🏗️  Build Performance Analysis:")
        print(f"   Sequential Time: {bp['total_sequential_time']}s")
        print(f"   Parallel Time: {bp['parallel_execution_time']}s")
        print(f"   Time Saved: {bp['time_saved_seconds']}s")
        print(f"   Efficiency: {bp['parallel_efficiency']*100:.1f}%")
        
        print(f"\n🎯 Build Recommendations:")
        for rec in results['recommendations']:
            print(f"   {rec}")
    
    print(f"\n✅ Analysis completed at {datetime.now().strftime('%H:%M:%S')}")
    print(f"🔧 Built with: gaffer-exec multi-language orchestration")

def main():
    """Main analysis workflow."""
    
    print("🐍 Starting Python ML Analysis Component...")
    print(f"⏰ Timestamp: {datetime.now().isoformat()}")
    
    # Analyze API metrics from Rust backend
    api_results = fetch_and_analyze_metrics()
    
    # Analyze build performance
    build_results = analyze_build_metrics()
    
    # Combine results
    combined_results = {
        **api_results,
        **build_results,
    }
    
    # Display results
    display_results(combined_results)
    
    # Export results for other components
    output_file = "ml_analysis_results.json"
    with open(output_file, 'w') as f:
        json.dump(combined_results, f, indent=2, default=str)
    
    print(f"\n📄 Results exported to: {output_file}")
    
    return 0 if combined_results.get('success', True) else 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)