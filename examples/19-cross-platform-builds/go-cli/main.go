package main

import (
	"fmt"
	"runtime"
	"time"
)

func main() {
	fmt.Println("╔════════════════════════════════════════╗")
	fmt.Println("║  Cross-Platform Go CLI Tool            ║")
	fmt.Println("╚════════════════════════════════════════╝")
	fmt.Println()

	printPlatformInfo()
	printRuntimeInfo()
	printPlatformFeatures()
	
	fmt.Println("\n✓ CLI tool executed successfully!")
}

func printPlatformInfo() {
	fmt.Println("Platform Information:")
	fmt.Printf("  OS:           %s\n", runtime.GOOS)
	fmt.Printf("  Architecture: %s\n", runtime.GOARCH)
	fmt.Printf("  Compiler:     %s\n", runtime.Compiler)
	fmt.Printf("  Go Version:   %s\n", runtime.Version())
}

func printRuntimeInfo() {
	fmt.Println("\nRuntime Information:")
	fmt.Printf("  CPUs:         %d\n", runtime.NumCPU())
	fmt.Printf("  Goroutines:   %d\n", runtime.NumGoroutine())
	fmt.Printf("  CGO Enabled:  %t\n", runtime.GOOS != "js")
}

func printPlatformFeatures() {
	fmt.Println("\nPlatform-Specific Features:")
	
	switch runtime.GOOS {
	case "windows":
		fmt.Println("  - Windows system calls available")
		fmt.Println("  - Native .exe binary format")
		fmt.Println("  - Windows service support")
	case "darwin":
		fmt.Println("  - macOS system calls available")
		fmt.Println("  - Mach-O binary format")
		fmt.Println("  - Native macOS integration")
	case "linux":
		fmt.Println("  - Linux system calls available")
		fmt.Println("  - ELF binary format")
		fmt.Println("  - Systemd integration")
	default:
		fmt.Printf("  - Platform: %s\n", runtime.GOOS)
	}
	
	switch runtime.GOARCH {
	case "amd64":
		fmt.Println("  - 64-bit x86 architecture")
		fmt.Println("  - SSE/AVX optimizations available")
	case "arm64":
		fmt.Println("  - 64-bit ARM architecture")
		fmt.Println("  - NEON optimizations available")
	case "386":
		fmt.Println("  - 32-bit x86 architecture")
	default:
		fmt.Printf("  - Architecture: %s\n", runtime.GOARCH)
	}
	
	fmt.Printf("\nBuild Time: %s\n", time.Now().Format(time.RFC3339))
}
