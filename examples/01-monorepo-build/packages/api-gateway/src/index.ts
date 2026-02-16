/**
 * API Gateway
 * Routes requests to appropriate microservices
 */

import { Logger, Config, validateConfig } from '@example/shared-lib';
import { AuthService } from '@example/auth-service';
import { UserService } from '@example/user-service';

export class APIGateway {
  private logger: Logger;
  private config: Config;
  private authService: AuthService;
  private userService: UserService;

  constructor(config: Config) {
    if (!validateConfig(config)) {
      throw new Error('Invalid configuration for APIGateway');
    }
    this.config = config;
    this.logger = new Logger(config.serviceName);
    
    // Initialize dependent services
    this.authService = new AuthService({
      serviceName: 'auth-service',
      port: 3001,
      environment: config.environment
    });
    
    this.userService = new UserService({
      serviceName: 'user-service',
      port: 3002,
      environment: config.environment
    });
  }

  start(): void {
    this.logger.info(`Starting API gateway on port ${this.config.port}`);
    this.authService.start();
    this.userService.start();
  }

  handleRequest(endpoint: string, data: any): any {
    this.logger.info(`Handling request to ${endpoint}`);
    
    if (endpoint.startsWith('/auth/')) {
      return this.authService;
    } else if (endpoint.startsWith('/users/')) {
      return this.userService;
    }
    
    return { error: 'Unknown endpoint' };
  }
}

// Example usage
const config: Config = {
  serviceName: 'api-gateway',
  port: 3000,
  environment: 'development'
};

const gateway = new APIGateway(config);
gateway.start();
