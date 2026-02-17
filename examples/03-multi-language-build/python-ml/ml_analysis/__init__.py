"""
Python ML Analysis Package

This package demonstrates proper Python package structure
for integration with gaffer-exec multi-language builds.
"""

from .analyzer import (
    analyze_api_response,
    fetch_and_analyze_metrics,
    analyze_build_metrics,
    display_results,
)

__version__ = "1.0.0"
__all__ = [
    "analyze_api_response",
    "fetch_and_analyze_metrics", 
    "analyze_build_metrics",
    "display_results",
]
