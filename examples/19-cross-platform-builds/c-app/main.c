#include <stdio.h>
#include <string.h>

#ifdef _WIN32
    #define PLATFORM "Windows"
    #define OS_TYPE "windows"
#elif __APPLE__
    #define PLATFORM "macOS"
    #define OS_TYPE "darwin"
#elif __linux__
    #define PLATFORM "Linux"
    #define OS_TYPE "linux"
#else
    #define PLATFORM "Unknown"
    #define OS_TYPE "unknown"
#endif

#ifdef __x86_64__
    #define ARCH "amd64"
#elif __aarch64__ || __ARM_ARCH_8__
    #define ARCH "arm64"
#elif __i386__
    #define ARCH "386"
#else
    #define ARCH "unknown"
#endif

int main() {
    printf("╔════════════════════════════════════════╗\n");
    printf("║  Cross-Platform C Application          ║\n");
    printf("╚════════════════════════════════════════╝\n\n");
    
    printf("Platform Information:\n");
    printf("  OS:           %s\n", PLATFORM);
    printf("  Type:         %s\n", OS_TYPE);
    printf("  Architecture: %s\n", ARCH);
    printf("  Compiler:     ");
    
    #ifdef __clang__
        printf("Clang %d.%d.%d\n", __clang_major__, __clang_minor__, __clang_patchlevel__);
    #elif __GNUC__
        printf("GCC %d.%d.%d\n", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__);
    #elif _MSC_VER
        printf("MSVC %d\n", _MSC_VER);
    #else
        printf("Unknown\n");
    #endif
    
    printf("\nBuild Configuration:\n");
    #ifdef DEBUG
        printf("  Mode:         Debug\n");
    #else
        printf("  Mode:         Release\n");
    #endif
    
    printf("\nPlatform-Specific Features:\n");
    #ifdef _WIN32
        printf("  - Windows API support\n");
        printf("  - MSVC runtime\n");
    #elif __APPLE__
        printf("  - Apple frameworks available\n");
        printf("  - Clang optimizations\n");
    #elif __linux__
        printf("  - POSIX compliance\n");
        printf("  - Linux system calls\n");
    #endif
    
    printf("\n✓ Application running successfully!\n");
    
    return 0;
}
