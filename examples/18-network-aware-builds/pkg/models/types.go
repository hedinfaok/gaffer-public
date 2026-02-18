package models

import "time"

// ServiceHealth represents the health status of a service
type ServiceHealth struct {
	Service   string            `json:"service"`
	Status    string            `json:"status"`
	Version   string            `json:"version"`
	Timestamp time.Time         `json:"timestamp"`
	Region    string            `json:"region,omitempty"`
	Details   map[string]string `json:"details,omitempty"`
}

// BuildArtifact represents a compiled artifact
type BuildArtifact struct {
	Name         string    `json:"name"`
	Size         int64     `json:"size"`
	Checksum     string    `json:"checksum"`
	BuildTime    time.Time `json:"build_time"`
	CachedFrom   string    `json:"cached_from,omitempty"`
	Region       string    `json:"region,omitempty"`
	Compressed   bool      `json:"compressed"`
	CompressionRatio float64 `json:"compression_ratio,omitempty"`
}

// CacheMetrics represents cache performance metrics
type CacheMetrics struct {
	Region        string   `json:"region"`
	Latency       int      `json:"latency_ms"`
	Bandwidth     float64  `json:"bandwidth_mbps"`
	CacheHits     int      `json:"cache_hits"`
	CacheMisses   int      `json:"cache_misses"`
	TotalTransfers int64   `json:"total_bytes_transferred"`
	AvgTransferSpeed float64 `json:"avg_transfer_speed_mbps"`
	Availability  float64  `json:"availability_percent"`
	LastSync      time.Time `json:"last_sync"`
}

// NetworkTopology represents the network layout
type NetworkTopology struct {
	LocalRegion   string                 `json:"local_region"`
	Regions       []RegionInfo           `json:"regions"`
	PrimaryCache  string                 `json:"primary_cache"`
	FallbackCaches []string              `json:"fallback_caches"`
	DetectedAt    time.Time              `json:"detected_at"`
}

// RegionInfo represents information about a cache region
type RegionInfo struct {
	Name      string  `json:"name"`
	Endpoint  string  `json:"endpoint"`
	Latency   int     `json:"latency_ms"`
	Bandwidth float64 `json:"bandwidth_mbps"`
	Score     float64 `json:"score"`
	Healthy   bool    `json:"healthy"`
}

// TransferJob represents an artifact transfer
type TransferJob struct {
	ID            string    `json:"id"`
	Artifact      string    `json:"artifact"`
	SourceRegion  string    `json:"source_region"`
	TargetRegion  string    `json:"target_region"`
	TotalSize     int64     `json:"total_size"`
	Transferred   int64     `json:"transferred"`
	StartTime     time.Time `json:"start_time"`
	Status        string    `json:"status"`
	Resumable     bool      `json:"resumable"`
	ChunkSize     int64     `json:"chunk_size"`
	CurrentChunk  int       `json:"current_chunk"`
	TotalChunks   int       `json:"total_chunks"`
	Checksum      string    `json:"checksum"`
}
