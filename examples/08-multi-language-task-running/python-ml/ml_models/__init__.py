"""
ML Models package for prediction service
"""
from .classifier import ImageClassifier
from .predictor import PredictionService

__all__ = ['ImageClassifier', 'PredictionService']
__version__ = '1.0.0'
