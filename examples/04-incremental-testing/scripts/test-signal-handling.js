#!/usr/bin/env node

/**
 * Signal Handling Demonstration
 * 
 * Demonstrates graceful shutdown on SIGINT, SIGTERM
 * Shows proper cleanup of:
 * - Running test processes
 * - Temporary files
 * - Database connections
 * - Open file handles
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🛡️  Signal Handling Demonstration');
console.log('━'.repeat(70));
console.log();

let testProcess = null;
let cleanupDone = false;

// Graceful shutdown handler
async function gracefulShutdown(signal) {
    if (cleanupDone) {
        return;
    }
    
    console.log();
    console.log(`\n⚠️  Received ${signal} - initiating graceful shutdown...`);
    console.log();
    
    cleanupDone = true;
    
    // Step 1: Stop running test processes
    if (testProcess && !testProcess.killed) {
        console.log('1️⃣  Stopping test processes...');
        testProcess.kill('SIGTERM');
        
        // Wait for process to exit
        await new Promise(resolve => {
            testProcess.on('exit', () => {
                console.log('   ✅ Test processes stopped');
                resolve();
            });
            
            // Force kill if not stopped after 5 seconds
            setTimeout(() => {
                if (!testProcess.killed) {
                    console.log('   ⚠️  Force killing unresponsive process');
                    testProcess.kill('SIGKILL');
                }
                resolve();
            }, 5000);
        });
    }
    
    // Step 2: Save partial test results
    console.log('2️⃣  Saving partial test results...');
    const partialResults = {
        interrupted: true,
        signal,
        timestamp: new Date().toISOString(),
        message: 'Tests interrupted by user - partial results saved'
    };
    
    const resultsPath = path.join(__dirname, '../.interrupted-test-results.json');
    try {
        fs.writeFileSync(resultsPath, JSON.stringify(partialResults, null, 2));
        console.log('   ✅ Partial results saved');
    } catch (e) {
        console.log('   ⚠️  Could not save partial results');
    }
    
    // Step 3: Clean up temporary files
    console.log('3️⃣  Cleaning up temporary files...');
    const tempFiles = [
        path.join(__dirname, '../.temp-test-data.json'),
        path.join(__dirname, '../.test-lock')
    ];
    
    tempFiles.forEach(file => {
        try {
            if (fs.existsSync(file)) {
                fs.unlinkSync(file);
            }
        } catch (e) {
            // Ignore cleanup errors
        }
    });
    console.log('   ✅ Temporary files cleaned');
    
    // Step 4: Close database connections (simulated)
    console.log('4️⃣  Closing database connections...');
    await new Promise(resolve => setTimeout(resolve, 100)); // Simulate async cleanup
    console.log('   ✅ Database connections closed');
    
    // Step 5: Final cleanup
    console.log('5️⃣  Finalizing cleanup...');
    console.log('   ✅ All resources released');
    
    console.log();
    console.log('━'.repeat(70));
    console.log('✅ Graceful shutdown completed successfully!');
    console.log();
    console.log('📊 Cleanup Summary:');
    console.log(`   • Test processes: Stopped`);
    console.log(`   • Partial results: Saved`);
    console.log(`   • Temporary files: Cleaned`);
    console.log(`   • Database connections: Closed`);
    console.log(`   • Exit code: 0 (clean exit)`);
    console.log();
    
    process.exit(0);
}

// Register signal handlers
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

// Unhandled errors
process.on('uncaughtException', (error) => {
    console.error('\n❌ Uncaught Exception:', error.message);
    gracefulShutdown('EXCEPTION');
});

process.on('unhandledRejection', (reason) => {
    console.error('\n❌ Unhandled Rejection:', reason);
    gracefulShutdown('REJECTION');
});

console.log('✅ Signal handlers registered:');
console.log('   • SIGINT (Ctrl+C)');
console.log('   • SIGTERM (kill command)');
console.log('   • Uncaught exceptions');
console.log('   • Unhandled promise rejections');
console.log();

// Simulate a long-running test
console.log('🧪 Starting simulated long-running test...');
console.log('   Press Ctrl+C to trigger graceful shutdown');
console.log();

let seconds = 0;
const maxSeconds = 10;

const interval = setInterval(() => {
    seconds++;
    console.log(`⏱️  Test running... ${seconds}s / ${maxSeconds}s`);
    
    if (seconds >= maxSeconds) {
        clearInterval(interval);
        console.log();
        console.log('✅ Test completed normally (no interruption)');
        console.log();
        process.exit(0);
    }
}, 1000);

// Simulate test process
testProcess = {
    killed: false,
    kill: (signal) => {
        testProcess.killed = true;
        clearInterval(interval);
        // Simulate async cleanup
        setTimeout(() => {
            if (testProcess.exitCallback) {
                testProcess.exitCallback();
            }
        }, 500);
    },
    on: (event, callback) => {
        if (event === 'exit') {
            testProcess.exitCallback = callback;
        }
    }
};

// Keep process alive
process.stdin.resume();
