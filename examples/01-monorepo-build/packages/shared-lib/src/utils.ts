/**
 * Utility functions shared across services
 */

import { ApiResponse, ServiceMetrics } from './types';

export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

export function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

export function formatDateTime(date: Date): string {
  return date.toISOString();
}

export function createSuccessResponse<T>(data: T): ApiResponse<T> {
  return {
    success: true,
    data,
    timestamp: new Date()
  };
}

export function createErrorResponse(error: string): ApiResponse {
  return {
    success: false,
    error,
    timestamp: new Date()
  };
}

export function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

export function retry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delayMs: number = 1000
): Promise<T> {
  return fn().catch(async (error) => {
    if (maxRetries <= 0) {
      throw error;
    }
    await sleep(delayMs);
    return retry(fn, maxRetries - 1, delayMs * 2);
  });
}

export class Timer {
  private startTime: number;

  constructor() {
    this.startTime = Date.now();
  }

  elapsed(): number {
    return Date.now() - this.startTime;
  }

  reset(): void {
    this.startTime = Date.now();
  }
}

export function calculateMetrics(
  previousMetrics: ServiceMetrics,
  newRequestTime: number,
  isError: boolean = false
): ServiceMetrics {
  const requestCount = previousMetrics.requestCount + 1;
  const errorCount = previousMetrics.errorCount + (isError ? 1 : 0);
  const averageResponseTime =
    (previousMetrics.averageResponseTime * previousMetrics.requestCount + newRequestTime) /
    requestCount;

  return {
    requestCount,
    errorCount,
    averageResponseTime,
    lastRequestAt: new Date()
  };
}

export function debounce<T extends (...args: any[]) => any>(
  func: T,
  waitMs: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null;

  return (...args: Parameters<T>) => {
    if (timeout) {
      clearTimeout(timeout);
    }
    timeout = setTimeout(() => func(...args), waitMs);
  };
}

export function chunk<T>(array: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size));
  }
  return chunks;
}
