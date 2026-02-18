package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"

	"network-aware-builds/pkg/models"
	"network-aware-builds/pkg/network"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	
	// Health check
	r.HandleFunc("/health", healthHandler).Methods("GET")
	
	// Worker routes
	r.HandleFunc("/api/jobs", listJobsHandler).Methods("GET")
	r.HandleFunc("/api/jobs/{id}", getJobHandler).Methods("GET")
	r.HandleFunc("/api/jobs", createJobHandler).Methods("POST")
	
	// Service info
	r.HandleFunc("/", infoHandler).Methods("GET")

	port := getEnv("PORT", "8081")
	region := getEnv("BUILD_REGION", "us-east-1")
	
	fmt.Printf("🔧 Worker service starting on port %s\n", port)
	fmt.Printf("🌍 Region: %s\n", region)
	
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	health := models.ServiceHealth{
		Service:   "worker",
		Status:    "healthy",
		Version:   "1.0.0",
		Region:    region,
		Timestamp: time.Now(),
		Details: map[string]string{
			"queue_size":     "5",
			"active_jobs":    "2",
			"cache_hits":     "850",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(health)
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	info := map[string]interface{}{
		"service": "Worker Service",
		"version": "1.0.0",
		"region":  region,
		"time":    time.Now(),
		"capabilities": []string{
			"artifact-building",
			"cache-management",
			"network-optimization",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(info)
}

func listJobsHandler(w http.ResponseWriter, r *http.Request) {
	jobs := []map[string]interface{}{
		{
			"id":       "job-001",
			"type":     "build",
			"status":   "completed",
			"artifact": "api",
			"duration": "45s",
			"cached":   true,
		},
		{
			"id":       "job-002",
			"type":     "build",
			"status":   "running",
			"artifact": "worker",
			"progress": "80%",
			"cached":   false,
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(jobs)
}

func getJobHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	region := getEnv("BUILD_REGION", "us-east-1")
	
	job := models.TransferJob{
		ID:           id,
		Artifact:     "test-artifact",
		SourceRegion: region,
		TargetRegion: "us-west",
		TotalSize:    5242880,
		Transferred:  4194304,
		StartTime:    time.Now().Add(-time.Minute),
		Status:       "in_progress",
		Resumable:    true,
		ChunkSize:    1048576,
		CurrentChunk: 4,
		TotalChunks:  5,
		Checksum:     "abc123def456",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(job)
}

func createJobHandler(w http.ResponseWriter, r *http.Request) {
	var req map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	
	region := getEnv("BUILD_REGION", "us-east-1")
	jobID := fmt.Sprintf("job-%03d", rand.Intn(1000))
	
	job := models.TransferJob{
		ID:           jobID,
		Artifact:     req["artifact"].(string),
		SourceRegion: region,
		TargetRegion: req["target_region"].(string),
		TotalSize:    5242880,
		Transferred:  0,
		StartTime:    time.Now(),
		Status:       "started",
		Resumable:    true,
		ChunkSize:    1048576,
		CurrentChunk: 0,
		TotalChunks:  5,
		Checksum:     "",
	}
	
	// Simulate network-aware job creation
	targetBandwidth := network.DetectBandwidth(req["target_region"].(string))
	estimatedTime := network.EstimateTransferTime(job.TotalSize, targetBandwidth)
	shouldCompress, compressionType := network.ShouldCompress(targetBandwidth)
	
	response := map[string]interface{}{
		"job":              job,
		"estimated_time":   estimatedTime.String(),
		"use_compression":  shouldCompress,
		"compression_type": compressionType,
	}
	
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
