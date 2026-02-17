package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/example/prediction-api/handlers"
	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()

	// Health check endpoint
	r.HandleFunc("/health", handlers.HealthHandler).Methods("GET")

	// Predictions endpoint
	r.HandleFunc("/predictions", handlers.PredictionsHandler).Methods("GET")
	r.HandleFunc("/predict", handlers.PredictHandler).Methods("POST")

	// Metrics endpoint
	r.HandleFunc("/metrics", handlers.MetricsHandler).Methods("GET")

	// CORS middleware
	r.Use(corsMiddleware)

	// Logging middleware
	r.Use(loggingMiddleware)

	port := ":8080"
	log.Printf("Starting API server on %s", port)
	if err := http.ListenAndServe(port, r); err != nil {
		log.Fatal(err)
	}
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
	})
}

// Response represents a standard API response
type Response struct {
	Status  string      `json:"status"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Message string      `json:"message,omitempty"`
}

// WriteJSON writes a JSON response
func WriteJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Error encoding JSON: %v", err)
	}
}

// WriteError writes an error response
func WriteError(w http.ResponseWriter, status int, message string) {
	resp := Response{
		Status: "error",
		Error:  message,
	}
	WriteJSON(w, status, resp)
}
