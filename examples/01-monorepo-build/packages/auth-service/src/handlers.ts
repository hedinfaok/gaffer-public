/**
 * Authentication handlers and middleware
 */

import { Logger, User, AuthToken, createSuccessResponse, createErrorResponse, ApiResponse } from '@example/shared-lib';

export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
}

export class AuthHandler {
  private logger: Logger;

  constructor(logger: Logger) {
    this.logger = logger;
  }

  async handleLogin(request: LoginRequest): Promise<ApiResponse<AuthToken>> {
    this.logger.info(`Login attempt for user: ${request.username}`);

    // Simulate some processing time
    await new Promise(resolve => setTimeout(resolve, 10));

    if (!request.username || !request.password) {
      return createErrorResponse('Username and password are required');
    }

    // Simplified authentication logic
    if (request.password.length < 8) {
      this.logger.warn(`Failed login attempt for ${request.username}: weak password`);
      return createErrorResponse('Invalid credentials');
    }

    const token: AuthToken = {
      token: `token_${request.username}_${Date.now()}`,
      expiresAt: new Date(Date.now() + 3600000), // 1 hour
      userId: `user_${request.username}`
    };

    this.logger.info(`Successful login for user: ${request.username}`);
    return createSuccessResponse(token);
  }

  async handleRegister(request: RegisterRequest): Promise<ApiResponse<User>> {
    this.logger.info(`Registration attempt for user: ${request.username}`);

    // Simulate some processing time
    await new Promise(resolve => setTimeout(resolve, 15));

    if (!request.username || !request.email || !request.password) {
      return createErrorResponse('All fields are required');
    }

    const user: User = {
      id: `user_${Date.now()}`,
      username: request.username,
      email: request.email,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    this.logger.info(`User registered successfully: ${user.id}`);
    return createSuccessResponse(user);
  }

  async validateToken(token: string): Promise<boolean> {
    this.logger.debug(`Validating token: ${token.substring(0, 10)}...`);
    
    // Simulate token validation
    await new Promise(resolve => setTimeout(resolve, 5));
    
    return token.startsWith('token_') && token.length > 20;
  }

  async refreshToken(oldToken: string): Promise<ApiResponse<AuthToken>> {
    const isValid = await this.validateToken(oldToken);
    
    if (!isValid) {
      return createErrorResponse('Invalid token');
    }

    const newToken: AuthToken = {
      token: `token_refreshed_${Date.now()}`,
      expiresAt: new Date(Date.now() + 3600000),
      userId: 'extracted_from_old_token'
    };

    return createSuccessResponse(newToken);
  }
}
