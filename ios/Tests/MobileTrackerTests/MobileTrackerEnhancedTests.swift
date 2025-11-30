import XCTest
@testable import MobileTracker

@available(iOS 13.0, macOS 10.15, *)
final class MobileTrackerEnhancedTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // Reset tracker state if needed
        MobileTracker.shared.reset(all: true)
    }
    
    // MARK: - Initialization Tests
    
    func testInitializeWithValidBrandId() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com",
            xApiKey: "test-key"
        )
        
        // When
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // Then - should not throw
    }
    
    func testInitializeWithEmptyBrandId() async {
        // Given
        let brandId = ""
        let config = TrackerConfig(debug: true)
        
        // When
        try? await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // Then - should not crash (errors are caught gracefully per web implementation)
        // The SDK will log the error but not throw to prevent crashing the app
    }
    
    func testInitializeWithNonNumericBrandId() async {
        // Given
        let brandId = "not-a-number"
        let config = TrackerConfig(debug: true)
        
        // When
        try? await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // Then - should not crash (errors are caught gracefully per web implementation)
        // The SDK will log the error but not throw to prevent crashing the app
    }
    
    // MARK: - Track Tests
    
    func testTrackEvent() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com"
        )
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // When
        await MobileTracker.shared.track(
            eventName: "BUTTON_CLICK",
            attributes: ["button": "signup"],
            metadata: ["flow": "onboarding"]
        )
        
        // Then - should not crash
    }
    
    // MARK: - Identify Tests
    
    func testIdentifyUser() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com"
        )
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // When
        await MobileTracker.shared.identify(
            userId: "user123",
            profileData: ["email": "user@example.com", "name": "John Doe"]
        )
        
        // Then - should not crash
    }
    
    // MARK: - Set Profile Tests
    
    func testSetProfile() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com"
        )
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // When
        await MobileTracker.shared.set(profileData: ["plan": "premium"])
        
        // Then - should not crash
    }
    
    // MARK: - Metadata Tests
    
    func testSetMetadata() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com"
        )
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // When
        await MobileTracker.shared.setMetadata(["session_type": "premium"])
        
        // Then - should not crash
    }
    
    // MARK: - Reset Tests
    
    func testReset() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com"
        )
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // When
        MobileTracker.shared.reset(all: false)
        
        // Then - should not crash
    }
    
    func testResetAll() async throws {
        // Given
        let brandId = "7366"
        let config = TrackerConfig(
            debug: true,
            apiUrl: "https://api.example.com"
        )
        try await MobileTracker.shared.initialize(brandId: brandId, config: config)
        
        // When
        MobileTracker.shared.reset(all: true)
        
        // Then - should not crash
    }
}
