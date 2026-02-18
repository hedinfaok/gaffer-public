#!/usr/bin/env node

const os = require('os');
const process = require('process');

console.log('╔════════════════════════════════════════╗');
console.log('║  Cross-Platform Node.js Application    ║');
console.log('╚════════════════════════════════════════╝');
console.log();

printPlatformInfo();
printRuntimeInfo();
printPlatformFeatures();

console.log('\n✓ Node.js application executed successfully!');

function printPlatformInfo() {
    console.log('Platform Information:');
    console.log(`  OS:           ${os.type()}`);
    console.log(`  Platform:     ${os.platform()}`);
    console.log(`  Architecture: ${os.arch()}`);
    console.log(`  Release:      ${os.release()}`);
    console.log(`  Node Version: ${process.version}`);
}

function printRuntimeInfo() {
    console.log('\nRuntime Information:');
    console.log(`  CPUs:         ${os.cpus().length}`);
    console.log(`  Total Memory: ${Math.round(os.totalmem() / 1024 / 1024 / 1024)}GB`);
    console.log(`  Free Memory:  ${Math.round(os.freemem() / 1024 / 1024 / 1024)}GB`);
    console.log(`  Uptime:       ${Math.round(os.uptime() / 3600)}h`);
}

function printPlatformFeatures() {
    console.log('\nPlatform-Specific Features:');
    
    const platform = os.platform();
    const arch = os.arch();
    
    switch (platform) {
        case 'win32':
            console.log('  - Windows platform detected');
            console.log('  - Native modules built with MSVC');
            console.log('  - Windows-specific APIs available');
            console.log('  - Path separator: \\');
            break;
        case 'darwin':
            console.log('  - macOS platform detected');
            console.log('  - Native modules built with Clang');
            console.log('  - FSEvents for file watching');
            console.log('  - Path separator: /');
            break;
        case 'linux':
            console.log('  - Linux platform detected');
            console.log('  - Native modules built with GCC');
            console.log('  - inotify for file watching');
            console.log('  - Path separator: /');
            break;
        default:
            console.log(`  - Platform: ${platform}`);
    }
    
    switch (arch) {
        case 'x64':
            console.log('  - 64-bit x86 architecture');
            console.log('  - V8 optimizations for x64');
            break;
        case 'arm64':
            console.log('  - 64-bit ARM architecture');
            console.log('  - V8 optimizations for ARM64');
            break;
        case 'ia32':
            console.log('  - 32-bit x86 architecture');
            break;
        default:
            console.log(`  - Architecture: ${arch}`);
    }
    
    console.log(`\nHome Directory: ${os.homedir()}`);
    console.log(`Temp Directory: ${os.tmpdir()}`);
}
