package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"network-aware-builds/pkg/models"
	"network-aware-builds/pkg/network"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	requestCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "api_requests_total",
			Help: "Total number of API requests",
		},
		[]string{"method", "endpoint"},
	)
	
	responseTime = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name: "api_response_time_seconds",
			Help: "API response time in seconds",
		},
		[]string{"method", "endpoint"},
	)
)

func init() {
	prometheus.MustRegister(requestCounter)
	prometheus.MustRegister(responseTime)
}

func main() {
	r := mux.NewRouter()
	
	// Health check
	r.HandleFunc("/health", healthHandler).Methods("GET")
	
	// API routes
	r.HandleFunc("/api/artifacts", listArtifactsHandler).Methods("GET")
	r.HandleFunc("/api/artifacts/{id}", getArtifactHandler).Methods("GET")
	r.HandleFunc("/api/network/topology", networkTopologyHandler).Methods("GET")
	r.HandleFunc("/api/network/metrics", networkMetricsHandler).Methods("GET")
	
	// Service info
	r.HandleFunc("/", infoHandler).Methods("GET")
	
	// Prometheus metrics
	r.Handle("/metrics", promhttp.Handler())

	port := getEnv("PORT", "8080")
	region := getEnv("BUILD_REGION", "us-east-1")
	
	fmt.Printf("🚀 API service starting on port %s\n", port)
	fmt.Printf("🌍 Region: %s\n", region)
	fmt.Printf("📊 Metrics: http://localhost:%s/metrics\n", port)
	
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	health := models.ServiceHealth{
		Service:   "api",
		Status:    "healthy",
		Version:   "1.0.0",
		Region:    region,
		Timestamp: time.Now(),
		Details: map[string]string{
			"uptime": "running",
			"cache":  "connected",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(health)
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	info := map[string]interface{}{
		"service": "API Service",
		"version": "1.0.0",
		"region":  region,
		"time":    time.Now(),
		"endpoints": []string{
			"/health",
			"/api/artifacts",
			"/api/network/topology",
			"/api/network/metrics",
			"/metrics",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(info)
}

func listArtifactsHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	defer func() {
		responseTime.WithLabelValues(r.Method, "/api/artifacts").Observe(time.Since(start).Seconds())
	}()
	requestCounter.WithLabelValues(r.Method, "/api/artifacts").Inc()
	
	region := getEnv("BUILD_REGION", "us-east-1")
	
	artifacts := []models.BuildArtifact{
		{
			Name:             "api",
			Size:             5242880,
			Checksum:         "abc123def456",
			BuildTime:        time.Now().Add(-time.Hour),
			CachedFrom:       region,
			Region:           region,
			Compressed:       true,
			CompressionRatio: 0.45,
		},
		{
			Name:             "worker",
			Size:             3145728,
			Checksum:         "def789ghi012",
			BuildTime:        time.Now().Add(-time.Hour),
			CachedFrom:       region,
			Region:           region,
			Compressed:       true,
			CompressionRatio: 0.50,
		},
		{
			Name:             "frontend",
			Size:             7340032,
			Checksum:         "ghi345jkl678",
			BuildTime:        time.Now().Add(-time.Hour),
			CachedFrom:       region,
			Region:           region,
			Compressed:       true,
			CompressionRatio: 0.35,
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(artifacts)
}

func getArtifactHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	region := getEnv("BUILD_REGION", "us-east-1")
	
	artifact := models.BuildArtifact{
		Name:             id,
		Size:             5242880,
		Checksum:         "abc123def456",
		BuildTime:        time.Now().Add(-time.Hour),
		CachedFrom:       region,
		Region:           region,
		Compressed:       true,
		CompressionRatio: 0.45,
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(artifact)
}

func networkTopologyHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	// Detect network topology
	regions := []models.RegionInfo{
		{
			Name:      "us-east",
			Endpoint:  "localhost:4566",
			Latency:   network.DetectLatency("us-east"),
			Bandwidth: network.DetectBandwidth("us-east"),
			Healthy:   network.CheckHealth("us-east"),
		},
		{
			Name:      "us-west",
			Endpoint:  "localhost:4567",
			Latency:   network.DetectLatency("us-west"),
			Bandwidth: network.DetectBandwidth("us-west"),
			Healthy:   network.CheckHealth("us-west"),
		},
		{
			Name:      "eu-central",
			Endpoint:  "localhost:4568",
			Latency:   network.DetectLatency("eu-central"),
			Bandwidth: network.DetectBandwidth("eu-central"),
			Healthy:   network.CheckHealth("eu-central"),
		},
	}
	
	// Calculate scores and find primary
	var primaryCache string
	bestScore := 1000.0
	for i := range regions {
		regions[i].Score = network.CalculateScore(regions[i].Latency, regions[i].Bandwidth)
		if regions[i].Healthy && regions[i].Score < bestScore {
			bestScore = regions[i].Score
			primaryCache = regions[i].Name
		}
	}
	
	topology := models.NetworkTopology{
		LocalRegion:    region,
		Regions:        regions,
		PrimaryCache:   primaryCache,
		FallbackCaches: []string{"us-west", "eu-central"},
		DetectedAt:     time.Now(),
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(topology)
}

func networkMetricsHandler(w http.ResponseWriter, r *http.Request) {
	metrics := []models.CacheMetrics{
		{
			Region:           "us-east",
			Latency:          network.DetectLatency("us-east"),
			Bandwidth:        network.DetectBandwidth("us-east"),
			CacheHits:        850,
			CacheMisses:      150,
			TotalTransfers:   524288000,
			AvgTransferSpeed: 95.5,
			Availability:     99.9,
			LastSync:         time.Now().Add(-time.Minute * 5),
		},
		{
			Region:           "us-west",
			Latency:          network.DetectLatency("us-west"),
			Bandwidth:        network.DetectBandwidth("us-west"),
			CacheHits:        600,
			CacheMisses:      400,
			TotalTransfers:   314572800,
			AvgTransferSpeed: 48.2,
			Availability:     99.5,
			LastSync:         time.Now().Add(-time.Minute * 10),
		},
		{
			Region:           "eu-central",
			Latency:          network.DetectLatency("eu-central"),
			Bandwidth:        network.DetectBandwidth("eu-central"),
			CacheHits:        400,
			CacheMisses:      600,
			TotalTransfers:   209715200,
			AvgTransferSpeed: 22.5,
			Availability:     98.8,
			LastSync:         time.Now().Add(-time.Minute * 15),
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metrics)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
