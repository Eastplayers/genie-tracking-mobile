import Foundation

/// Configuration for the MobileTracker SDK with environment selection
/// Used by the configuration UI to allow users to input credentials
public struct TrackerConfiguration: Codable {
    /// API key for authentication (X-API-KEY header)
    public let apiKey: String
    
    /// Brand ID for tracking
    public let brandId: String
    
    /// User ID (optional, for convenience during testing)
    public let userId: String
    
    /// Selected environment (QC or Production)
    public let environment: Environment
    
    /// Computed property that maps environment to the correct API URL
    public var apiUrl: String {
        switch environment {
        case .qc:
            return "https://tracking.api.qc.founder-os.ai/api"
        case .production:
            return "https://tracking.api.founder-os.ai/api"
        }
    }
    
    /// Initialize a new TrackerConfiguration
    public init(
        apiKey: String,
        brandId: String,
        userId: String = "",
        environment: Environment = .qc
    ) {
        self.apiKey = apiKey
        self.brandId = brandId
        self.userId = userId
        self.environment = environment
    }
    
    /// Validate the configuration
    /// Returns ValidationResult.valid if configuration is valid
    /// Returns ValidationResult.error with message if configuration is invalid
    public func validate() -> ValidationResult {
        if apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("API Key is required")
        }
        if brandId.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("Brand ID is required")
        }
        return .valid
    }
}
