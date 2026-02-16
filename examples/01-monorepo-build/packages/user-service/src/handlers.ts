/**
 * User service handlers
 */

import { Logger, User, ApiResponse, createSuccessResponse, createErrorResponse, validateEmail, validateUsername } from '@example/shared-lib';
import { UserRepository } from './repository';

export interface CreateUserRequest {
  username: string;
  email: string;
}

export interface UpdateUserRequest {
  username?: string;
  email?: string;
}

export class UserHandler {
  private logger: Logger;
  private repository: UserRepository;

  constructor(logger: Logger, repository: UserRepository) {
    this.logger = logger;
    this.repository = repository;
  }

  async handleCreateUser(request: CreateUserRequest): Promise<ApiResponse<User>> {
    this.logger.info(`Creating user: ${request.username}`);

    if (!validateUsername(request.username)) {
      return createErrorResponse('Invalid username format');
    }

    if (!validateEmail(request.email)) {
      return createErrorResponse('Invalid email format');
    }

    // Check if user already exists
    const existingUser = await this.repository.findByUsername(request.username);
    if (existingUser) {
      return createErrorResponse('Username already exists');
    }

    const existingEmail = await this.repository.findByEmail(request.email);
    if (existingEmail) {
      return createErrorResponse('Email already registered');
    }

    try {
      const user = await this.repository.createUser(request.username, request.email);
      this.logger.info(`User created successfully: ${user.id}`);
      return createSuccessResponse(user);
    } catch (error) {
      this.logger.error(`Failed to create user: ${error}`);
      return createErrorResponse('Failed to create user');
    }
  }

  async handleGetUser(userId: string): Promise<ApiResponse<User>> {
    this.logger.info(`Fetching user: ${userId}`);

    const user = await this.repository.findById(userId);
    
    if (!user) {
      return createErrorResponse('User not found');
    }

    return createSuccessResponse(user);
  }

  async handleUpdateUser(userId: string, request: UpdateUserRequest): Promise<ApiResponse<User>> {
    this.logger.info(`Updating user: ${userId}`);

    if (request.username && !validateUsername(request.username)) {
      return createErrorResponse('Invalid username format');
    }

    if (request.email && !validateEmail(request.email)) {
      return createErrorResponse('Invalid email format');
    }

    const updatedUser = await this.repository.updateUser(userId, request);
    
    if (!updatedUser) {
      return createErrorResponse('User not found');
    }

    this.logger.info(`User updated successfully: ${userId}`);
    return createSuccessResponse(updatedUser);
  }

  async handleDeleteUser(userId: string): Promise<ApiResponse<boolean>> {
    this.logger.info(`Deleting user: ${userId}`);

    const deleted = await this.repository.deleteUser(userId);
    
    if (!deleted) {
      return createErrorResponse('User not found');
    }

    this.logger.info(`User deleted successfully: ${userId}`);
    return createSuccessResponse(true);
  }

  async handleListUsers(limit?: number, offset?: number): Promise<ApiResponse<User[]>> {
    this.logger.info(`Listing users (limit: ${limit}, offset: ${offset})`);

    const users = await this.repository.listUsers(limit, offset);
    const count = await this.repository.count();

    this.logger.info(`Retrieved ${users.length} users (total: ${count})`);
    return createSuccessResponse(users);
  }
}
