/**
 * Application state management
 */

import { Logger, User } from '@example/shared-lib';

export interface AppState {
  currentUser: User | null;
  isAuthenticated: boolean;
  lastUpdated: Date;
}

export class StateManager {
  private logger: Logger;
  private state: AppState;
  private listeners: Array<(state: AppState) => void> = [];

  constructor(logger: Logger) {
    this.logger = logger;
    this.state = {
      currentUser: null,
      isAuthenticated: false,
      lastUpdated: new Date()
    };
  }

  getState(): AppState {
    return { ...this.state };
  }

  setState(updates: Partial<AppState>): void {
    this.logger.info(`Updating state: ${JSON.stringify(updates)}`);
    
    this.state = {
      ...this.state,
      ...updates,
      lastUpdated: new Date()
    };

    this.notifyListeners();
  }

  subscribe(listener: (state: AppState) => void): () => void {
    this.listeners.push(listener);
    
    // Return unsubscribe function
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener(this.getState());
      } catch (error) {
        this.logger.error(`Error in state listener: ${error}`);
      }
    });
  }

  login(user: User): void {
    this.setState({
      currentUser: user,
      isAuthenticated: true
    });
    this.logger.info(`User logged in: ${user.username}`);
  }

  logout(): void {
    this.setState({
      currentUser: null,
      isAuthenticated: false
    });
    this.logger.info('User logged out');
  }
}
