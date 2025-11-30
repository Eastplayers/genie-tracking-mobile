import Foundation

/// Context information automatically added to all events
public struct EventContext: Codable {
    /// Platform identifier ("ios")
    public let platform: String
    
    /// Operating system version
    public let osVersion: String
    
    /// Application version (if available)
    public let appVersion: String?
    
    public init(platform: String, osVersion: String, appVersion: String?) {
        self.platform = platform
        self.osVersion = osVersion
        self.appVersion = appVersion
    }
}
