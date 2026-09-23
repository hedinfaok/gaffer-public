import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Port is provided by start-frontend.sh via the PORT env var (default 3000).
export default defineConfig({
  plugins: [react()],
  server: {
    port: Number(process.env.PORT) || 3000,
    host: true,
    proxy: {
      '/api': 'http://localhost:3001',
    },
  },
});
