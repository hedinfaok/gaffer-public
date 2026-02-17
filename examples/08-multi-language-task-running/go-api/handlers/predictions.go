package handlers

import (
	"encoding/json"
	"math/rand"
	"net/http"
	"time"
)

// Prediction represents a single prediction
type Prediction struct {
	Label      string  `json:"label"`
	Confidence float64 `json:"confidence"`
}

// PredictionsResponse represents the predictions response
type PredictionsResponse struct {
	Predictions []Prediction `json:"predictions"`
	Count       int          `json:"count"`
	Timestamp   time.Time    `json:"timestamp"`
}

// PredictRequest represents a prediction request
type PredictRequest struct {
	Features []float64 `json:"features"`
}

// PredictionsHandler returns a list of recent predictions
func PredictionsHandler(w http.ResponseWriter, r *http.Request) {
	// Mock predictions for demonstration
	predictions := []Prediction{
		{Label: "cats", Confidence: 0.95},
		{Label: "dogs", Confidence: 0.87},
		{Label: "birds", Confidence: 0.72},
	}

	response := PredictionsResponse{
		Predictions: predictions,
		Count:       len(predictions),
		Timestamp:   time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// PredictHandler handles new prediction requests
func PredictHandler(w http.ResponseWriter, r *http.Request) {
	var req PredictRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Mock prediction logic
	labels := []string{"cats", "dogs", "birds", "fish"}
	prediction := Prediction{
		Label:      labels[rand.Intn(len(labels))],
		Confidence: 0.7 + rand.Float64()*0.3,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(prediction)
}
