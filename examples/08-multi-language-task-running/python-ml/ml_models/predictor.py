"""
Prediction service for serving model predictions
"""
import numpy as np
from .classifier import ImageClassifier


class PredictionService:
    """Service for making predictions with trained models"""
    
    def __init__(self, model_path=None):
        """
        Initialize prediction service
        
        Args:
            model_path: Path to saved model (optional)
        """
        self.classifier = ImageClassifier()
        if model_path:
            self.classifier.load(model_path)
    
    def get_predictions(self, features, top_k=3):
        """
        Get top-k predictions with confidence scores
        
        Args:
            features: Input features
            top_k: Number of top predictions to return
            
        Returns:
            List of (label, confidence) tuples
        """
        probas = self.classifier.predict_proba(features)
        results = []
        
        for proba in probas:
            # Get indices of top-k predictions
            top_indices = np.argsort(proba)[-top_k:][::-1]
            predictions = [
                (self.classifier.labels[idx], float(proba[idx]))
                for idx in top_indices
            ]
            results.append(predictions)
            
        return results
    
    def batch_predict(self, batch_features):
        """
        Make predictions for a batch of features
        
        Args:
            batch_features: List of feature arrays
            
        Returns:
            List of predictions
        """
        return [
            self.get_predictions(features)
            for features in batch_features
        ]
