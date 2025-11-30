package com.mobiletracker

import android.content.Context
import android.content.SharedPreferences
import java.io.File

/**
 * StorageManager handles persistent storage with dual storage strategy
 * Primary: SharedPreferences (similar to web cookies)
 * Secondary: File backup (similar to web localStorage)
 * 
 * Web Reference: api.ts getCookie(), writeCookie(), clearCookie() methods (lines 37-127)
 */
class StorageManager(
    context: Context,
    private val prefix: String
) {
    private val prefs: SharedPreferences = context.getSharedPreferences("MobileTracker", Context.MODE_PRIVATE)
    private val backupDirectory: File = File(context.filesDir, "tracker_backup")
    
    init {
        // Ensure backup directory exists
        if (!backupDirectory.exists()) {
            backupDirectory.mkdirs()
        }
    }
    
    /**
     * Save a value to both primary (SharedPreferences) and secondary (file backup) storage
     * 
     * @param key Storage key (will be prefixed)
     * @param value String value to store
     * @param expires Optional expiration in days (not enforced, for compatibility)
     */
    fun save(key: String, value: String, expires: Int? = null) {
        val fullKey = prefix + key
        
        // Save to SharedPreferences (primary storage)
        prefs.edit().putString(fullKey, value).apply()
        
        // Save to file backup (secondary storage)
        saveToFileBackup(fullKey, value)
    }
    
    /**
     * Retrieve a value from storage, checking SharedPreferences first, then file backup
     * 
     * @param key Storage key (will be prefixed)
     * @return Stored value if found, null otherwise
     */
    fun retrieve(key: String): String? {
        val fullKey = prefix + key
        
        // Try SharedPreferences first (primary storage)
        prefs.getString(fullKey, null)?.let { return it }
        
        // Fallback to file backup (secondary storage)
        return retrieveFromFileBackup(fullKey)
    }
    
    /**
     * Remove a value from both storages
     * 
     * @param key Storage key (will be prefixed)
     */
    fun remove(key: String) {
        val fullKey = prefix + key
        
        // Remove from SharedPreferences
        prefs.edit().remove(fullKey).apply()
        
        // Remove from file backup
        removeFromFileBackup(fullKey)
    }
    
    /**
     * Clear all keys with the current prefix from both storages
     */
    fun clear() {
        // Clear all keys with prefix from SharedPreferences
        val editor = prefs.edit()
        prefs.all.keys.filter { it.startsWith(prefix) }.forEach { editor.remove(it) }
        editor.apply()
        
        // Clear file backup
        clearFileBackup()
    }
    
    // MARK: - File Backup Methods (Secondary Storage)
    
    /**
     * Save value to file backup
     */
    private fun saveToFileBackup(key: String, value: String) {
        try {
            val file = File(backupDirectory, sanitizeFilename(key))
            file.writeText(value)
        } catch (e: Exception) {
            // Silently fail - backup is optional
            // Could log in debug mode if needed
        }
    }
    
    /**
     * Retrieve value from file backup
     */
    private fun retrieveFromFileBackup(key: String): String? {
        return try {
            val file = File(backupDirectory, sanitizeFilename(key))
            if (file.exists()) {
                file.readText()
            } else {
                null
            }
        } catch (e: Exception) {
            // File doesn't exist or can't be read
            null
        }
    }
    
    /**
     * Remove value from file backup
     */
    private fun removeFromFileBackup(key: String) {
        try {
            val file = File(backupDirectory, sanitizeFilename(key))
            if (file.exists()) {
                file.delete()
            }
        } catch (e: Exception) {
            // Silently fail
        }
    }
    
    /**
     * Clear all files in backup directory with the current prefix
     */
    private fun clearFileBackup() {
        try {
            val sanitizedPrefix = sanitizeFilename(prefix)
            backupDirectory.listFiles()?.forEach { file ->
                if (file.name.startsWith(sanitizedPrefix)) {
                    file.delete()
                }
            }
        } catch (e: Exception) {
            // Silently fail
        }
    }
    
    /**
     * Sanitize key for use as filename
     */
    private fun sanitizeFilename(key: String): String {
        // Replace characters that are invalid in filenames
        return key.replace("/", "_")
            .replace(":", "_")
            .replace("\\", "_")
    }
}
