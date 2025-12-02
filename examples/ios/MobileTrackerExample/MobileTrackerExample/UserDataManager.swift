import Foundation

/// Manages persistence of user data (userId, name, email) across app sessions
/// 
/// Stores user information in UserDefaults so it can be restored when the app reopens,
/// unless the user explicitly resets the session or all data.
struct UserDataManager {
    private static let prefsName = "user_data_prefs"
    private static let keyUserId = "user_id"
    private static let keyUserName = "user_name"
    private static let keyUserEmail = "user_email"
    
    /// Save user data to UserDefaults
    static func saveUserData(userId: String, name: String, email: String) {
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: keyUserId)
        defaults.set(name, forKey: keyUserName)
        defaults.set(email, forKey: keyUserEmail)
    }
    
    /// Load user data from UserDefaults
    static func loadUserData() -> UserData? {
        let defaults = UserDefaults.standard
        
        guard let userId = defaults.string(forKey: keyUserId) else {
            return nil
        }
        
        let name = defaults.string(forKey: keyUserName) ?? ""
        let email = defaults.string(forKey: keyUserEmail) ?? ""
        
        return UserData(userId: userId, name: name, email: email)
    }
    
    /// Clear user data from UserDefaults
    static func clearUserData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: keyUserId)
        defaults.removeObject(forKey: keyUserName)
        defaults.removeObject(forKey: keyUserEmail)
    }
}

/// Data structure for user information
struct UserData {
    let userId: String
    let name: String
    let email: String
}
