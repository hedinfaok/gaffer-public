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
	
	// User endpoints
	r.HandleFunc("/users", getUsersHandler).Methods("GET")
	r.HandleFunc("/users/{id}", getUserHandler).Methods("GET")
	r.HandleFunc("/users", createUserHandler).Methods("POST")
	r.HandleFunc("/users/{id}", updateUserHandler).Methods("PUT")
	
	// Service info
	r.HandleFunc("/", infoHandler).Methods("GET")

	port := getEnv("PORT", "8082")
	fmt.Printf("👥 Users service starting on port %s\n", port)
	
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	health := models.ServiceHealth{
		Service:   "users",
		Status:    "healthy",
		Version:   "1.0.0",
		Timestamp: time.Now(),
		Details: map[string]string{
			"total_users":     "1,247",
			"active_sessions": "89",
			"db_connections":  "5/20",
		},
	}
	
	common.WriteSuccess(w, health)
}

func getUsersHandler(w http.ResponseWriter, r *http.Request) {
	users := []models.User{
		{
			ID:        "user-123",
			Username:  "alice",
			Email:     "alice@example.com",
			CreatedAt: time.Now().Add(-7 * 24 * time.Hour),
			UpdatedAt: time.Now().Add(-1 * time.Hour),
		},
		{
			ID:        "user-456",
			Username:  "bob",
			Email:     "bob@example.com",
			CreatedAt: time.Now().Add(-3 * 24 * time.Hour),
			UpdatedAt: time.Now().Add(-2 * time.Hour),
		},
	}
	
	common.WriteSuccess(w, users)
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["id"]
	
	user := models.User{
		ID:        userID,
		Username:  "example-user",
		Email:     "user@example.com",
		CreatedAt: time.Now().Add(-5 * 24 * time.Hour),
		UpdatedAt: time.Now().Add(-30 * time.Minute),
	}
	
	common.WriteSuccess(w, user)
}

func createUserHandler(w http.ResponseWriter, r *http.Request) {
	var user models.User
	json.NewDecoder(r.Body).Decode(&user)
	
	user.ID = fmt.Sprintf("user-%d", time.Now().Unix())
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()
	
	common.WriteSuccess(w, user)
}

func updateUserHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["id"]
	
	var updates map[string]interface{}
	json.NewDecoder(r.Body).Decode(&updates)
	
	response := map[string]interface{}{
		"user_id": userID,
		"updated": updates,
		"message": "User updated successfully",
	}
	
	common.WriteSuccess(w, response)
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	info := map[string]interface{}{
		"service":     "User Management Service",
		"version":     "1.0.0",
		"description": "Manages user profiles and data",
		"endpoints": []string{
			"GET /health",
			"GET /users",
			"GET /users/{id}",
			"POST /users",
			"PUT /users/{id}",
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