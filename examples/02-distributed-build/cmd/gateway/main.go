package main

import (
	"encoding/json"
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
	
	// Gateway routes - proxy to other services
	r.HandleFunc("/api/auth/{path:.*}", authProxyHandler).Methods("GET", "POST", "PUT", "DELETE")
	r.HandleFunc("/api/users/{path:.*}", usersProxyHandler).Methods("GET", "POST", "PUT", "DELETE")
	
	// Service info
	r.HandleFunc("/", infoHandler).Methods("GET")

	port := getEnv("PORT", "8080")
	fmt.Printf("🚪 Gateway service starting on port %s\n", port)
	fmt.Printf("🔗 Proxying:\n")
	fmt.Printf("   - /api/auth/* -> auth-service:8081\n")
	fmt.Printf("   - /api/users/* -> users-service:8082\n")
	
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	health := models.ServiceHealth{
		Service:   "gateway",
		Status:    "healthy",
		Version:   "1.0.0",
		Timestamp: time.Now(),
		Details: map[string]string{
			"uptime":     "5m",
			"goroutines": "12",
			"memory":     "45MB",
		},
	}
	
	common.WriteSuccess(w, health)
}

func authProxyHandler(w http.ResponseWriter, r *http.Request) {
	// In real implementation, this would proxy to auth service
	response := map[string]interface{}{
		"proxied_to": "auth-service:8081",
		"method":     r.Method,
		"path":       r.URL.Path,
		"message":    "This would be proxied to the auth service",
	}
	
	common.WriteSuccess(w, response)
}

func usersProxyHandler(w http.ResponseWriter, r *http.Request) {
	// In real implementation, this would proxy to users service
	response := map[string]interface{}{
		"proxied_to": "users-service:8082",
		"method":     r.Method,
		"path":       r.URL.Path,
		"message":    "This would be proxied to the users service",
	}
	
	common.WriteSuccess(w, response)
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	info := map[string]interface{}{
		"service":     "API Gateway",
		"version":     "1.0.0",
		"description": "Routes requests to microservices",
		"endpoints": []string{
			"GET /health",
			"* /api/auth/*",
			"* /api/users/*",
		},
		"built_with": "gaffer-exec distributed build",
	}
	
	json.NewEncoder(w).Encode(info)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}