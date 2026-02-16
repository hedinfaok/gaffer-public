/**
 * Middleware for API Gateway
 */

import { Logger, ApiResponse, createErrorResponse } from '@example/shared-lib';

export interface Middleware {
  process(request: any, next: () => Promise<ApiResponse>): Promise<ApiResponse>;
}

export class LoggingMiddleware implements Middleware {
  constructor(private logger: Logger) {}

  async process(request: any, next: () => Promise<ApiResponse>): Promise<ApiResponse> {
    const startTime = Date.now();
    this.logger.info(`Incoming request: ${JSON.stringify(request).substring(0, 100)}`);

    const response = await next();

    const duration = Date.now() - startTime;
    this.logger.info(`Request completed in ${duration}ms`);

    return response;
  }
}

export class RateLimitMiddleware implements Middleware {
  private requestCounts: Map<string, { count: number; resetTime: number }> = new Map();
  private maxRequests: number;
  private windowMs: number;

  constructor(maxRequests: number = 100, windowMs: number = 60000) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
  }

  async process(request: any, next: () => Promise<ApiResponse>): Promise<ApiResponse> {
    const clientId = request.clientId || 'anonymous';
    const now = Date.now();

    let record = this.requestCounts.get(clientId);

    if (!record || now > record.resetTime) {
      record = {
        count: 0,
        resetTime: now + this.windowMs
      };
      this.requestCounts.set(clientId, record);
    }

    if (record.count >= this.maxRequests) {
      return createErrorResponse('Rate limit exceeded');
    }

    record.count++;
    return next();
  }
}

export class ValidationMiddleware implements Middleware {
  constructor(private logger: Logger) {}

  async process(request: any, next: () => Promise<ApiResponse>): Promise<ApiResponse> {
    if (!request || typeof request !== 'object') {
      this.logger.warn('Invalid request format');
      return createErrorResponse('Invalid request format');
    }

    // Basic validation
    if (request.method && !['GET', 'POST', 'PUT', 'DELETE'].includes(request.method)) {
      return createErrorResponse('Invalid HTTP method');
    }

    return next();
  }
}

export class MiddlewareChain {
  private middlewares: Middleware[] = [];

  use(middleware: Middleware): void {
    this.middlewares.push(middleware);
  }

  async execute(request: any, finalHandler: () => Promise<ApiResponse>): Promise<ApiResponse> {
    let index = 0;

    const next = async (): Promise<ApiResponse> => {
      if (index < this.middlewares.length) {
        const middleware = this.middlewares[index++];
        return middleware.process(request, next);
      }
      return finalHandler();
    };

    return next();
  }
}
