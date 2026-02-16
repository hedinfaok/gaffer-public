/**
 * API Gateway routing logic
 */

import { Logger, ApiResponse, createSuccessResponse, createErrorResponse } from '@example/shared-lib';
import { AuthService } from '@example/auth-service';
import { UserService } from '@example/user-service';

export interface RouteHandler {
  handle(request: any): Promise<ApiResponse>;
}

export class Router {
  private logger: Logger;
  private routes: Map<string, RouteHandler> = new Map();

  constructor(logger: Logger) {
    this.logger = logger;
  }

  register(path: string, handler: RouteHandler): void {
    this.logger.info(`Registering route: ${path}`);
    this.routes.set(path, handler);
  }

  async route(path: string, request: any): Promise<ApiResponse> {
    this.logger.info(`Routing request to: ${path}`);

    const handler = this.routes.get(path);
    if (!handler) {
      this.logger.warn(`No handler found for path: ${path}`);
      return createErrorResponse(`Route not found: ${path}`);
    }

    try {
      return await handler.handle(request);
    } catch (error) {
      this.logger.error(`Error handling request for ${path}: ${error}`);
      return createErrorResponse('Internal server error');
    }
  }

  listRoutes(): string[] {
    return Array.from(this.routes.keys());
  }
}

export class AuthRouteHandler implements RouteHandler {
  constructor(private authService: AuthService) {}

  async handle(request: any): Promise<ApiResponse> {
    const { action, ...data } = request;

    switch (action) {
      case 'login':
        return this.authService.getAuthHandler().handleLogin(data);
      case 'register':
        return this.authService.getAuthHandler().handleRegister(data);
      case 'validate':
        const isValid = await this.authService.getAuthHandler().validateToken(data.token);
        return createSuccessResponse({ valid: isValid });
      default:
        return createErrorResponse(`Unknown action: ${action}`);
    }
  }
}

export class UserRouteHandler implements RouteHandler {
  constructor(private userService: UserService) {}

  async handle(request: any): Promise<ApiResponse> {
    const { action, ...data } = request;

    switch (action) {
      case 'create':
        return this.userService.getHandler().handleCreateUser(data);
      case 'get':
        return this.userService.getHandler().handleGetUser(data.userId);
      case 'update':
        return this.userService.getHandler().handleUpdateUser(data.userId, data.updates);
      case 'delete':
        return this.userService.getHandler().handleDeleteUser(data.userId);
      case 'list':
        return this.userService.getHandler().handleListUsers(data.limit, data.offset);
      default:
        return createErrorResponse(`Unknown action: ${action}`);
    }
  }
}
