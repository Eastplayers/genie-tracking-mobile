import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// API Client for backend communication
/// Mirrors the web ApiClient class from utils/api.ts
@available(iOS 13.0, macOS 10.15, *)
class ApiClient {
    private let config: TrackerConfig
    private let storagePrefix: String
    private let storage: StorageManager
    
    /// Initialize ApiClient with configuration and brand ID
    /// Web Reference: api.ts lines 14-19
    init(config: TrackerConfig, brandId: String) {
        self.config = config
        self.storagePrefix = "__GT_\(brandId)_"
        self.storage = StorageManager(prefix: storagePrefix)
    }
    
    // MARK: - HTTP Headers
    
    /// Get HTTP headers for API requests
    /// Web Reference: api.ts lines 21-35
    private func getHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        
        // Add x-api-key if provided
        if let xApiKey = config.xApiKey {
            headers["x-api-key"] = xApiKey
        }
        
        return headers
    }
    
    // MARK: - Storage Methods (Cookie-like interface)
    
    /// Get a value from storage (cookie-like interface)
    /// Web Reference: api.ts lines 37-50
    private func getCookie(_ name: String) -> String? {
        return storage.retrieve(key: name)
    }
    
    /// Write a value to storage (cookie-like interface)
    /// Web Reference: api.ts lines 52-105
    private func writeCookie(_ name: String, value: String, expires: Int? = nil, domain: String? = nil) {
        storage.save(key: name, value: value, expires: expires)
    }
    
    /// Clear a value from storage (cookie-like interface)
    /// Web Reference: api.ts lines 107-130
    private func clearCookie(_ name: String, domain: String? = nil) {
        storage.remove(key: name)
    }
    
    /// Clear all tracking cookies and storage
    /// Web Reference: api.ts lines 132-148
    func clearAllTrackingCookies() {
        let cookiesToClear = ["device_id", "session_id", "session_email", "identify_id"]
        
        for cookieName in cookiesToClear {
            clearCookie(cookieName)
        }
        
        if config.debug {
            print("[ApiClient] All tracking cookies cleared")
        }
    }
    
    // MARK: - Device ID Methods
    
    /// Generate a UUID for device identification
    /// Web Reference: api.ts lines 175-184
    private func generateUUID() -> String {
        return UUID().uuidString
    }
    
    /// Detect the operating system name
    /// Web Reference: api.ts lines 186-199
    private func detectOS() -> String {
        #if canImport(UIKit)
        return UIDevice.current.systemName
        #else
        return "iOS"
        #endif
    }
    
    /// Get the current device ID from storage
    /// Web Reference: api.ts line 231
    func getDeviceId() -> String? {
        return getCookie("device_id")
    }
    
    /// Generate and save a new device ID
    /// Web Reference: api.ts lines 233-235
    func writeDeviceId() async -> String {
        let deviceId = generateUUID()
        writeCookie("device_id", value: deviceId, expires: 365, domain: config.cookieDomain)
        return deviceId
    }
    
    /// Collect device information for tracking
    /// Web Reference: api.ts lines 225-249
    func getDeviceInfo() async -> DeviceInfo {
        let osName = detectOS()
        
        // Get or generate device ID
        var deviceId = getCookie("device_id")
        if deviceId == nil {
            deviceId = generateUUID()
            writeCookie("device_id", value: deviceId!, expires: 365, domain: config.cookieDomain)
        }
        
        // Detect device type based on user interface idiom
        let deviceType: String
        #if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            deviceType = "Mobile"
        case .pad:
            deviceType = "Tablet"
        default:
            deviceType = "Mobile"
        }
        #else
        deviceType = "Mobile"
        #endif
        
        return DeviceInfo(
            deviceId: deviceId!,
            osName: osName,
            deviceType: deviceType
        )
    }
    
    // MARK: - Session Methods
    
    /// Create a new tracking session with the backend
    /// Web Reference: api.ts lines 251-291
    func createTrackingSession(_ brandId: Int) async -> String? {
        do {
            let deviceData = await getDeviceInfo()
            
            // Build payload matching web structure
            let payload: [String: Any] = [
                "device_id": deviceData.deviceId,
                "os_name": deviceData.osName,
                "device_type": deviceData.deviceType,
                "brand_id": brandId
            ]
            
            guard let apiUrl = config.apiUrl else {
                if config.debug {
                    print("[ApiClient] Error: API URL not configured")
                }
                return nil
            }
            
            guard let url = URL(string: "\(apiUrl)/v2/tracking-session") else {
                if config.debug {
                    print("[ApiClient] Error: Invalid API URL")
                }
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = getHeaders()
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            if config.debug {
                print("[ApiClient] Creating session: POST \(url)")
                print("[ApiClient] Payload: \(payload)")
                print("[ApiClient] Headers: \(getHeaders())")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                if config.debug {
                    print("[ApiClient] Error: Invalid HTTP response")
                }
                throw NSError(domain: "ApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
            }
            
            // Accept both 200 (OK) and 201 (Created) as success
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                if config.debug {
                    print("[ApiClient] Error: HTTP \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("[ApiClient] Response: \(responseString)")
                    }
                }
                throw NSError(domain: "ApiClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
            }
            
            if config.debug {
                print("[ApiClient] ✅ Session created successfully")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("[ApiClient] Response: \(responseString)")
                }
            }
            
            // Parse response to extract session ID
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let sessionId = dataDict["id"] as? String {
                
                // Save session ID to storage
                writeCookie("session_id", value: sessionId, expires: 365, domain: config.cookieDomain)
                
                // Request location update (async, non-blocking)
                Task {
                    await requestLocationUpdate(sessionId)
                }
                
                return sessionId
            }
            
            return nil
        } catch {
            if config.debug {
                print("[ApiClient] Error creating tracking session: \(error)")
            }
            return nil
        }
    }
    
    /// Request location update for a session
    /// Web Reference: api.ts lines 300-322
    private func requestLocationUpdate(_ sessionId: String) async {
        let locationManager = LocationManager(apiClient: self, config: config)
        await locationManager.requestLocationUpdate(sessionId)
    }
    
    /// Update session location
    /// Web Reference: api.ts lines 348-362
    func updateSessionLocation(_ sessionId: String, location: LocationData) async -> Bool {
        do {
            guard let apiUrl = config.apiUrl else {
                return false
            }
            
            guard let url = URL(string: "\(apiUrl)/v2/tracking-session/\(sessionId)/location") else {
                return false
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = getHeaders()
            request.httpBody = try JSONEncoder().encode(location)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            if config.debug {
                print("[ApiClient] Session location updated successfully")
            }
            
            return true
        } catch {
            if config.debug {
                print("[ApiClient] Error updating session location: \(error)")
            }
            return false
        }
    }
    
    /// Update session email
    /// Web Reference: api.ts lines 324-346
    func updateSessionEmail(_ sessionId: String, newEmail: String, brandId: Int) async -> String? {
        do {
            guard let apiUrl = config.apiUrl else {
                return nil
            }
            
            guard let url = URL(string: "\(apiUrl)/v2/tracking-session/\(sessionId)/email_v2") else {
                return nil
            }
            
            let payload: [String: Any] = [
                "email": newEmail,
                "brand_id": brandId
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = getHeaders()
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Save email to storage
            writeCookie("session_email", value: newEmail, expires: 365, domain: config.cookieDomain)
            
            // Check if we got a new session ID
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let newSessionId = dataDict["id"] as? String,
               newSessionId != sessionId {
                
                writeCookie("session_id", value: newSessionId, expires: 365, domain: config.cookieDomain)
                return newSessionId
            }
            
            return sessionId
        } catch {
            if config.debug {
                print("[ApiClient] Error updating session email: \(error)")
            }
            return nil
        }
    }
    
    // MARK: - Profile and Metadata Methods
    
    /// Update user profile
    /// Web Reference: api.ts lines 367-410
    func updateProfile(_ data: [String: Any], brandId: Int) async -> Bool {
        do {
            let identifyId = getCookie("identify_id")
            let userId = data["user_id"] as? String
            let sessionId = getCookie("session_id")
            
            // If user_id differs from stored identify_id, call identifyById first
            if let userId = userId, let sessionId = sessionId, identifyId != userId {
                _ = await identifyById(sessionId: sessionId, userId: userId)
            }
            
            guard let apiUrl = config.apiUrl else {
                return false
            }
            
            guard let url = URL(string: "\(apiUrl)/v1/customer-profiles/set") else {
                return false
            }
            
            // Build payload matching web structure
            var payload: [String: Any] = [
                "brand_id": brandId
            ]
            
            // Add all profile fields
            if let email = data["email"] { payload["email"] = email }
            if let name = data["name"] { payload["name"] = name }
            if let phone = data["phone"] { payload["phone"] = phone }
            if let gender = data["gender"] { payload["gender"] = gender }
            if let businessDomain = data["business_domain"] { payload["business_domain"] = businessDomain }
            if let metadata = data["metadata"] { payload["metadata"] = metadata }
            if let source = data["source"] { payload["source"] = source }
            if let birthday = data["birthday"] { payload["birthday"] = birthday }
            if let userId = userId { payload["user_id"] = userId }
            if let sessionId = sessionId { payload["session_id"] = sessionId }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = getHeaders()
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            if config.debug {
                print("[ApiClient] Customer profile updated successfully")
            }
            
            return true
        } catch {
            if config.debug {
                print("[ApiClient] Error updating customer profile: \(error)")
            }
            return false
        }
    }
    
    /// Set metadata for session context
    /// Web Reference: api.ts lines 412-450
    func setMetadata(_ metadata: [String: Any], brandId: Int) async -> Bool {
        let sessionId = getCookie("session_id")
        let userId = getCookie("identify_id")
        
        // Check if we have session_id or user_id
        if sessionId == nil && userId == nil {
            if config.debug {
                print("[ApiClient] No session_id or user_id available for metadata update")
            }
            return false
        }
        
        do {
            guard let apiUrl = config.apiUrl else {
                return false
            }
            
            guard let url = URL(string: "\(apiUrl)/v1/customer-profiles/set") else {
                return false
            }
            
            var payload: [String: Any] = [
                "metadata": metadata,
                "brand_id": brandId
            ]
            
            if let userId = userId { payload["user_id"] = userId }
            if let sessionId = sessionId { payload["session_id"] = sessionId }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = getHeaders()
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            if config.debug {
                print("[ApiClient] Metadata updated successfully")
            }
            
            return true
        } catch {
            if config.debug {
                print("[ApiClient] Error updating metadata: \(error)")
            }
            return false
        }
    }
    
    /// Identify user by ID
    /// Web Reference: api.ts lines 530-568
    func identifyById(sessionId: String, userId: String) async -> String? {
        do {
            guard let apiUrl = config.apiUrl else {
                return nil
            }
            
            guard let url = URL(string: "\(apiUrl)/v2/tracking-session/\(sessionId)/identify/\(userId)") else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = getHeaders()
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Save identify_id to storage
            writeCookie("identify_id", value: userId, expires: 365, domain: config.cookieDomain)
            
            // Check if we got a new session ID
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let newSessionId = dataDict["id"] as? String,
               newSessionId != sessionId {
                
                writeCookie("session_id", value: newSessionId, expires: 365, domain: config.cookieDomain)
                return newSessionId
            }
            
            return sessionId
        } catch {
            if config.debug {
                print("[ApiClient] Error identifying user: \(error)")
            }
            return nil
        }
    }
    
    // MARK: - Event Tracking
    
    /// Track an event
    /// Web Reference: api.ts lines 452-486
    func trackEvent(_ brandId: Int, sessionId: String, eventName: String, eventData: [String: Any]?) async -> Bool {
        do {
            guard let apiUrl = config.apiUrl else {
                if config.debug {
                    print("[ApiClient] Error: API URL not configured")
                }
                return false
            }
            
            guard let url = URL(string: "\(apiUrl)/v2/tracking-session-data") else {
                if config.debug {
                    print("[ApiClient] Error: Invalid API URL")
                }
                return false
            }
            
            // Build payload matching web structure
            var payload: [String: Any] = [
                "brand_id": brandId,
                "session_id": sessionId,
                "event_name": eventName
            ]
            
            if let eventData = eventData {
                payload["data"] = eventData
            }
            
            // Add flow_context for non-VIEW_PAGE events (matching web behavior)
            // Web Reference: api.ts lines 508-510
            if eventName != "VIEW_PAGE" {
                payload["flow_context"] = [
                    "url": "",  // iOS doesn't have window.location.href
                    "room_id": NSNull()  // iOS doesn't have sessionStorage
                ]
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = getHeaders()
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            if config.debug {
                print("[ApiClient] Tracking event '\(eventName)': POST \(url)")
                print("[ApiClient] Headers: \(getHeaders())")
                print("[ApiClient] Payload: \(payload)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                if config.debug {
                    print("[ApiClient] Error: Invalid HTTP response for event '\(eventName)'")
                }
                return false
            }
            
            // Accept both 200 and 201 as success
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                if config.debug {
                    print("[ApiClient] Error: HTTP \(httpResponse.statusCode) for event '\(eventName)'")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("[ApiClient] Response: \(responseString)")
                    }
                }
                return false
            }
            
            if config.debug {
                print("[ApiClient] Event tracked successfully: \(eventName)")
            }
            
            return true
        } catch {
            if config.debug {
                print("[ApiClient] Error tracking event: \(error)")
            }
            return false
        }
    }
    
    // MARK: - Storage Helper Methods
    
    /// Get session ID from storage
    /// Web Reference: api.ts lines 488-490
    func getSessionId() -> String? {
        return getCookie("session_id")
    }
    
    /// Set session ID in storage
    /// Web Reference: api.ts lines 492-496
    func setSessionId(_ sessionId: String) {
        writeCookie("session_id", value: sessionId, expires: 365, domain: config.cookieDomain)
    }
    
    /// Get session email from storage
    /// Web Reference: api.ts lines 498-500
    func getSessionEmail() -> String? {
        return getCookie("session_email")
    }
    
    /// Get brand ID from storage
    /// Web Reference: api.ts lines 502-511
    func getBrandId() -> Int? {
        if let brandIdStr = getCookie("brand_id"),
           let brandId = Int(brandIdStr) {
            return brandId
        }
        return nil
    }
    
    /// Set brand ID in storage
    /// Web Reference: api.ts lines 513-517
    func setBrandId(_ brandId: Int) {
        writeCookie("brand_id", value: String(brandId), expires: 365, domain: config.cookieDomain)
    }
}
