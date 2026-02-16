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
}

export function validateConfig(config: Config): boolean {
  if (!config.serviceName || config.serviceName.trim() === '') {
    return false;
  }
  if (config.port < 1024 || config.port > 65535) {
    return false;
  }
  return true;
}

export const version = '1.0.0';
