import AsyncStorage from '@react-native-async-storage/async-storage'

/**
 * Configuration for the MobileTracker SDK
 */
export interface TrackerConfiguration {
  apiKey: string
  brandId: string
  userId: string
  environment: 'qc' | 'production'
}

/**
 * Result of configuration validation
 */
export interface ValidationResult {
  valid: boolean
  errors: string[]
}

/**
 * AsyncStorage keys for persisting configuration
 */
export const ASYNC_STORAGE_KEYS = {
  apiKey: 'tracker_api_key',
  brandId: 'tracker_brand_id',
  environment: 'tracker_environment',
  userId: 'tracker_user_id',
} as const

/**
 * Environment to API URL mapping
 */
export const ENVIRONMENT_URLS = {
  qc: 'https://tracking.api.qc.founder-os.ai/api',
  production: 'https://tracking.api.founder-os.ai/api',
} as const

/**
 * Validates a configuration object
 * @param config - Partial configuration to validate
 * @returns ValidationResult with valid flag and error messages
 */
export function validateConfiguration(
  config: Partial<TrackerConfiguration>
): ValidationResult {
  const errors: string[] = []

  if (!config.apiKey?.trim()) {
    errors.push('API Key is required')
  }
  if (!config.brandId?.trim()) {
    errors.push('Brand ID is required')
  }

  return {
    valid: errors.length === 0,
    errors,
  }
}

/**
 * Gets the API URL for a given environment
 * @param environment - Environment name ('qc' or 'production')
 * @returns API URL string
 */
export function getApiUrl(environment: 'qc' | 'production'): string {
  return ENVIRONMENT_URLS[environment]
}

/**
 * Loads configuration from AsyncStorage
 * @returns TrackerConfiguration if found, null otherwise
 */
export async function loadConfiguration(): Promise<TrackerConfiguration | null> {
  try {
    const [apiKey, brandId, environment, userId] = await Promise.all([
      AsyncStorage.getItem(ASYNC_STORAGE_KEYS.apiKey),
      AsyncStorage.getItem(ASYNC_STORAGE_KEYS.brandId),
      AsyncStorage.getItem(ASYNC_STORAGE_KEYS.environment),
      AsyncStorage.getItem(ASYNC_STORAGE_KEYS.userId),
    ])

    if (!apiKey || !brandId || !environment) {
      return null
    }

    return {
      apiKey,
      brandId,
      userId: userId || '',
      environment: environment as 'qc' | 'production',
    }
  } catch (error) {
    console.error('Error loading configuration from AsyncStorage:', error)
    return null
  }
}

/**
 * Saves configuration to AsyncStorage
 * @param config - Configuration to save
 */
export async function saveConfiguration(
  config: TrackerConfiguration
): Promise<void> {
  try {
    await Promise.all([
      AsyncStorage.setItem(ASYNC_STORAGE_KEYS.apiKey, config.apiKey),
      AsyncStorage.setItem(ASYNC_STORAGE_KEYS.brandId, config.brandId),
      AsyncStorage.setItem(ASYNC_STORAGE_KEYS.environment, config.environment),
      AsyncStorage.setItem(ASYNC_STORAGE_KEYS.userId, config.userId),
    ])
  } catch (error) {
    console.error('Error saving configuration to AsyncStorage:', error)
    throw error
  }
}

/**
 * Clears configuration from AsyncStorage
 */
export async function clearConfiguration(): Promise<void> {
  try {
    await Promise.all([
      AsyncStorage.removeItem(ASYNC_STORAGE_KEYS.apiKey),
      AsyncStorage.removeItem(ASYNC_STORAGE_KEYS.brandId),
      AsyncStorage.removeItem(ASYNC_STORAGE_KEYS.environment),
      AsyncStorage.removeItem(ASYNC_STORAGE_KEYS.userId),
    ])
  } catch (error) {
    console.error('Error clearing configuration from AsyncStorage:', error)
    throw error
  }
}

/**
 * Checks if configuration exists in AsyncStorage
 * @returns true if configuration exists, false otherwise
 */
export async function hasConfiguration(): Promise<boolean> {
  try {
    const config = await loadConfiguration()
    return config !== null
  } catch (error) {
    console.error('Error checking configuration:', error)
    return false
  }
}
