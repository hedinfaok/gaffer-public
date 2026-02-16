// Test setup - runs before each test file
// Global test configuration and utilities

// Increase timeout for integration/e2e tests
jest.setTimeout(30000);

// Global test utilities
global.testUtils = {
  // Helper to create mock user data
  createMockUser: (overrides = {}) => ({
    id: Date.now(),
    name: 'Test User',
    email: 'test@example.com',
    phone: '+1234567890',
    ...overrides
  }),
  
  // Helper to create mock calculation data
  createMockCalculation: (operation = 'add', a = 5, b = 3) => ({
    operation,
    a,
    b,
    expectedResult: {
      add: a + b,
      subtract: a - b,
      multiply: a * b,
      divide: a / b
    }[operation]
  }),
  
  // Helper to wait for async operations
  delay: (ms) => new Promise(resolve => setTimeout(resolve, ms)),
  
  // Helper to suppress console output during tests
  suppressConsole: () => {
    jest.spyOn(console, 'log').mockImplementation(() => {});
    jest.spyOn(console, 'warn').mockImplementation(() => {});
    jest.spyOn(console, 'error').mockImplementation(() => {});
  },
  
  // Helper to restore console output
  restoreConsole: () => {
    console.log.mockRestore?.();
    console.warn.mockRestore?.();
    console.error.mockRestore?.();
  }
};

// Global beforeEach - runs before each test
beforeEach(() => {
  // Clear all mocks before each test
  jest.clearAllMocks();
});

// Global afterEach - runs after each test
afterEach(() => {
  // Cleanup any test data
  global.testUtils.restoreConsole();
});

// Handle unhandled promise rejections in tests
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Set up environment variables for testing
process.env.NODE_ENV = 'test';
process.env.PORT = '0'; // Use random available port for testing

console.log('🧪 Test environment initialized');
console.log(`🔧 Node environment: ${process.env.NODE_ENV}`);
console.log(`⚙️  Jest version: ${require('jest/package.json').version}`);