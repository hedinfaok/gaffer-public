/**
 * Web Application
 * Frontend application that consumes the API gateway
 */

import { Logger, Config, validateConfig, version } from '@example/shared-lib';
import { APIGateway } from '@example/api-gateway';
import { Header, Navigation, Dashboard, Footer } from './components';
import { StateManager } from './state';

export class WebApp {
  private logger: Logger;
  private config: Config;
  private apiGateway: APIGateway;
  private stateManager: StateManager;
  private header: Header;
  private navigation: Navigation;
  private dashboard: Dashboard;
  private footer: Footer;

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

    // Initialize state management
    this.stateManager = new StateManager(this.logger);

    // Initialize components
    const componentProps = { logger: this.logger };
    this.header = new Header(componentProps);
    this.navigation = new Navigation(componentProps, ['Home', 'Users', 'Auth', 'Settings']);
    this.dashboard = new Dashboard(componentProps);
    this.footer = new Footer(componentProps, version);
  }

  start(): void {
    this.logger.info(`Starting web app on port ${this.config.port}`);
    this.logger.info(`Environment: ${this.config.environment}`);
    
    this.apiGateway.start();
    this.renderApplication();
  }

  private renderApplication(): void {
    console.log('\n');
    this.header.render();
    this.navigation.render();
    this.dashboard.render();
    this.footer.render();
    console.log('\n');
    
    this.logger.info('Application rendered successfully');
  }

  async makeRequest(endpoint: string, data: any): Promise<void> {
    this.logger.info(`Making request to ${endpoint}`);
    await this.apiGateway.handleRequest(endpoint, data);
  }

  getStateManager(): StateManager {
    return this.stateManager;
  }
}

// Export components and state
export * from './components';
export * from './state';

// Main entry point
const config: Config = {
  serviceName: 'web-app',
  port: 8080,
  environment: 'development'
};

const app = new WebApp(config);
app.start();
