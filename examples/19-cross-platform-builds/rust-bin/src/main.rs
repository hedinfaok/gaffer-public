use std::env;

fn main() {
    println!("╔════════════════════════════════════════╗");
    println!("║  Cross-Platform Rust Application       ║");
    println!("╚════════════════════════════════════════╝");
    println!();
    
    print_platform_info();
    print_build_info();
    print_platform_features();
    
    println!("\n✓ Rust application executed successfully!");
}

fn print_platform_info() {
    println!("Platform Information:");
    println!("  OS:           {}", env::consts::OS);
    println!("  Architecture: {}", env::consts::ARCH);
    println!("  Family:       {}", env::consts::FAMILY);
    
    #[cfg(target_pointer_width = "64")]
    println!("  Pointer Size: 64-bit");
    
    #[cfg(target_pointer_width = "32")]
    println!("  Pointer Size: 32-bit");
    
    #[cfg(target_endian = "little")]
    println!("  Endianness:   Little-endian");
    
    #[cfg(target_endian = "big")]
    println!("  Endianness:   Big-endian");
}

fn print_build_info() {
    println!("\nBuild Configuration:");
    
    #[cfg(debug_assertions)]
    println!("  Mode:         Debug");
    
    #[cfg(not(debug_assertions))]
    println!("  Mode:         Release");
    
    println!("  Rust Version: {}", env!("CARGO_PKG_VERSION"));
}

fn print_platform_features() {
    println!("\nPlatform-Specific Features:");
    
    #[cfg(target_os = "linux")]
    {
        println!("  - Linux-specific code paths enabled");
        println!("  - POSIX API available");
        println!("  - Native threading support");
    }
    
    #[cfg(target_os = "macos")]
    {
        println!("  - macOS-specific code paths enabled");
        println!("  - Apple frameworks available");
        println!("  - Grand Central Dispatch support");
    }
    
    #[cfg(target_os = "windows")]
    {
        println!("  - Windows-specific code paths enabled");
        println!("  - Windows API available");
        println!("  - MSVC runtime linked");
    }
    
    #[cfg(target_arch = "x86_64")]
    {
        println!("  - x86-64 instruction set");
        println!("  - SSE/AVX optimizations possible");
    }
    
    #[cfg(target_arch = "aarch64")]
    {
        println!("  - ARM64 instruction set");
        println!("  - NEON optimizations possible");
    }
    
    #[cfg(target_env = "gnu")]
    println!("  - GNU environment (glibc)");
    
    #[cfg(target_env = "msvc")]
    println!("  - MSVC environment");
}
