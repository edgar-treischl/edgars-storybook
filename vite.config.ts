import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import federation from '@originjs/vite-plugin-federation';
import { copyFileSync } from 'fs';
import { join } from 'path';

export default defineConfig({
  // IMPORTANT for GitHub Pages deployment
  base: '/edgars-storybook/',

  plugins: [
    react(),
    federation({
      name: 'edgars-storybook',
      filename: 'remoteEntry.js',
      exposes: {
        './App': './src/App.tsx',
      },

      shared: ['react', 'react-dom', 'react-router-dom']

    }),
    {
      name: 'move-remote-entry',
      apply: 'build',
      enforce: 'post',
      closeBundle() {
        try {
          const source = join(process.cwd(), 'dist/assets/remoteEntry.js');
          const dest = join(process.cwd(), 'dist/remoteEntry.js');
          copyFileSync(source, dest);
          console.log('✓ Moved remoteEntry.js to dist root');
        } catch (e) {
          console.warn('Could not move remoteEntry.js:', e);
        }
      }
    }
  ],

  server: {
    host: true,
    port: 5174,
    cors: true,
  },

  preview: {
    host: true,
    port: 5174,
  },

  build: {
    target: 'esnext',
    cssCodeSplit: false,
    minify: false,
  },
});
