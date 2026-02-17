package handlers

import (
	"encoding/json"
	"net/http"
	"runtime"
	"time"
)

// MetricsResponse represents system metrics
type MetricsResponse struct {
	Uptime        string  `json:"uptime"`
	RequestsTotal int64   `json:"requests_total"`
	MemoryUsageMB float64 `json:"memory_usage_mb"`
	Goroutines    int     `json:"goroutines"`
	CPUCores      int     `json:"cpu_cores"`
}

var (
	startTime     = time.Now()
	requestsTotal int64
)

// MetricsHandler returns system metrics
func MetricsHandler(w http.ResponseWriter, r *http.Request) {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)

	response := MetricsResponse{
		Uptime:        time.Since(startTime).String(),
		RequestsTotal: requestsTotal,
		MemoryUsageMB: float64(m.Alloc) / 1024 / 1024,
		Goroutines:    runtime.NumGoroutine(),
		CPUCores:      runtime.NumCPU(),
	}

	requestsTotal++

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
