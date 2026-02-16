package common

import (
	"encoding/json"
	"net/http"
)

// Response represents a standard API response
type Response struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// WriteJSON writes a JSON response
func WriteJSON(w http.ResponseWriter, statusCode int, data interface{}) error {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	return json.NewEncoder(w).Encode(data)
}

// WriteError writes an error response
func WriteError(w http.ResponseWriter, statusCode int, message string) error {
	return WriteJSON(w, statusCode, Response{
		Success: false,
		Error:   message,
	})
}

// WriteSuccess writes a success response
func WriteSuccess(w http.ResponseWriter, data interface{}) error {
	return WriteJSON(w, http.StatusOK, Response{
		Success: true,
		Data:    data,
	})
}