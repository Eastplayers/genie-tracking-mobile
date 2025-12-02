package ai.founderos.mobiletracker.example

/**
 * Constants for SharedPreferences keys used in configuration persistence
 */
object PreferencesKeys {
    /**
     * SharedPreferences file name for storing tracker configuration
     */
    const val PREFS_NAME = "tracker_config"

    /**
     * Key for storing the API key
     */
    const val KEY_API_KEY = "api_key"

    /**
     * Key for storing the brand ID
     */
    const val KEY_BRAND_ID = "brand_id"

    /**
     * Key for storing the selected environment (QC or PRODUCTION)
     */
    const val KEY_ENVIRONMENT = "environment"

    /**
     * Key for storing the optional user ID
     */
    const val KEY_USER_ID = "user_id"
}
