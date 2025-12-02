package ai.founderos.mobiletracker.example

import android.content.Context

/**
 * Manages persistence of user data (userId, name, email) across app sessions
 * 
 * Stores user information in SharedPreferences so it can be restored when the app reopens,
 * unless the user explicitly resets the session or all data.
 */
object UserDataManager {
    private const val PREFS_NAME = "user_data_prefs"
    private const val KEY_USER_ID = "user_id"
    private const val KEY_USER_NAME = "user_name"
    private const val KEY_USER_EMAIL = "user_email"
    
    /**
     * Save user data to SharedPreferences
     */
    fun saveUserData(context: Context, userId: String, name: String, email: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString(KEY_USER_ID, userId)
            putString(KEY_USER_NAME, name)
            putString(KEY_USER_EMAIL, email)
            apply()
        }
    }
    
    /**
     * Load user data from SharedPreferences
     */
    fun loadUserData(context: Context): UserData? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
        val userId = prefs.getString(KEY_USER_ID, null) ?: return null
        val name = prefs.getString(KEY_USER_NAME, "") ?: ""
        val email = prefs.getString(KEY_USER_EMAIL, "") ?: ""
        
        return UserData(userId = userId, name = name, email = email)
    }
    
    /**
     * Clear user data from SharedPreferences
     */
    fun clearUserData(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            remove(KEY_USER_ID)
            remove(KEY_USER_NAME)
            remove(KEY_USER_EMAIL)
            apply()
        }
    }
}

/**
 * Data class for user information
 */
data class UserData(
    val userId: String,
    val name: String,
    val email: String
)
