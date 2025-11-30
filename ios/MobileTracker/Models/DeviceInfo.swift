import Foundation

/// Device information for tracking sessions
struct DeviceInfo: Codable {
    let deviceId: String
    let osName: String
    let deviceType: String
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case osName = "os_name"
        case deviceType = "device_type"
    }
}
