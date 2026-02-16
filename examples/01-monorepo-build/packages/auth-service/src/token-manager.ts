/**
 * Token management utilities
 */

import { AuthToken, generateId } from '@example/shared-lib';

export class TokenManager {
  private tokens: Map<string, AuthToken> = new Map();

  generateToken(userId: string, expiresInMs: number = 3600000): AuthToken {
    const token: AuthToken = {
      token: `jwt_${generateId()}`,
      expiresAt: new Date(Date.now() + expiresInMs),
      userId
    };

    this.tokens.set(token.token, token);
    return token;
  }

  validateToken(tokenString: string): boolean {
    const token = this.tokens.get(tokenString);
    
    if (!token) {
      return false;
    }

    if (token.expiresAt < new Date()) {
      this.tokens.delete(tokenString);
      return false;
    }

    return true;
  }

  revokeToken(tokenString: string): boolean {
    return this.tokens.delete(tokenString);
  }

  getUserIdFromToken(tokenString: string): string | null {
    const token = this.tokens.get(tokenString);
    return token ? token.userId : null;
  }

  cleanExpiredTokens(): void {
    const now = new Date();
    for (const [tokenString, token] of this.tokens.entries()) {
      if (token.expiresAt < now) {
        this.tokens.delete(tokenString);
      }
    }
  }

  getActiveTokenCount(): number {
    this.cleanExpiredTokens();
    return this.tokens.size;
  }
}
