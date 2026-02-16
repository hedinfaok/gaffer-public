/**
 * Common type definitions used across all services
 */

export interface User {
  id: string;
  username: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface AuthToken {
  token: string;
  expiresAt: Date;
  userId: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: Date;
}

export interface ServiceHealth {
  status: 'healthy' | 'degraded' | 'unhealthy';
  uptime: number;
  version: string;
  dependencies: Record<string, boolean>;
}

export type Environment = 'development' | 'staging' | 'production';

export interface DatabaseConfig {
  host: string;
  port: number;
  database: string;
  maxConnections: number;
}

export interface ServiceMetrics {
  requestCount: number;
  errorCount: number;
  averageResponseTime: number;
  lastRequestAt?: Date;
}
