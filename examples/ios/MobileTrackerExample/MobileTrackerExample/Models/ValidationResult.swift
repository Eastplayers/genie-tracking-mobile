import Foundation

/// Result of configuration validation
public enum ValidationResult {
    /// Configuration is valid
    case valid
    
    /// Configuration is invalid with error message
    case error(String)
    
    /// Check if validation passed
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .error:
            return false
        }
    }
    
    /// Get error message if validation failed
    public var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .error(let message):
            return message
        }
    }
}
