import Foundation

#if os(iOS)
import UIKit
#endif

/// Main SDK class providing the public API for event tracking
/// Mirrors the web FounderOS class from tracker.ts
@available(iOS 13.0, macOS 10.15, *)
@objc public class MobileTracker: NSObject {
    // MARK: - Singleton
    
    /// Shared singleton instance
    /// Web Reference: tracker.ts line 665
    @objc public static let shared = MobileTracker()
    
    // MARK: - Properties (matching web tracker.ts lines 39-47)
    
    /// SDK configuration with defaults
    /// Web Reference: tracker.ts line 39
    private var config: TrackerConfig = TrackerConfig.default
    
    /// API client for backend communication
    /// Web Reference: tracker.ts line 40
    private var apiClient: ApiClient?
    
    /// Brand ID for the application
    /// Web Reference: tracker.ts line 41
    private var brandId: String = ""
    
    /// Whether SDK is initialized
    /// Web Reference: tracker.ts line 42
    private var initialized: Bool = false
    
    /// Whether initialization is in progress
    /// Web Reference: tracker.ts line 43
    private var isInitPending: Bool = false
    
    /// Promise for initialization completion
    /// Web Reference: tracker.ts line 44
    private var initPromise: Task<Void, Error>?
    
    /// Timeout for initialization
    private var initTimeout: DispatchWorkItem?
    
    /// Queue of pending track calls before initialization completes
    /// Web Reference: tracker.ts line 46
    private var pendingTrackCalls: [(String, [String: Any]?, [String: Any]?)] = []
    
    /// Last tracked URL for page view tracking
    /// Web Reference: tracker.ts line 47
    fileprivate var lastTrackedUrl: String?
    
    /// Track if initialization has failed permanently
    private var initializationFailed: Bool = false
    
    /// Maximum number of pending events to prevent memory issues
    private let MAX_PENDING_EVENTS = 100
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public API
    
    /// Initialize the tracker with brand ID and configuration
    /// Web Reference: tracker.ts lines 56-104
    /// - Parameters:
    ///   - brandId: Your brand ID (string or number)
    ///   - config: Configuration options
    public func initialize(brandId: String, config: TrackerConfig? = nil) async throws {
        // If already initialized, return immediately (web: lines 63-68)
        if initialized {
            if self.config.debug {
                print("[MobileTracker] Already initialized")
            }
            return
        }
        
        // If initialization is already in progress, wait for it to complete (web: lines 70-77)
        if isInitPending, let promise = initPromise {
            if self.config.debug {
                print("[MobileTracker] Initialization already in progress, waiting...")
            }
            try await promise.value
            return
        }
        
        // Set pending state (web: line 80)
        isInitPending = true
        
        // Create 30-second timeout (web: lines 82-89)
        let timeoutItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.config.debug {
                print("[MobileTracker] Initialization timeout - resetting state")
            }
            self.isInitPending = false
            self.initPromise = nil
        }
        initTimeout = timeoutItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutItem)
        
        // Create and store the initialization promise (web: line 92)
        let task = Task {
            try await performInitialization(brandId: brandId, config: config)
        }
        initPromise = task
        
        do {
            try await task.value
            // Clear timeout if initialization completes normally (web: lines 96-99)
            if let timeout = initTimeout {
                timeout.cancel()
                initTimeout = nil
            }
        } catch {
            // Clear timeout on error too
            if let timeout = initTimeout {
                timeout.cancel()
                initTimeout = nil
            }
            throw error
        }
    }
    
    /// Perform the actual initialization logic
    /// Web Reference: tracker.ts lines 106-172
    private func performInitialization(brandId: String, config: TrackerConfig?) async throws {
        do {
            // Validate brandId is non-empty (web: lines 112-114)
            guard !brandId.isEmpty else {
                throw TrackerError.invalidBrandId("Brand ID is required")
            }
            
            // Validate brandId is numeric (web: lines 116-118)
            guard Int(brandId) != nil else {
                throw TrackerError.invalidBrandId("Brand ID must be a number")
            }
            
            // Store brandId (web: line 121)
            self.brandId = brandId
            
            // Merge config with defaults (web: line 122)
            if let providedConfig = config {
                self.config = providedConfig
            } else {
                self.config = TrackerConfig.default
            }
            
            // Validate config (web: lines 124-128)
            try validateConfig(self.config)
            
            // Create ApiClient instance (web: lines 131-132)
            self.apiClient = ApiClient(config: self.config, brandId: brandId)
            
            // Set brandId on ApiClient (web: line 133)
            if let brandIdInt = Int(brandId) {
                self.apiClient?.setBrandId(brandIdInt)
            }
            
            // Mark as initialized immediately to allow tracking to start (web: line 136)
            self.initialized = true
            
            if self.config.debug {
                print("[MobileTracker] Fast initialization completed - loading session in background")
            }
            
            // Initialize all background services without blocking (web: lines 147-149)
            Task {
                await initializeBackgroundServices()
            }
            
            // Create session asynchronously in background (web: lines 179-218)
            Task {
                await createSessionAsync()
            }
        } catch {
            // Catch errors gracefully, never crash (web: lines 150-155)
            initializationFailed = true
            if self.config.debug {
                print("[MobileTracker] ❌ Initialization failed: \(error)")
            }
            // DO NOT re-throw error to prevent crashing the embedding app
        }
        
        // Set isInitPending = false in finally (web: line 157)
        defer {
            isInitPending = false
        }
        
        // Flush pending track calls (web: lines 159-161)
        if initialized {
            await flushPendingTrackCalls()
        } else if initializationFailed && self.config.debug {
            // Clear pending events if initialization failed
            if !pendingTrackCalls.isEmpty {
                print("[MobileTracker] ⚠️ Discarding \(pendingTrackCalls.count) pending events due to initialization failure")
                pendingTrackCalls.removeAll()
            }
        }
    }
    
    /// Validate configuration
    private func validateConfig(_ config: TrackerConfig) throws {
        // Basic validation - can be extended as needed
        if let apiUrl = config.apiUrl, !apiUrl.isEmpty {
            guard URL(string: apiUrl) != nil else {
                throw TrackerError.invalidConfig("Invalid API URL")
            }
        }
    }
    
    /// Initialize background services (page tracking, etc.)
    /// Web Reference: tracker.ts lines 174-177
    private func initializeBackgroundServices() async {
        // Setup page view tracking
        setupPageViewTracking()
    }
    
    /// Check if tracking operations are allowed based on consent
    /// Web Reference: tracker.ts lines 179-182
    private func isTrackingAllowed() -> Bool {
        // For now, always return true
        // In future, integrate with iOS App Tracking Transparency
        return true
    }
    
    /// Create tracking session asynchronously without blocking
    /// Web Reference: tracker.ts lines 184-218
    private func createSessionAsync() async {
        guard let apiClient = apiClient, !brandId.isEmpty else { return }
        
        // Check for existing session
        var sessionId = apiClient.getSessionId()
        
        if sessionId == nil {
            // Create new session in background
            if let brandIdInt = Int(brandId) {
                sessionId = await apiClient.createTrackingSession(brandIdInt)
                
                if config.debug {
                    print("[MobileTracker] Session created asynchronously: \(sessionId != nil ? "success" : "failed")")
                }
                
                // Flush any pending events now that session exists
                if sessionId != nil && !pendingTrackCalls.isEmpty {
                    await flushPendingTrackCalls()
                    if config.debug {
                        print("[MobileTracker] Flushed pending track calls after session creation")
                    }
                }
            }
        }
    }
    
    /// Track an event with optional attributes and metadata
    /// Web Reference: tracker.ts lines 280-346
    /// - Parameters:
    ///   - eventName: The name of the event (e.g., 'BUTTON_CLICK', 'PAGE_VIEW')
    ///   - attributes: Event properties
    ///   - metadata: Technical metadata
    public func track(eventName: String, attributes: [String: Any]? = nil, metadata: [String: Any]? = nil) async {
        // If initialization failed, don't queue events
        if initializationFailed {
            if config.debug {
                print("[MobileTracker] ⚠️ Cannot track event '\(eventName)' - initialization failed")
            }
            return
        }
        
        // If init pending, queue event (web: lines 287-290)
        if isInitPending {
            if pendingTrackCalls.count < MAX_PENDING_EVENTS {
                pendingTrackCalls.append((eventName, attributes, metadata))
                if config.debug {
                    print("[MobileTracker] Initialization pending - queuing event: \(eventName)")
                }
            } else if config.debug {
                print("[MobileTracker] ⚠️ Event queue full - dropping event: \(eventName)")
            }
            return
        }
        
        // If not initialized, warn and return (web: lines 292-297)
        guard initialized, let apiClient = apiClient else {
            if config.debug {
                print("[MobileTracker] ⚠️ Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Get sessionId from apiClient (web: line 299)
        let sessionId = apiClient.getSessionId()
        
        // Get brandId from apiClient (web: line 300)
        let brandId = apiClient.getBrandId()
        
        if sessionId == nil {
            // Queue the event if session is missing but tracker is initialized (web: lines 302-309)
            if pendingTrackCalls.count < MAX_PENDING_EVENTS {
                pendingTrackCalls.append((eventName, attributes, metadata))
                if config.debug {
                    print("[MobileTracker] Missing session ID - queuing event: \(eventName)")
                }
            } else if config.debug {
                print("[MobileTracker] ⚠️ Event queue full - dropping event: \(eventName)")
            }
            return
        }
        
        // Additional consent check for tracking (web: lines 311-316)
        if !isTrackingAllowed() {
            if config.debug {
                print("[MobileTracker] Event blocked - consent not granted: \(eventName)")
            }
            return
        }
        
        guard let sessionId = sessionId else { return }
        guard let brandId = brandId else {
            if config.debug {
                print("[MobileTracker] Missing brand ID")
            }
            return
        }
        
        // Merge attributes and metadata (web: line 323)
        var eventData: [String: Any] = [:]
        if let attributes = attributes {
            eventData.merge(attributes) { _, new in new }
        }
        if let metadata = metadata {
            eventData.merge(metadata) { _, new in new }
        }
        
        // Call apiClient.trackEvent() (web: line 326)
        let success = await apiClient.trackEvent(brandId, sessionId: sessionId, eventName: eventName, eventData: eventData.isEmpty ? nil : eventData)
        
        // Log success/error in debug mode (web: lines 328-334)
        if config.debug {
            if success {
                print("[MobileTracker] Event tracked: \(eventName), \(attributes ?? [:])")
            } else {
                print("[MobileTracker] Error tracking event: \(eventName)")
            }
        }
    }
    

    
    /// Identify a user with their ID and profile data
    /// Web Reference: tracker.ts lines 348-379
    /// - Parameters:
    ///   - userId: Unique user identifier
    ///   - profileData: User profile information
    public func identify(userId: String, profileData: [String: Any]? = nil) async {
        // Check if initialized (web: lines 349-354)
        guard initialized, apiClient != nil else {
            if config.debug {
                print("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Check consent before sending user data (web: lines 356-362)
        if !isTrackingAllowed() {
            if config.debug {
                print("[MobileTracker] identify() blocked - consent not granted")
            }
            return
        }
        
        // Validate user_id is not empty (web: lines 364-369)
        guard !userId.isEmpty else {
            if config.debug {
                print("[MobileTracker] user_id is required for identify()")
            }
            return
        }
        
        // Call updateProfile() with combined data (web: lines 371-373)
        if let profileData = profileData {
            var data = profileData
            data["user_id"] = userId
            await updateProfile(data: data)
        } else {
            await updateProfile(data: ["user_id": userId])
        }
    }
    

    
    /// Update user profile with new data
    /// Web Reference: tracker.ts lines 381-403
    /// - Parameter profileData: Profile data to update
    public func set(profileData: [String: Any]) async {
        // Check if initialized (web: lines 382-387)
        guard initialized, apiClient != nil else {
            if config.debug {
                print("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Check consent before sending user data (web: lines 389-395)
        if !isTrackingAllowed() {
            if config.debug {
                print("[MobileTracker] set() blocked - consent not granted")
            }
            return
        }
        
        // Call updateProfile() with data (web: line 397)
        await updateProfile(data: profileData)
    }
    
    /// Objective-C compatible wrapper for set (synchronous wrapper for async method)
    @objc public func setProfileDataSync(_ profileData: [String: Any]) {
        Task {
            await set(profileData: profileData)
        }
    }
    
    /// Update user profile with detailed data (internal method)
    /// Web Reference: tracker.ts lines 405-424
    private func updateProfile(data: [String: Any]) async {
        guard initialized, let apiClient = apiClient else {
            if config.debug {
                print("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        guard let brandId = apiClient.getBrandId() else {
            if config.debug {
                print("[MobileTracker] No brand_id available")
            }
            return
        }
        
        do {
            let success = await apiClient.updateProfile(data, brandId: brandId)
            
            if config.debug {
                if success {
                    print("[MobileTracker] Profile updated successfully")
                } else {
                    print("[MobileTracker] Error updating profile")
                }
            }
        }
    }
    

    
    /// Set metadata for tracking context
    /// Web Reference: tracker.ts lines 426-461
    /// - Parameter metadata: Metadata object
    public func setMetadata(_ metadata: [String: Any]) async {
        // Check if initialized (web: lines 427-432)
        guard initialized, let apiClient = apiClient else {
            if config.debug {
                print("[MobileTracker] Not initialized. Call initialize() first.")
            }
            return
        }
        
        // Check consent before sending metadata (web: lines 434-440)
        if !isTrackingAllowed() {
            if config.debug {
                print("[MobileTracker] setMetadata() blocked - consent not granted")
            }
            return
        }
        
        // Get brandId from apiClient (web: lines 442-448)
        guard let brandId = apiClient.getBrandId() else {
            if config.debug {
                print("[MobileTracker] No brand_id available")
            }
            return
        }
        
        // Call apiClient.setMetadata() (web: line 450)
        let success = await apiClient.setMetadata(metadata, brandId: brandId)
        
        // Log success/error in debug mode (web: lines 452-458)
        if config.debug {
            if success {
                print("[MobileTracker] Metadata set successfully")
            } else {
                print("[MobileTracker] Error setting metadata")
            }
        }
    }
    
    /// Objective-C compatible wrapper for setMetadata (synchronous wrapper for async method)
    @objc public func setMetadataSync(_ metadata: [String: Any]) {
        Task {
            await setMetadata(metadata)
        }
    }
    

    
    /// Reset tracker state and clear all stored data
    /// Web Reference: tracker.ts lines 463-502
    /// - Parameter all: If true, also clear brand_id
    @objc public func reset(all: Bool = false) {
        guard let apiClient = apiClient else { return }
        
        // Clear all tracking cookies (web: lines 469-479)
        let cookiesToClear = ["session_id", "device_id", "session_email", "identify_id"]
        
        // If all=true, also clear brand_id (web: lines 470-472)
        var allCookies = cookiesToClear
        if all {
            allCookies.append("brand_id")
        }
        
        // Clear each cookie individually (web: lines 473-477)
        for cookie in allCookies {
            apiClient.clearCookieByName(cookie)
        }
        
        // Clear file backup items with brand prefix (web: lines 482-489)
        // This is handled by the StorageManager's clear() method
        
        // Reset internal state: isInitPending, pendingTrackCalls, lastTrackedUrl (web: lines 492-494)
        isInitPending = false
        initializationFailed = false
        pendingTrackCalls = []
        lastTrackedUrl = nil
        
        // Create new tracking session (web: lines 495-497)
        if !brandId.isEmpty, let brandIdInt = Int(brandId) {
            Task {
                _ = await apiClient.createTrackingSession(brandIdInt)
            }
        }
        
        // Log completion in debug mode (web: lines 499-501)
        if config.debug {
            print("[MobileTracker] Reset completed")
        }
    }
    
    // MARK: - Private Methods
    
    /// Flush pending track calls
    /// Web Reference: tracker.ts lines 619-623
    private func flushPendingTrackCalls() async {
        if config.debug && !pendingTrackCalls.isEmpty {
            print("[MobileTracker] Flushing \(pendingTrackCalls.count) pending events")
        }
        
        // Create a copy to avoid infinite loop if track() re-queues events
        let eventsToFlush = pendingTrackCalls
        pendingTrackCalls.removeAll()
        
        for (eventName, attributes, metadata) in eventsToFlush {
            await track(eventName: eventName, attributes: attributes, metadata: metadata)
        }
    }
    
    /// Setup automatic page view tracking
    /// Web Reference: tracker.ts lines 625-662 (adapted for iOS)
    private func setupPageViewTracking() {
        #if os(iOS)
        // Track initial VIEW_PAGE event (web: lines 631-632)
        let initialScreen = getCurrentScreenName()
        Task {
            await track(eventName: "VIEW_PAGE", attributes: ["url": initialScreen])
        }
        
        // Store lastTrackedUrl (web: line 633)
        lastTrackedUrl = initialScreen
        
        // Swizzle UIViewController viewDidAppear to detect screen changes
        swizzleViewDidAppear()
        #endif
    }
    
    #if os(iOS)
    /// Get current screen name
    private func getCurrentScreenName() -> String {
        if let topViewController = UIApplication.shared.windows.first?.rootViewController {
            return getTopViewController(from: topViewController).description
        }
        return "Unknown"
    }
    
    /// Get the top-most view controller
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return getTopViewController(from: presented)
        }
        if let navigation = viewController as? UINavigationController {
            if let visible = navigation.visibleViewController {
                return getTopViewController(from: visible)
            }
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(from: selected)
            }
        }
        return viewController
    }
    
    /// Swizzle UIViewController viewDidAppear to track screen changes
    private func swizzleViewDidAppear() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.tracker_viewDidAppear(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    #endif
}

#if os(iOS)
// Extension to add swizzled method
extension UIViewController {
    @objc func tracker_viewDidAppear(_ animated: Bool) {
        // Call original implementation
        self.tracker_viewDidAppear(animated)
        
        // Track screen view
        let screenName = String(describing: type(of: self))
        let tracker = MobileTracker.shared
        
        // Only track if URL changed
        if tracker.lastTrackedUrl != screenName {
            tracker.lastTrackedUrl = screenName
            Task {
                await tracker.track(eventName: "VIEW_PAGE", attributes: ["url": screenName])
            }
        }
    }
}
#endif

/// Errors that can occur during SDK operations
public enum TrackerError: Error, Equatable {
    case invalidAPIKey
    case invalidEndpoint
    case serializationFailed
    case networkError(underlying: Error)
    case invalidBrandId(String)
    case invalidConfig(String)
    case initializationFailed(String)
    
    public static func == (lhs: TrackerError, rhs: TrackerError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidAPIKey, .invalidAPIKey):
            return true
        case (.invalidEndpoint, .invalidEndpoint):
            return true
        case (.serializationFailed, .serializationFailed):
            return true
        case (.networkError, .networkError):
            return true
        case (.invalidBrandId, .invalidBrandId):
            return true
        case (.invalidConfig, .invalidConfig):
            return true
        case (.initializationFailed, .initializationFailed):
            return true
        default:
            return false
        }
    }
    
    /// Convert TrackerError to NSError for Objective-C compatibility
    func toNSError() -> NSError {
        let domain = "TrackerError"
        let code: Int
        let description: String
        
        switch self {
        case .invalidAPIKey:
            code = 0
            description = "Invalid API key provided"
        case .invalidEndpoint:
            code = 1
            description = "Invalid endpoint URL provided"
        case .serializationFailed:
            code = 2
            description = "Failed to serialize event data"
        case .networkError(let underlying):
            code = 3
            description = "Network error: \(underlying.localizedDescription)"
        case .invalidBrandId(let message):
            code = 4
            description = message
        case .invalidConfig(let message):
            code = 5
            description = message
        case .initializationFailed(let message):
            code = 6
            description = message
        }
        
        return NSError(
            domain: domain,
            code: code,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }
}

