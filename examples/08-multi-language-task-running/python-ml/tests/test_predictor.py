"""
Tests for PredictionService
"""
import numpy as np
import pytest
from ml_models.predictor import PredictionService


class TestPredictionService:
    """Test suite for PredictionService"""
    
    def test_initialization(self):
        """Test service initialization"""
        service = PredictionService()
        assert service.classifier is not None
        
    def test_get_predictions(self):
        """Test getting predictions"""
        service = PredictionService()
        
        # Train with dummy data
        X_train = np.random.rand(100, 10)
        y_train = np.random.randint(0, 4, 100)
        service.classifier.train(X_train, y_train)
        
        # Get predictions
        X_test = np.random.rand(3, 10)
        predictions = service.get_predictions(X_test, top_k=2)
        
        assert len(predictions) == 3
        for pred_list in predictions:
            assert len(pred_list) == 2
            for label, confidence in pred_list:
                assert label in service.classifier.labels
                assert 0 <= confidence <= 1
                
    def test_batch_predict(self):
        """Test batch prediction"""
        service = PredictionService()
        
        # Train with dummy data
        X_train = np.random.rand(100, 10)
        y_train = np.random.randint(0, 4, 100)
        service.classifier.train(X_train, y_train)
        
        # Batch predict
        batch = [np.random.rand(2, 10), np.random.rand(3, 10)]
        results = service.batch_predict(batch)
        
        assert len(results) == 2
        assert len(results[0]) == 2  # First batch has 2 samples
        assert len(results[1]) == 3  # Second batch has 3 samples
