/**
 * Configuration helper to load environment variables
 *
 * For React Native, we use react-native-config to load .env files
 * Install: npm install react-native-config
 *
 * Alternative: Use react-native-dotenv for simpler setup
 */

// If using react-native-config (recommended):
// import Config from 'react-native-config';

// For now, we'll use a simple approach that works without additional dependencies
// In production, consider using react-native-config or react-native-dotenv

interface AppConfig {
  BRAND_ID: string
  API_URL: string
  X_API_KEY?: string
  DEBUG: string
}

// This will be replaced by react-native-config in production
// For development, you can set these in your .env file and use a bundler plugin
const Config: AppConfig = {
  BRAND_ID: process.env.BRAND_ID || '',
  API_URL: process.env.API_URL || '',
  X_API_KEY: process.env.X_API_KEY || undefined,
  DEBUG: process.env.DEBUG || 'false',
}

export default Config

/**
 * Validate that required configuration is present
 */
export function validateConfig(): void {
  if (!Config.BRAND_ID) {
    throw new Error('BRAND_ID is required. Check your .env file.')
  }

  if (!Config.API_URL) {
    throw new Error('API_URL is required. Check your .env file.')
  }

  if (!Config.API_URL.startsWith('http')) {
    throw new Error('API_URL must be a valid URL')
  }
}

/**
 * Get configuration values with type safety
 */
export const AppConfig = {
  brandId: Config.BRAND_ID,
  apiUrl: Config.API_URL,
  xApiKey: Config.X_API_KEY,
  debug: Config.DEBUG.toLowerCase() === 'true',
}
