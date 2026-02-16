/**
 * Validation utilities for common data types
 */

import { User, Config } from './index';

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function validateUsername(username: string): boolean {
  // Username must be 3-20 characters, alphanumeric with underscores
  const usernameRegex = /^[a-zA-Z0-9_]{3,20}$/;
  return usernameRegex.test(username);
}

export function validatePort(port: number): boolean {
  return Number.isInteger(port) && port >= 1024 && port <= 65535;
}

export function validateUser(user: Partial<User>): string[] {
  const errors: string[] = [];

  if (!user.username || !validateUsername(user.username)) {
    errors.push('Invalid username: must be 3-20 alphanumeric characters');
  }

  if (!user.email || !validateEmail(user.email)) {
    errors.push('Invalid email format');
  }

  if (!user.id || user.id.trim() === '') {
    errors.push('User ID is required');
  }

  return errors;
}

export function validateConfig(config: Config): boolean {
  if (!config.serviceName || config.serviceName.trim() === '') {
    return false;
  }
  if (!validatePort(config.port)) {
    return false;
  }
  if (!['development', 'staging', 'production'].includes(config.environment)) {
    return false;
  }
  return true;
}

export function sanitizeInput(input: string): string {
  // Basic sanitization - remove potential SQL injection characters
  return input.replace(/['"`;]/g, '');
}

export function validatePassword(password: string): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (password.length < 8) {
    errors.push('Password must be at least 8 characters');
  }

  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }

  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }

  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
