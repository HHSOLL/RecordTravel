import react from '@vitejs/plugin-react';
import path from 'path';
import {defineConfig} from 'vite';

export default defineConfig({
  base: './',
  plugins: [react()],
  build: {
    outDir: 'dist-embed',
    emptyOutDir: true,
    sourcemap: false,
    assetsInlineLimit: 10_000_000,
    rollupOptions: {
      input: path.resolve(__dirname, 'embed.html'),
    },
  },
});
