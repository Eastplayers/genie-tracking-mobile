import Foundation

/// Manages user identification data
public class UserContext {
    /// Current user identifier
    public var userId: String?
    
    /// User traits/attributes
    public var traits: [String: Any]?
    
    public init() {
        self.userId = nil
        self.traits = nil
    }
    
    /// Update user identification
    public func update(userId: String, traits: [String: Any]?) {
        self.userId = userId
        self.traits = traits
    }
    
    /// Clear user identification
    public func clear() {
        self.userId = nil
        self.traits = nil
    }
}
