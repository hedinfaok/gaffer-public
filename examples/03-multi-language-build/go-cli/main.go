package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/spf13/cobra"
)

type ApiResponse struct {
	Success   bool            `json:"success"`
	Data      json.RawMessage `json:"data"`
	Timestamp int64           `json:"timestamp"`
	Language  string          `json:"language"`
}

type HealthStatus struct {
	Status    string    `json:"status"`
	Version   string    `json:"version"`
	Uptime    string    `json:"uptime"`
	BuildInfo BuildInfo `json:"build_info"`
}

type BuildInfo struct {
	BuiltWith    string   `json:"built_with"`
	Orchestrator string   `json:"orchestrator"`
	Languages    []string `json:"languages"`
}

type MetricsData struct {
	RequestsServed      int64    `json:"requests_served"`
	LanguagesIntegrated int      `json:"languages_integrated"`
	BuildTimeSeconds    float32  `json:"build_time_seconds"`
	Components          []string `json:"components"`
}

const backendURL = "http://localhost:8080"

var rootCmd = &cobra.Command{
	Use:   "multi-cli",
	Short: "Go CLI for multi-language application",
	Long:  `A command-line interface for the multi-language polyglot application.`,
}

var healthCmd = &cobra.Command{
	Use:   "health",
	Short: "Check backend health",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("🐹 Go CLI - Checking backend health...")
		
		resp, err := http.Get(backendURL + "/health")
		if err != nil {
			log.Printf("❌ Failed to connect to backend: %v", err)
			return
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("❌ Failed to read response: %v", err)
			return
		}

		var apiResp ApiResponse
		if err := json.Unmarshal(body, &apiResp); err != nil {
			log.Printf("❌ Failed to parse JSON: %v", err)
			return
		}

		var health HealthStatus
		if err := json.Unmarshal(apiResp.Data, &health); err != nil {
			log.Printf("❌ Failed to parse health data: %v", err)
			return
		}

		fmt.Printf("✅ Backend Status: %s\n", health.Status)
		fmt.Printf("📦 Version: %s\n", health.Version)
		fmt.Printf("⏱️  Uptime: %s\n", health.Uptime)
		fmt.Printf("🔧 Built with: %s\n", health.BuildInfo.BuiltWith)
		fmt.Printf("🚀 Languages: %v\n", health.BuildInfo.Languages)
	},
}

var metricsCmd = &cobra.Command{
	Use:   "metrics",
	Short: "Get application metrics",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("🐹 Go CLI - Fetching metrics...")
		
		resp, err := http.Get(backendURL + "/metrics")
		if err != nil {
			log.Printf("❌ Failed to connect to backend: %v", err)
			return
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("❌ Failed to read response: %v", err)
			return
		}

		var apiResp ApiResponse
		if err := json.Unmarshal(body, &apiResp); err != nil {
			log.Printf("❌ Failed to parse JSON: %v", err)
			return
		}

		var metrics MetricsData
		if err := json.Unmarshal(apiResp.Data, &metrics); err != nil {
			log.Printf("❌ Failed to parse metrics data: %v", err)
			return
		}

		fmt.Printf("📊 Application Metrics:\n")
		fmt.Printf("   📈 Requests Served: %d\n", metrics.RequestsServed)
		fmt.Printf("   🗣️  Languages Integrated: %d\n", metrics.LanguagesIntegrated)
		fmt.Printf("   ⚡ Build Time: %.2f seconds\n", metrics.BuildTimeSeconds)
		fmt.Printf("   🧩 Components: %v\n", metrics.Components)
	},
}

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "Full system status",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("🐹 Go CLI - Getting full system status...")
		fmt.Println()
		
		// Check health
		fmt.Println("🔍 Health Check:")
		healthCmd.Run(cmd, args)
		
		fmt.Println()
		
		// Get metrics
		fmt.Println("📊 System Metrics:")
		metricsCmd.Run(cmd, args)
		
		fmt.Println()
		fmt.Printf("🎯 CLI built with: gaffer-exec multi-language build\n")
		fmt.Printf("⏰ Timestamp: %s\n", time.Now().Format(time.RFC3339))
	},
}

func main() {
	rootCmd.AddCommand(healthCmd)
	rootCmd.AddCommand(metricsCmd)
	rootCmd.AddCommand(statusCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}