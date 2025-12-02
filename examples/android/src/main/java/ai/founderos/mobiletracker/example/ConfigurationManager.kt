package ai.founderos.mobiletracker.example

import android.content.Context

/**
 * Singleton object for managing configuration persistence to SharedPreferences
 * 
 * Handles loading, saving, and clearing tracker configuration from local storage.
 * Requirements: 2.1, 2.2, 2.3
 */
object ConfigurationManager {
    /**
     * Load configuration from SharedPreferences
     * 
     * @param context Android context for accessing SharedPreferences
     * @return TrackerConfiguration if one exists, null otherwise
     */
    fun loadConfiguration(context: Context): TrackerConfiguration? {
        val prefs = context.getSharedPreferences(
            PreferencesKeys.PREFS_NAME,
            Context.MODE_PRIVATE
        )

        // Check if all required keys exist
        if (!prefs.contains(PreferencesKeys.KEY_API_KEY) ||
            !prefs.contains(PreferencesKeys.KEY_BRAND_ID) ||
            !prefs.contains(PreferencesKeys.KEY_ENVIRONMENT)
        ) {
            return null
        }

        val apiKey = prefs.getString(PreferencesKeys.KEY_API_KEY, "") ?: ""
        val brandId = prefs.getString(PreferencesKeys.KEY_BRAND_ID, "") ?: ""
        val environmentStr = prefs.getString(PreferencesKeys.KEY_ENVIRONMENT, "") ?: ""

        // Return null if required fields are empty
        if (apiKey.isEmpty() || brandId.isEmpty() || environmentStr.isEmpty()) {
            return null
        }

        val environment = try {
            Environment.valueOf(environmentStr)
        } catch (e: IllegalArgumentException) {
            return null
        }

        return TrackerConfiguration(
            apiKey = apiKey,
            brandId = brandId,
            environment = environment,
        )
    }

    /**
     * Save configuration to SharedPreferences
     * 
     * @param context Android context for accessing SharedPreferences
     * @param config The TrackerConfiguration to save
     */
    fun saveConfiguration(context: Context, config: TrackerConfiguration) {
        val prefs = context.getSharedPreferences(
            PreferencesKeys.PREFS_NAME,
            Context.MODE_PRIVATE
        )

        prefs.edit().apply {
            putString(PreferencesKeys.KEY_API_KEY, config.apiKey)
            putString(PreferencesKeys.KEY_BRAND_ID, config.brandId)
            putString(PreferencesKeys.KEY_ENVIRONMENT, config.environment.name)
            apply()
        }
    }

    /**
     * Clear configuration from SharedPreferences
     * 
     * @param context Android context for accessing SharedPreferences
     */
    fun clearConfiguration(context: Context) {
        val prefs = context.getSharedPreferences(
            PreferencesKeys.PREFS_NAME,
            Context.MODE_PRIVATE
        )

        prefs.edit().apply {
            remove(PreferencesKeys.KEY_API_KEY)
            remove(PreferencesKeys.KEY_BRAND_ID)
            remove(PreferencesKeys.KEY_ENVIRONMENT)
            apply()
        }
    }

    /**
     * Check if a configuration exists in SharedPreferences
     * 
     * @param context Android context for accessing SharedPreferences
     * @return true if configuration exists, false otherwise
     */
    fun hasConfiguration(context: Context): Boolean {
        return loadConfiguration(context) != null
    }
}
