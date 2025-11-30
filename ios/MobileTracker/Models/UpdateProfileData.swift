import Foundation

/// Profile data for user identification and updates
/// Note: This is a simple data structure for API payloads
/// We don't use Codable here since we build JSON manually in ApiClient
struct UpdateProfileData {
    var name: String?
    var phone: String?
    var gender: String?
    var businessDomain: String?
    var metadata: [String: Any]?
    var email: String?
    var source: String?
    var birthday: String?
    var userId: String?
}
