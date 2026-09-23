/**
 * Web application UI components
 */

import { Logger } from '@example/shared-lib';

export interface ComponentProps {
  logger: Logger;
}

export class Header {
  private logger: Logger;

  constructor(props: ComponentProps) {
    this.logger = props.logger;
  }

  render(): void {
    console.log('╔════════════════════════════════════════════════════════╗');
    console.log('║     Monorepo Example - TypeScript Web Application     ║');
    console.log('╚════════════════════════════════════════════════════════╝');
    this.logger.info('Header component rendered');
  }
}

export class Navigation {
  private logger: Logger;
  private routes: string[];

  constructor(props: ComponentProps, routes: string[]) {
    this.logger = props.logger;
    this.routes = routes;
  }

  render(): void {
    console.log('\nNavigation:');
    this.routes.forEach((route, index) => {
      console.log(`   ${index + 1}. ${route}`);
    });
    console.log('');
    this.logger.info('Navigation component rendered');
  }
}

export class Dashboard {
  private logger: Logger;

  constructor(props: ComponentProps) {
    this.logger = props.logger;
  }

  render(): void {
    console.log('Dashboard');
    console.log('─'.repeat(56));
    console.log('This application demonstrates:');
    console.log('  ✓ TypeScript compilation across multiple packages');
    console.log('  ✓ Dependency management in a monorepo');
    console.log('  ✓ Parallel builds with gaffer-exec');
    console.log('  ✓ Realistic build complexity');
    console.log('─'.repeat(56));
    this.logger.info('Dashboard component rendered');
  }
}

export class Footer {
  private logger: Logger;
  private version: string;

  constructor(props: ComponentProps, version: string) {
    this.logger = props.logger;
    this.version = version;
  }

  render(): void {
    console.log('');
    console.log('─'.repeat(56));
    console.log(`Version: ${this.version} | Built with ♥  using gaffer-exec`);
    console.log('─'.repeat(56));
    this.logger.info('Footer component rendered');
  }
}
