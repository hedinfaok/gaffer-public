#!/usr/bin/env node

/**
 * Flaky Test Demonstration
 * 
 * This script demonstrates gaffer-exec's advanced retry logic with exponential backoff.
 * It simulates real-world flaky tests that might fail due to:
 * - Network timeouts
 * - Race conditions
 * - External service unavailability
 * - Resource contention
 */

const fs = require('fs');
const path = require('path');

// Simulated test results storage
const resultsFile = path.join(__dirname, '../../.flaky-test-results.json');

// Track retry attempts
let attemptNumber = 0;
const maxAttempts = 5;

// Read previous attempt count if exists
if (fs.existsSync(resultsFile)) {
    try {
        const prevResults = JSON.parse(fs.readFileSync(resultsFile, 'utf8'));
        attemptNumber = (prevResults.attemptNumber || 0) + 1;
    } catch (e) {
        // Ignore parse errors
    }
}

// Configure flakiness - test succeeds on attempt 3 or later
const successThreshold = 3;

console.log(`\n🎲 Flaky Test Suite - Attempt ${attemptNumber + 1}/${maxAttempts}`);
console.log('━'.repeat(60));

// Simulate various flaky test scenarios
const tests = [
    {
        name: 'Network-dependent API call',
        description: 'Simulates intermittent network failure',
        flakyUntilAttempt: 2,
        errorMessage: 'ECONNREFUSED: Connection refused'
    },
    {
        name: 'Race condition test',
        description: 'Simulates timing-dependent test',
        flakyUntilAttempt: 1,
        errorMessage: 'Timeout: Promise did not resolve within 5000ms'
    },
    {
        name: 'External service dependency',
        description: 'Simulates external service unavailability',
        flakyUntilAttempt: 3,
        errorMessage: 'Service temporarily unavailable (503)'
    },
    {
        name: 'Resource contention',
        description: 'Simulates file lock or resource conflict',
        flakyUntilAttempt: 2,
        errorMessage: 'EBUSY: resource busy or locked'
    }
];

const startTime = Date.now();
let passedTests = 0;
let failedTests = 0;
const testResults = [];

// Run simulated tests
tests.forEach(test => {
    const passed = attemptNumber >= test.flakyUntilAttempt;
    
    if (passed) {
        console.log(`✅ ${test.name}`);
        console.log(`   ${test.description}`);
        passedTests++;
        testResults.push({
            name: test.name,
            status: 'PASS',
            attemptSucceeded: attemptNumber + 1
        });
    } else {
        console.log(`❌ ${test.name}`);
        console.log(`   ${test.description}`);
        console.log(`   Error: ${test.errorMessage}`);
        failedTests++;
        testResults.push({
            name: test.name,
            status: 'FAIL',
            error: test.errorMessage,
            currentAttempt: attemptNumber + 1,
            willPassOnAttempt: test.flakyUntilAttempt + 1
        });
    }
    console.log();
});

const executionTime = Date.now() - startTime;

// Save results for next retry
const results = {
    attemptNumber,
    timestamp: new Date().toISOString(),
    passedTests,
    failedTests,
    totalTests: tests.length,
    executionTimeMs: executionTime,
    testResults,
    retryConfig: {
        maxAttempts,
        currentAttempt: attemptNumber + 1,
        willSucceedOn: successThreshold + 1
    }
};

fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));

// Print summary
console.log('━'.repeat(60));
console.log(`📊 Test Results (Attempt ${attemptNumber + 1})`);
console.log(`   Passed: ${passedTests}/${tests.length}`);
console.log(`   Failed: ${failedTests}/${tests.length}`);
console.log(`   Execution Time: ${executionTime}ms`);
console.log();

// Exponential backoff demonstration
if (failedTests > 0) {
    const nextDelay = Math.min(1000 * Math.pow(2, attemptNumber), 10000);
    console.log(`⏱️  Exponential Backoff Configuration:`);
    console.log(`   Initial delay: 1000ms`);
    console.log(`   Current delay: ${nextDelay}ms`);
    console.log(`   Backoff multiplier: 2.0x`);
    console.log(`   Max delay: 10000ms`);
    console.log();
    console.log(`♻️  gaffer-exec will retry with ${nextDelay}ms delay...`);
    console.log(`   Expected to succeed on attempt ${successThreshold + 1}`);
}

// Exit with appropriate code
if (failedTests > 0 && attemptNumber < successThreshold) {
    console.log(`\n⚠️  Tests failed but will pass on retry (designed behavior)\n`);
    process.exit(1);
} else {
    console.log(`\n✅ Flaky tests passed after ${attemptNumber + 1} attempt(s)!\n`);
    
    // Display retry statistics
    if (attemptNumber > 0) {
        console.log(`📈 Retry Statistics:`);
        console.log(`   Total attempts: ${attemptNumber + 1}`);
        console.log(`   First attempt: Failed`);
        console.log(`   Final attempt: Passed`);
        console.log(`   Retry strategy: Exponential backoff`);
        console.log();
    }
    
    process.exit(0);
}
