#!/usr/bin/env python3
"""
Python ML Analysis Component for Multi-Language Application

This script demonstrates:
- Integration with Rust backend API
- Data analysis of API responses
- ML-style processing patterns
- Integration within gaffer-exec polyglot build
- Proper Python package structure with build artifacts
"""

import json
import sys
from datetime import datetime

try:
    from ml_analysis import (
        fetch_and_analyze_metrics,
        analyze_build_metrics,
        display_results,
    )
except ImportError as e:
    print(f"❌ Missing ml_analysis package: {e}")
    print("💡 Run: python3 setup.py build")
    sys.exit(1)

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