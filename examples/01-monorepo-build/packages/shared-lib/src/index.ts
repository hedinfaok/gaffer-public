/**
 * Shared library used across all services in the monorepo
 * This demonstrates a common pattern in real monorepo projects
 */

export interface Config {
  port: number;
  environment: string;
  serviceName: string;
}

export class Logger {
  private serviceName: string;

  constructor(serviceName: string) {
    this.serviceName = serviceName;
  }

  info(message: string): void {
    console.log(`[${this.serviceName}] INFO: ${message}`);
  }

  error(message: string): void {
    console.error(`[${this.serviceName}] ERROR: ${message}`);
  }

  warn(message: string): void {
    console.warn(`[${this.serviceName}] WARN: ${message}`);
  }

  debug(message: string): void {
    if (process.env.DEBUG) {
      console.log(`[${this.serviceName}] DEBUG: ${message}`);
    }
  }
}

export const version = '1.0.0';

// Re-export from other modules
export * from './types';
export * from './validators';
export * from './utils';
