import Foundation

/// Configuration for the Mobile Tracker SDK
/// Mirrors the web TrackerConfig interface
public struct TrackerConfig {
    /// Enable debug logging
    public var debug: Bool
    
    /// Backend API URL
    public var apiUrl: String?
    
    /// API key for authentication
    public var xApiKey: String?
    
    /// Enable cross-site cookie support
    public var crossSiteCookie: Bool
    
    /// Cookie domain for storage
    public var cookieDomain: String?
    
    /// Cookie expiration in days
    public var cookieExpiration: Int
    
    /// Default configuration
    public static let `default` = TrackerConfig(
        debug: false,
        apiUrl: nil,
        xApiKey: nil,
        crossSiteCookie: false,
        cookieDomain: nil,
        cookieExpiration: 365
    )
    
    public init(
        debug: Bool = false,
        apiUrl: String? = nil,
        xApiKey: String? = nil,
        crossSiteCookie: Bool = false,
        cookieDomain: String? = nil,
        cookieExpiration: Int = 365
    ) {
        self.debug = debug
        self.apiUrl = apiUrl
        self.xApiKey = xApiKey
        self.crossSiteCookie = crossSiteCookie
        self.cookieDomain = cookieDomain
        self.cookieExpiration = cookieExpiration
    }
}
