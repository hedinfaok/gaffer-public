package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"network-aware-builds/pkg/models"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	
	// Health check
	r.HandleFunc("/health", healthHandler).Methods("GET")
	
	// Frontend routes
	r.HandleFunc("/", indexHandler).Methods("GET")
	r.HandleFunc("/dashboard", dashboardHandler).Methods("GET")
	r.HandleFunc("/api/stats", statsHandler).Methods("GET")
	
	port := getEnv("PORT", "8082")
	region := getEnv("BUILD_REGION", "us-east-1")
	
	fmt.Printf("🌐 Frontend service starting on port %s\n", port)
	fmt.Printf("🌍 Region: %s\n", region)
	fmt.Printf("📊 Dashboard: http://localhost:%s/dashboard\n", port)
	
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	health := models.ServiceHealth{
		Service:   "frontend",
		Status:    "healthy",
		Version:   "1.0.0",
		Region:    region,
		Timestamp: time.Now(),
		Details: map[string]string{
			"active_users": "42",
			"page_loads":   "1234",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(health)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	region := getEnv("BUILD_REGION", "us-east-1")
	
	html := fmt.Sprintf(`<!DOCTYPE html>
<html>
<head>
    <title>Network-Aware Builds - Frontend</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .region { color: #007bff; font-weight: bold; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 30px; }
        .stat-card { background: #f8f9fa; padding: 20px; border-radius: 4px; border-left: 4px solid #007bff; }
        .stat-value { font-size: 2em; font-weight: bold; color: #333; }
        .stat-label { color: #666; margin-top: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 Network-Aware Builds</h1>
        <p>Frontend Service - Region: <span class="region">%s</span></p>
        <p>This demonstrates intelligent network-aware build orchestration with multi-region caching.</p>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-value">99.9%%</div>
                <div class="stat-label">Cache Hit Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">45s</div>
                <div class="stat-label">Avg Build Time</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">95%%</div>
                <div class="stat-label">Bandwidth Saved</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">3</div>
                <div class="stat-label">Active Regions</div>
            </div>
        </div>
        
        <p style="margin-top: 30px;">
            <a href="/dashboard">View Dashboard →</a>
        </p>
    </div>
</body>
</html>`, region)
	
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(html))
}

func dashboardHandler(w http.ResponseWriter, r *http.Request) {
	html := `<!DOCTYPE html>
<html>
<head>
    <title>Build Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #1e1e1e; color: #fff; }
        .header { background: #2d2d2d; padding: 20px; border-bottom: 2px solid #007bff; }
        .container { padding: 30px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .metric-card { background: #2d2d2d; padding: 20px; border-radius: 8px; border: 1px solid #444; }
        .metric-title { color: #007bff; font-weight: bold; margin-bottom: 10px; }
        .metric-value { font-size: 1.5em; margin: 10px 0; }
        .status-good { color: #28a745; }
        .status-warning { color: #ffc107; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #444; }
        th { background: #2d2d2d; color: #007bff; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 Network-Aware Build Dashboard</h1>
        <p>Real-time monitoring of multi-region build infrastructure</p>
    </div>
    <div class="container">
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-title">🌍 US-East Region</div>
                <div class="metric-value status-good">✅ Healthy</div>
                <div>Latency: 50ms | Bandwidth: 100 Mbps</div>
                <div>Cache Hits: 850 | Availability: 99.9%</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">🌍 US-West Region</div>
                <div class="metric-value status-good">✅ Healthy</div>
                <div>Latency: 100ms | Bandwidth: 50 Mbps</div>
                <div>Cache Hits: 600 | Availability: 99.5%</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">🌍 EU-Central Region</div>
                <div class="metric-value status-warning">⚠️ Degraded</div>
                <div>Latency: 150ms | Bandwidth: 25 Mbps</div>
                <div>Cache Hits: 400 | Availability: 98.8%</div>
            </div>
        </div>
        
        <h2 style="margin-top: 40px;">Recent Builds</h2>
        <table>
            <tr>
                <th>Artifact</th>
                <th>Region</th>
                <th>Duration</th>
                <th>Cached</th>
                <th>Status</th>
            </tr>
            <tr>
                <td>api</td>
                <td>us-east</td>
                <td>8s</td>
                <td>✅ Yes</td>
                <td class="status-good">Success</td>
            </tr>
            <tr>
                <td>worker</td>
                <td>us-east</td>
                <td>7s</td>
                <td>✅ Yes</td>
                <td class="status-good">Success</td>
            </tr>
            <tr>
                <td>frontend</td>
                <td>us-west</td>
                <td>12s</td>
                <td>❌ No</td>
                <td class="status-good">Success</td>
            </tr>
        </table>
    </div>
</body>
</html>`
	
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(html))
}

func statsHandler(w http.ResponseWriter, r *http.Request) {
	stats := map[string]interface{}{
		"total_builds":     1234,
		"cache_hit_rate":   0.85,
		"avg_build_time":   "8.5s",
		"bandwidth_saved":  "95%",
		"active_regions":   3,
		"total_artifacts":  567,
		"last_sync":        time.Now().Add(-time.Minute * 5).Format(time.RFC3339),
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
