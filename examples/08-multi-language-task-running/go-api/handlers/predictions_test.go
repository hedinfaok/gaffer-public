package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPredictionsHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/predictions", nil)
	assert.NoError(t, err)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(PredictionsHandler)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)

	var response PredictionsResponse
	err = json.NewDecoder(rr.Body).Decode(&response)
	assert.NoError(t, err)

	assert.Greater(t, response.Count, 0)
	assert.Len(t, response.Predictions, response.Count)
	assert.NotZero(t, response.Timestamp)
}

func TestPredictHandler(t *testing.T) {
	reqBody := PredictRequest{
		Features: []float64{0.1, 0.2, 0.3, 0.4, 0.5},
	}
	body, err := json.Marshal(reqBody)
	assert.NoError(t, err)

	req, err := http.NewRequest("POST", "/predict", bytes.NewBuffer(body))
	assert.NoError(t, err)
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(PredictHandler)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)

	var response Prediction
	err = json.NewDecoder(rr.Body).Decode(&response)
	assert.NoError(t, err)

	assert.NotEmpty(t, response.Label)
	assert.Greater(t, response.Confidence, 0.0)
	assert.LessOrEqual(t, response.Confidence, 1.0)
}

func TestPredictHandlerInvalidRequest(t *testing.T) {
	req, err := http.NewRequest("POST", "/predict", bytes.NewBuffer([]byte("invalid json")))
	assert.NoError(t, err)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(PredictHandler)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}
