import { useCallback } from 'react'
import {
  TrackerConfiguration,
  ValidationResult,
  loadConfiguration as utilLoadConfiguration,
  saveConfiguration as utilSaveConfiguration,
  clearConfiguration as utilClearConfiguration,
  hasConfiguration as utilHasConfiguration,
  validateConfiguration as utilValidateConfiguration,
  getApiUrl as utilGetApiUrl,
} from './configurationManager'

/**
 * Hook for managing tracker configuration persistence and validation
 * Provides methods to load, save, clear, and validate configuration
 * stored in AsyncStorage
 */
export function useConfigurationManager() {
  /**
   * Load configuration from AsyncStorage
   * @returns TrackerConfiguration if found, null otherwise
   */
  const loadConfiguration =
    useCallback(async (): Promise<TrackerConfiguration | null> => {
      return utilLoadConfiguration()
    }, [])

  /**
   * Save configuration to AsyncStorage
   * @param config - Configuration to save
   * @throws Error if save operation fails
   */
  const saveConfiguration = useCallback(
    async (config: TrackerConfiguration): Promise<void> => {
      return utilSaveConfiguration(config)
    },
    []
  )

  /**
   * Clear configuration from AsyncStorage
   * @throws Error if clear operation fails
   */
  const clearConfiguration = useCallback(async (): Promise<void> => {
    return utilClearConfiguration()
  }, [])

  /**
   * Check if configuration exists in AsyncStorage
   * @returns true if configuration exists, false otherwise
   */
  const hasConfiguration = useCallback(async (): Promise<boolean> => {
    return utilHasConfiguration()
  }, [])

  /**
   * Validate configuration object
   * @param config - Partial configuration to validate
   * @returns ValidationResult with valid flag and error messages
   */
  const validateConfiguration = useCallback(
    (config: Partial<TrackerConfiguration>): ValidationResult => {
      return utilValidateConfiguration(config)
    },
    []
  )

  /**
   * Get API URL for a given environment
   * @param environment - Environment name ('qc' or 'production')
   * @returns API URL string
   */
  const getApiUrl = useCallback((environment: 'qc' | 'production'): string => {
    return utilGetApiUrl(environment)
  }, [])

  return {
    loadConfiguration,
    saveConfiguration,
    clearConfiguration,
    hasConfiguration,
    validateConfiguration,
    getApiUrl,
  }
}

export default useConfigurationManager
