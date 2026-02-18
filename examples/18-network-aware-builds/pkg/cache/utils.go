package cache

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"time"
)

// ComputeChecksum computes SHA256 checksum of a file
func ComputeChecksum(filePath string) (string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return "", err
	}
	defer file.Close()

	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return "", err
	}

	return hex.EncodeToString(hash.Sum(nil)), nil
}

// VerifyChecksum verifies a file against a checksum
func VerifyChecksum(filePath, expectedChecksum string) (bool, error) {
	actualChecksum, err := ComputeChecksum(filePath)
	if err != nil {
		return false, err
	}
	return actualChecksum == expectedChecksum, nil
}

// CacheKey generates a cache key for an artifact
func CacheKey(service, version, platform string) string {
	return fmt.Sprintf("%s/%s/%s", service, version, platform)
}

// IsExpired checks if a cache entry is expired
func IsExpired(timestamp time.Time, ttl time.Duration) bool {
	return time.Since(timestamp) > ttl
}

// CompressRatio calculates compression ratio
func CompressRatio(originalSize, compressedSize int64) float64 {
	if originalSize == 0 {
		return 0
	}
	return float64(compressedSize) / float64(originalSize)
}

// SavingsPercent calculates percentage saved
func SavingsPercent(originalSize, compressedSize int64) float64 {
	if originalSize == 0 {
		return 0
	}
	return (1.0 - CompressRatio(originalSize, compressedSize)) * 100.0
}
