/**
 * User Management Service
 * Handles user CRUD operations and profile management
 */

import { Logger, Config, validateConfig, User } from '@example/shared-lib';
import { UserRepository } from './repository';
import { UserHandler } from './handlers';

export class UserService {
  private logger: Logger;
  private config: Config;
  private repository: UserRepository;
  private handler: UserHandler;

  constructor(config: Config) {
    if (!validateConfig(config)) {
      throw new Error('Invalid configuration for UserService');
    }
    this.config = config;
    this.logger = new Logger(config.serviceName);
    this.repository = new UserRepository();
    this.handler = new UserHandler(this.logger, this.repository);
  }

  start(): void {
    this.logger.info(`Starting user service on port ${this.config.port}`);
    this.logger.info(`Environment: ${this.config.environment}`);
  }

  async getUser(userId: string): Promise<User | null> {
    this.logger.info(`Retrieving user: ${userId}`);
    return this.repository.findById(userId);
  }

  async createUser(username: string, email: string): Promise<User> {
    this.logger.info(`Creating user: ${username}`);
    return this.repository.createUser(username, email);
  }

  getHandler(): UserHandler {
    return this.handler;
  }

  getRepository(): UserRepository {
    return this.repository;
  }
}

// Export handlers and repository
export * from './handlers';
export * from './repository';

// Example usage
const config: Config = {
  serviceName: 'user-service',
  port: 3002,
  environment: 'development'
};

const service = new UserService(config);
service.start();
