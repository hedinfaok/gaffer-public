/**
 * User Service
 * Handles user profile management and operations
 */

import { Logger, Config, validateConfig } from '@example/shared-lib';

export interface User {
  id: string;
  username: string;
  email: string;
  createdAt: Date;
}

export class UserService {
  private logger: Logger;
  private config: Config;
  private users: Map<string, User>;

  constructor(config: Config) {
    if (!validateConfig(config)) {
      throw new Error('Invalid configuration for UserService');
    }
    this.config = config;
    this.logger = new Logger(config.serviceName);
    this.users = new Map();
  }

  start(): void {
    this.logger.info(`Starting user service on port ${this.config.port}`);
  }

  createUser(username: string, email: string): User {
    const user: User = {
      id: `user_${Date.now()}`,
      username,
      email,
      createdAt: new Date()
    };
    this.users.set(user.id, user);
    this.logger.info(`Created user: ${username}`);
    return user;
  }

  getUser(id: string): User | undefined {
    return this.users.get(id);
  }
}

// Example usage
const config: Config = {
  serviceName: 'user-service',
  port: 3002,
  environment: 'development'
};

const service = new UserService(config);
service.start();
