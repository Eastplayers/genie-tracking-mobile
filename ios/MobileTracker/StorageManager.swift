import Foundation

/// StorageManager handles persistent storage with dual storage strategy
/// Primary: UserDefaults (similar to web cookies)
/// Secondary: File backup (similar to web localStorage)
class StorageManager {
    private let prefix: String
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let backupDirectory: URL
    
    /// Initialize StorageManager with a storage prefix
    /// - Parameter prefix: Storage key prefix in format "__GT_{brandId}_"
    init(prefix: String) {
        self.prefix = prefix
        
        // Create backup directory in app's documents directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.backupDirectory = documentsPath.appendingPathComponent("tracker_backup", isDirectory: true)
        
        // Ensure backup directory exists
        try? fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// Save a value to both primary (UserDefaults) and secondary (file backup) storage
    /// - Parameters:
    ///   - key: Storage key (will be prefixed)
    ///   - value: String value to store
    ///   - expires: Optional expiration in days (not enforced, for compatibility)
    func save(key: String, value: String, expires: Int? = nil) {
        let fullKey = prefix + key
        
        // Save to UserDefaults (primary storage)
        userDefaults.set(value, forKey: fullKey)
        userDefaults.synchronize()
        
        // Save to file backup (secondary storage)
        saveToFileBackup(key: fullKey, value: value)
    }
    
    /// Retrieve a value from storage, checking UserDefaults first, then file backup
    /// - Parameter key: Storage key (will be prefixed)
    /// - Returns: Stored value if found, nil otherwise
    func retrieve(key: String) -> String? {
        let fullKey = prefix + key
        
        // Try UserDefaults first (primary storage)
        if let value = userDefaults.string(forKey: fullKey) {
            return value
        }
        
        // Fallback to file backup (secondary storage)
        return retrieveFromFileBackup(key: fullKey)
    }
    
    /// Remove a value from both storages
    /// - Parameter key: Storage key (will be prefixed)
    func remove(key: String) {
        let fullKey = prefix + key
        
        // Remove from UserDefaults
        userDefaults.removeObject(forKey: fullKey)
        userDefaults.synchronize()
        
        // Remove from file backup
        removeFromFileBackup(key: fullKey)
    }
    
    /// Clear all keys with the current prefix from both storages
    func clear() {
        // Clear all keys with prefix from UserDefaults
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(prefix) {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        
        // Clear file backup
        clearFileBackup()
    }
    
    // MARK: - File Backup Methods (Secondary Storage)
    
    /// Save value to file backup
    private func saveToFileBackup(key: String, value: String) {
        let fileURL = backupDirectory.appendingPathComponent(sanitizeFilename(key))
        
        do {
            try value.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            // Silently fail - backup is optional
            if userDefaults.bool(forKey: "debug") {
                print("StorageManager: Failed to save to file backup: \(error)")
            }
        }
    }
    
    /// Retrieve value from file backup
    private func retrieveFromFileBackup(key: String) -> String? {
        let fileURL = backupDirectory.appendingPathComponent(sanitizeFilename(key))
        
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            // File doesn't exist or can't be read
            return nil
        }
    }
    
    /// Remove value from file backup
    private func removeFromFileBackup(key: String) {
        let fileURL = backupDirectory.appendingPathComponent(sanitizeFilename(key))
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Clear all files in backup directory with the current prefix
    private func clearFileBackup() {
        guard let files = try? fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        let sanitizedPrefix = sanitizeFilename(prefix)
        for fileURL in files {
            let filename = fileURL.lastPathComponent
            if filename.hasPrefix(sanitizedPrefix) {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    /// Sanitize key for use as filename
    private func sanitizeFilename(_ key: String) -> String {
        // Replace characters that are invalid in filenames
        return key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
    }
}
