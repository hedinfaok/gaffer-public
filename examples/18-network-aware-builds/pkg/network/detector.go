package network

import (
	"fmt"
	"math/rand"
	"time"
)

// DetectLatency simulates latency detection to a cache endpoint
func DetectLatency(endpoint string) int {
	// Simulate actual network ping
	// In a real implementation, this would use ICMP ping or HTTP HEAD requests
	time.Sleep(10 * time.Millisecond)
	
	// Return simulated latency based on endpoint
	switch endpoint {
	case "localhost:4566", "us-east":
		return 50 + rand.Intn(10) // 50-60ms
	case "localhost:4567", "us-west":
		return 100 + rand.Intn(20) // 100-120ms
	case "localhost:4568", "eu-central":
		return 150 + rand.Intn(30) // 150-180ms
	default:
		return 75 + rand.Intn(25)
	}
}

// DetectBandwidth simulates bandwidth detection to a cache endpoint
func DetectBandwidth(endpoint string) float64 {
	// Simulate bandwidth test with small data transfer
	time.Sleep(20 * time.Millisecond)
	
	// Return simulated bandwidth in Mbps
	switch endpoint {
	case "localhost:4566", "us-east":
		return 95.0 + rand.Float64()*10.0 // 95-105 Mbps
	case "localhost:4567", "us-west":
		return 45.0 + rand.Float64()*10.0 // 45-55 Mbps
	case "localhost:4568", "eu-central":
		return 20.0 + rand.Float64()*10.0 // 20-30 Mbps
	default:
		return 50.0 + rand.Float64()*20.0
	}
}

// CalculateScore calculates a composite score for cache selection
// Lower score is better (combines latency and bandwidth)
func CalculateScore(latencyMs int, bandwidthMbps float64) float64 {
	// Normalize and weight: latency is 40%, bandwidth is 60%
	latencyScore := float64(latencyMs) / 10.0          // Normalize
	bandwidthScore := (100.0 - bandwidthMbps) / 10.0   // Invert (higher is worse)
	
	return (latencyScore * 0.4) + (bandwidthScore * 0.6)
}

// CheckHealth checks if a cache endpoint is healthy
func CheckHealth(endpoint string) bool {
	// Simulate health check
	time.Sleep(5 * time.Millisecond)
	
	// Randomly simulate occasional failures (5% failure rate)
	return rand.Float64() > 0.05
}

// EstimateTransferTime estimates transfer time for a given size
func EstimateTransferTime(sizeBytes int64, bandwidthMbps float64) time.Duration {
	// Convert bandwidth to bytes per second
	bytesPerSecond := (bandwidthMbps * 1024 * 1024) / 8
	
	// Calculate time
	seconds := float64(sizeBytes) / bytesPerSecond
	return time.Duration(seconds * float64(time.Second))
}

// ShouldCompress determines if compression should be used based on bandwidth
func ShouldCompress(bandwidthMbps float64) (bool, string) {
	if bandwidthMbps > 100 {
		// High bandwidth: skip compression to save CPU
		return false, "none"
	} else if bandwidthMbps > 50 {
		// Medium bandwidth: use fast compression
		return true, "gzip"
	} else {
		// Low bandwidth: use maximum compression
		return true, "zstd"
	}
}

// SimulateTransfer simulates a network transfer with progress
func SimulateTransfer(sizeBytes int64, bandwidthMbps float64, onProgress func(transferred int64)) error {
	chunkSize := int64(1024 * 1024) // 1MB chunks
	transferred := int64(0)
	
	for transferred < sizeBytes {
		// Simulate chunk transfer
		chunkTime := EstimateTransferTime(chunkSize, bandwidthMbps)
		time.Sleep(chunkTime)
		
		transferred += chunkSize
		if transferred > sizeBytes {
			transferred = sizeBytes
		}
		
		if onProgress != nil {
			onProgress(transferred)
		}
	}
	
	return nil
}

// FormatBytes formats bytes to human readable format
func FormatBytes(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}

// FormatBandwidth formats bandwidth to human readable format
func FormatBandwidth(mbps float64) string {
	if mbps >= 1000 {
		return fmt.Sprintf("%.1f Gbps", mbps/1000)
	}
	return fmt.Sprintf("%.1f Mbps", mbps)
}
