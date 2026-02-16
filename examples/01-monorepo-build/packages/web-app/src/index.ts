/**
 * Web Application
 * Frontend application that consumes the API gateway
 */

import { Logger, Config, validateConfig } from '@example/shared-lib';
import { APIGateway } from '@example/api-gateway';

export class WebApp {
  private logger: Logger;
  private config: Config;
  private apiGateway: APIGateway;

  constructor(config: Config) {
    if (!validateConfig(config)) {
      throw new Error('Invalid configuration for WebApp');
    }
    this.config = config;
    this.logger = new Logger(config.serviceName);
    
    // Connect to API Gateway
    this.apiGateway = new APIGateway({
      serviceName: 'api-gateway',
      port: 3000,
      environment: config.environment
    });
  }

  start(): void {
    this.logger.info(`Starting web app on port ${this.config.port}`);
    this.apiGateway.start();
    this.renderHomePage();
  }

  private renderHomePage(): void {
    this.logger.info('Rendering home page');
    console.log('='.repeat(50));
    console.log('Welcome to the Monorepo Example Web App');
    console.log('='.repeat(50));
    console.log('This app demonstrates:');
    console.log('- TypeScript compilation across packages');
    console.log('- Dependency management in a monorepo');
    console.log('- Parallel builds with gaffer-exec');
    console.log('='.repeat(50));
  }

  makeRequest(endpoint: string, data: any): void {
    this.logger.info(`Making request to ${endpoint}`);
    this.apiGateway.handleRequest(endpoint, data);
  }
}

// Example usage
const config: Config = {
  serviceName: 'web-app',
  port: 8080,
  environment: 'development'
};

const app = new WebApp(config);
app.start();
