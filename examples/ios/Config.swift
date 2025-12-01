import Foundation

/// Configuration helper to load environment variables
/// This reads from environment variables set in Xcode scheme or system
struct Config {
    /// Default API URL
    static let defaultApiUrl = "https://tracking.api.founder-os.ai/api"
    
    /// Get configuration value from environment
    static func get(_ key: String, default defaultValue: String = "") -> String {
        // Try to get from ProcessInfo (environment variables)
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }
        
        // Try to get from Info.plist
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty {
            return value
        }
        
        return defaultValue
    }
    
    /// Brand ID for tracking (REQUIRED)
    static var brandId: String {
        get("BRAND_ID", default: "")
    }
    
    /// API URL for tracking backend (optional, defaults to production URL)
    static var apiUrl: String? {
        let value = get("API_URL", default: "")
        return value.isEmpty ? nil : value
    }
    
    /// API key for authenticated requests (REQUIRED)
    static var xApiKey: String? {
        let value = get("X_API_KEY", default: "")
        return value.isEmpty ? nil : value
    }
    
    /// Debug mode flag
    static var debug: Bool {
        get("DEBUG", default: "false").lowercased() == "true"
    }
    
    /// Validate that required configuration is present
    static func validate() throws {
        guard !brandId.isEmpty else {
            throw ConfigError.missingValue("BRAND_ID is required")
        }
        
        guard xApiKey != nil else {
            throw ConfigError.missingValue("X_API_KEY is required")
        }
        
        // API URL is optional, will use default if not provided
        if let url = apiUrl, !url.isEmpty {
            guard URL(string: url) != nil else {
                throw ConfigError.invalidValue("API_URL is not a valid URL")
            }
        }
    }
}

enum ConfigError: Error, LocalizedError {
    case missingValue(String)
    case invalidValue(String)
    
    var errorDescription: String? {
        switch self {
        case .missingValue(let message):
            return "Configuration Error: \(message)"
        case .invalidValue(let message):
            return "Configuration Error: \(message)"
        }
    }
}
