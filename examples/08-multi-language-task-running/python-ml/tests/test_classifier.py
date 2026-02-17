"""
Tests for ImageClassifier
"""
import numpy as np
import pytest
from ml_models.classifier import ImageClassifier


class TestImageClassifier:
    """Test suite for ImageClassifier"""
    
    def test_initialization(self):
        """Test classifier initialization"""
        classifier = ImageClassifier(n_estimators=50)
        assert classifier.model.n_estimators == 50
        assert len(classifier.labels) == 4
        
    def test_train_predict(self):
        """Test training and prediction"""
        classifier = ImageClassifier()
        
        # Create dummy training data
        X_train = np.random.rand(100, 10)
        y_train = np.random.randint(0, 4, 100)
        
        # Train model
        classifier.train(X_train, y_train)
        
        # Make predictions
        X_test = np.random.rand(10, 10)
        predictions = classifier.predict(X_test)
        
        assert len(predictions) == 10
        assert all(0 <= p < 4 for p in predictions)
        
    def test_predict_proba(self):
        """Test probability predictions"""
        classifier = ImageClassifier()
        
        # Create dummy training data
        X_train = np.random.rand(100, 10)
        y_train = np.random.randint(0, 4, 100)
        
        classifier.train(X_train, y_train)
        
        X_test = np.random.rand(5, 10)
        probas = classifier.predict_proba(X_test)
        
        assert probas.shape == (5, 4)
        # Check probabilities sum to 1
        assert np.allclose(probas.sum(axis=1), 1.0)
        
    def test_labels(self):
        """Test label definitions"""
        classifier = ImageClassifier()
        expected_labels = ['cats', 'dogs', 'birds', 'fish']
        assert classifier.labels == expected_labels
