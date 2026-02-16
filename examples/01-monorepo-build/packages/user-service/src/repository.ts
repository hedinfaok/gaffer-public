/**
 * User repository for data access
 */

import { User, generateId, validateUser } from '@example/shared-lib';

export class UserRepository {
  private users: Map<string, User> = new Map();

  async createUser(username: string, email: string): Promise<User> {
    // Simulate database latency
    await new Promise(resolve => setTimeout(resolve, 10));

    const user: User = {
      id: generateId(),
      username,
      email,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const validationErrors = validateUser(user);
    if (validationErrors.length > 0) {
      throw new Error(`Validation failed: ${validationErrors.join(', ')}`);
    }

    this.users.set(user.id, user);
    return user;
  }

  async findById(id: string): Promise<User | null> {
    await new Promise(resolve => setTimeout(resolve, 5));
    return this.users.get(id) || null;
  }

  async findByUsername(username: string): Promise<User | null> {
    await new Promise(resolve => setTimeout(resolve, 5));
    
    for (const user of this.users.values()) {
      if (user.username === username) {
        return user;
      }
    }
    
    return null;
  }

  async findByEmail(email: string): Promise<User | null> {
    await new Promise(resolve => setTimeout(resolve, 5));
    
    for (const user of this.users.values()) {
      if (user.email === email) {
        return user;
      }
    }
    
    return null;
  }

  async updateUser(id: string, updates: Partial<User>): Promise<User | null> {
    await new Promise(resolve => setTimeout(resolve, 8));
    
    const user = this.users.get(id);
    if (!user) {
      return null;
    }

    const updatedUser: User = {
      ...user,
      ...updates,
      id: user.id, // Ensure ID cannot be changed
      updatedAt: new Date()
    };

    this.users.set(id, updatedUser);
    return updatedUser;
  }

  async deleteUser(id: string): Promise<boolean> {
    await new Promise(resolve => setTimeout(resolve, 7));
    return this.users.delete(id);
  }

  async listUsers(limit: number = 100, offset: number = 0): Promise<User[]> {
    await new Promise(resolve => setTimeout(resolve, 12));
    
    const allUsers = Array.from(this.users.values());
    return allUsers.slice(offset, offset + limit);
  }

  async count(): Promise<number> {
    return this.users.size;
  }
}
