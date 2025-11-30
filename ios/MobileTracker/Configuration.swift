import Foundation

/// SDK configuration settings
public class Configuration {
    /// API key for authentication with the backend
    public let apiKey: String
    
    /// Backend endpoint URL where events are sent
    public let endpoint: String
    
    /// Maximum number of events to store in the queue
    public let maxQueueSize: Int
    
    public init(apiKey: String, endpoint: String, maxQueueSize: Int = 100) {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.maxQueueSize = maxQueueSize
    }
}
