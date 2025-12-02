import Foundation

/// Environment selection for the tracker API
public enum Environment: String, Codable, CaseIterable {
    /// Quality Control/staging environment for testing
    case qc = "QC"
    
    /// Live production environment for real tracking
    case production = "Production"
    
    /// Display name for UI presentation
    public var displayName: String {
        self.rawValue
    }
}
