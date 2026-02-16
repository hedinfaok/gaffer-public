/**
 * Authentication Service
 * Handles user authentication and token management
 */

import { Logger, Config, validateConfig } from '@example/shared-lib';
import { AuthHandler } from './handlers';
import { TokenManager } from './token-manager';

export class AuthService {
  private logger: Logger;
  private config: Config;
  private authHandler: AuthHandler;
  private tokenManager: TokenManager;

  constructor(config: Config) {
    if (!validateConfig(config)) {
      throw new Error('Invalid configuration for AuthService');
    }
    this.config = config;
    this.logger = new Logger(config.serviceName);
    this.authHandler = new AuthHandler(this.logger);
    this.tokenManager = new TokenManager();
  }

  start(): void {
    this.logger.info(`Starting auth service on port ${this.config.port}`);
    this.logger.info(`Environment: ${this.config.environment}`);
  }

  authenticate(username: string, password: string): boolean {
    this.logger.info(`Authentication attempt for user: ${username}`);
    // Simplified auth logic for demonstration
    return username.length > 0 && password.length > 0;
  }

  generateToken(username: string): string {
    return `token_${username}_${Date.now()}`;
  }

  getAuthHandler(): AuthHandler {
    return this.authHandler;
  }

  getTokenManager(): TokenManager {
    return this.tokenManager;
  }
}

// Export handlers and managers
export * from './handlers';
export * from './token-manager';

// Example usage
const config: Config = {
  serviceName: 'auth-service',
  port: 3001,
  environment: 'development'
};

const service = new AuthService(config);
service.start();
