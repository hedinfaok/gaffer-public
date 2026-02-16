package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"distributed-build-example/pkg/common"
	"distributed-build-example/pkg/models"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	
	// Health check
	r.HandleFunc("/health", healthHandler).Methods("GET")
	
	// Auth endpoints
	r.HandleFunc("/login", loginHandler).Methods("POST")
	r.HandleFunc("/logout", logoutHandler).Methods("POST")
	r.HandleFunc("/validate", validateHandler).Methods("POST")
	
	// Service info
	r.HandleFunc("/", infoHandler).Methods("GET")

	port := getEnv("PORT", "8081")
	fmt.Printf("🔐 Auth service starting on port %s\n", port)
	
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	health := models.ServiceHealth{
		Service:   "auth",
		Status:    "healthy",
		Version:   "1.0.0",
		Timestamp: time.Now(),
		Details: map[string]string{
			"active_sessions": "42",
			"token_cache":     "1024 tokens",
			"last_cleanup":    "2m ago",
		},
	}
	
	common.WriteSuccess(w, health)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	// Simulate login
	token := models.AuthToken{
		Token:     "jwt-token-" + fmt.Sprintf("%d", time.Now().Unix()),
		UserID:    "user-123",
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}
	
	common.WriteSuccess(w, token)
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]string{
		"message": "Successfully logged out",
		"status":  "success",
	}
	
	common.WriteSuccess(w, response)
}

func validateHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"valid":   true,
		"user_id": "user-123",
		"expires": time.Now().Add(12 * time.Hour),
	}
	
	common.WriteSuccess(w, response)
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	info := map[string]interface{}{
		"service":     "Authentication Service",
		"version":     "1.0.0",
		"description": "Handles user authentication and authorization",
		"endpoints": []string{
			"GET /health",
			"POST /login",
			"POST /logout", 
			"POST /validate",
		},
		"built_with": "gaffer-exec distributed build",
	}
	
	common.WriteJSON(w, http.StatusOK, info)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}