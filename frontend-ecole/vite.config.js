import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    port: 5173,
    host: true, // Permet de lier toutes les IP locales (utile pour Render)
    proxy: {
      '/api': {
        target: 'https://schoolndtg.onrender.com',
        changeOrigin: true,
        secure: false,
      },
      '/sanctum': {
        target: 'https://schoolndtg.onrender.com',
        changeOrigin: true,
        secure: false,
      }
    }
  },
  preview: {
    allowedHosts: ['elevendtg.onrender.com'] // Autorise ton domaine Render
    // ou pour autoriser tous les domaines : allowedHosts: 'all'
  }
})