import Foundation

/// Represents a tracking event with all associated data
public struct Event: Codable {
    /// Event type: "track", "identify", or "screen"
    public let type: String
    
    /// Event name (for track and screen events)
    public let name: String?
    
    /// User identifier (if user has been identified)
    public let userId: String?
    
    /// User traits (for identify events or after identification)
    public let traits: [String: AnyCodable]?
    
    /// Event properties (for track and screen events)
    public let properties: [String: AnyCodable]?
    
    /// Automatic context data
    public let context: EventContext
    
    /// ISO 8601 formatted timestamp
    public let timestamp: String
    
    public init(
        type: String,
        name: String?,
        userId: String?,
        traits: [String: Any]?,
        properties: [String: Any]?,
        context: EventContext,
        timestamp: String
    ) {
        self.type = type
        self.name = name
        self.userId = userId
        self.traits = traits?.mapValues { AnyCodable($0) }
        self.properties = properties?.mapValues { AnyCodable($0) }
        self.context = context
        self.timestamp = timestamp
    }
}

/// Type-erased wrapper for encoding/decoding arbitrary JSON values
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode value"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to encode value of type \(type(of: value))"
                )
            )
        }
    }
}
