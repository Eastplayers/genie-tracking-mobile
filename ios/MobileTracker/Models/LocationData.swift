import Foundation

/// Location data for session tracking
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
}
