"""
Image classification model
"""
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import joblib


class ImageClassifier:
    """Classifier for image recognition tasks"""
    
    def __init__(self, n_estimators=100):
        """
        Initialize classifier
        
        Args:
            n_estimators: Number of trees in the forest
        """
        self.model = RandomForestClassifier(
            n_estimators=n_estimators,
            random_state=42
        )
        self.labels = ['cats', 'dogs', 'birds', 'fish']
        
    def train(self, X, y):
        """
        Train the classifier
        
        Args:
            X: Training features
            y: Training labels
        """
        self.model.fit(X, y)
        
    def predict(self, X):
        """
        Make predictions
        
        Args:
            X: Features to predict
            
        Returns:
            Predicted labels
        """
        return self.model.predict(X)
    
    def predict_proba(self, X):
        """
        Get prediction probabilities
        
        Args:
            X: Features to predict
            
        Returns:
            Prediction probabilities for each class
        """
        return self.model.predict_proba(X)
    
    def save(self, path):
        """Save model to disk"""
        joblib.dump(self.model, path)
        
    def load(self, path):
        """Load model from disk"""
        self.model = joblib.load(path)
