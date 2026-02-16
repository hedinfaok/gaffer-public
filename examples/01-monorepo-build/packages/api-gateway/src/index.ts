/**
 * API Gateway
 * Routes requests to appropriate microservices
 */

import { Logger, Config, validateConfig } from '@example/shared-lib';
import { AuthService } from '@example/auth-service';
import { UserService } from '@example/user-service';
import { Router, AuthRouteHandler, UserRouteHandler } from './router';
import { MiddlewareChain, LoggingMiddleware, RateLimitMiddleware, ValidationMiddleware } from './middleware';

export class APIGateway {
  private logger: Logger;
  private config: Config;
  private authService: AuthService;
  private userService: UserService;
  private router: Router;
  private middleware: MiddlewareChain;

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

    // Setup router
    this.router = new Router(this.logger);
    this.setupRoutes();

    // Setup middleware
    this.middleware = new MiddlewareChain();
    this.setupMiddleware();
  }

  private setupRoutes(): void {
    this.router.register('/auth', new AuthRouteHandler(this.authService));
    this.router.register('/users', new UserRouteHandler(this.userService));
  }

  private setupMiddleware(): void {
    this.middleware.use(new ValidationMiddleware(this.logger));
    this.middleware.use(new LoggingMiddleware(this.logger));
    this.middleware.use(new RateLimitMiddleware());
  }

  start(): void {
    this.logger.info(`Starting API gateway on port ${this.config.port}`);
    this.logger.info(`Environment: ${this.config.environment}`);
    this.logger.info(`Available routes: ${this.router.listRoutes().join(', ')}`);
    
    this.authService.start();
    this.userService.start();
  }

  async handleRequest(endpoint: string, data: any): Promise<void> {
    this.logger.info(`Handling request to ${endpoint}`);

    const response = await this.middleware.execute(data, async () => {
      return this.router.route(endpoint, data);
    });

    this.logger.info(`Response: ${response.success ? 'Success' : 'Error'}`);
    if (response.error) {
      this.logger.error(`Error: ${response.error}`);
    }
  }

  getRouter(): Router {
    return this.router;
  }
}

// Export router and middleware
export * from './router';
export * from './middleware';

// Example usage
const config: Config = {
  serviceName: 'api-gateway',
  port: 3000,
  environment: 'development'
};

const gateway = new APIGateway(config);
gateway.start();
