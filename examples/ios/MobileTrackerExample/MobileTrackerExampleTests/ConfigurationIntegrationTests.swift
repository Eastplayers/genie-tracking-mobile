import XCTest
@testable import MobileTrackerExample

/// Integration tests for the configuration flow
/// Tests the full end-to-end configuration, persistence, and reconfiguration flows
class ConfigurationIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        clearAllUserDefaults()
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up after each test
        clearAllUserDefaults()
    }
    
    // MARK: - Test 8.1: Full Configuration Flow End-to-End
    
    /// Test that the configuration flow works end-to-end:
    /// Launch app → Show configuration screen → Enter values → Initialize → Show demo screen
    /// Requirements: 1.1, 1.2, 1.6
    func testFullConfigurationFlowEndToEnd() {
        // Arrange: Create a valid configuration
        let testApiKey = "test-api-key-12345"
        let testBrandId = "test-brand-id"
        let testUserId = "test-user-123"
        let testEnvironment = Environment.qc
        
        let config = TrackerConfiguration(
            apiKey: testApiKey,
            brandId: testBrandId,
            userId: testUserId,
            environment: testEnvironment
        )
        
        // Act: Validate the configuration
        let validationResult = config.validate()
        
        // Assert: Configuration should be valid
        XCTAssertTrue(validationResult.isValid, "Configuration should be valid")
        
        // Act: Save configuration
        let configManager = ConfigurationManager()
        configManager.saveConfiguration(config)
        
        // Assert: Configuration should be persisted
        XCTAssertTrue(configManager.hasConfiguration(), "Configuration should be persisted")
        
        // Act: Load configuration
        let loadedConfig = configManager.loadConfiguration()
        
        // Assert: Loaded configuration should match saved configuration
        XCTAssertNotNil(loadedConfig, "Configuration should be loaded")
        XCTAssertEqual(loadedConfig?.apiKey, testApiKey, "API key should match")
        XCTAssertEqual(loadedConfig?.brandId, testBrandId, "Brand ID should match")
        XCTAssertEqual(loadedConfig?.userId, testUserId, "User ID should match")
        XCTAssertEqual(loadedConfig?.environment, testEnvironment, "Environment should match")
    }
    
    // MARK: - Test 8.2: Persistence Across App Restarts
    
    /// Test that configuration persists across app restarts:
    /// Save configuration → Kill app → Relaunch → Verify auto-initialization
    /// Requirements: 2.2
    func testPersistenceAcrossAppRestarts() {
        // Arrange: Create and save a configuration
        let testApiKey = "persist-test-key"
        let testBrandId = "persist-test-brand"
        let testUserId = "persist-user"
        let testEnvironment = Environment.production
        
        let config = TrackerConfiguration(
            apiKey: testApiKey,
            brandId: testBrandId,
            userId: testUserId,
            environment: testEnvironment
        )
        
        let configManager = ConfigurationManager()
        configManager.saveConfiguration(config)
        
        // Act: Simulate app restart by creating a new ConfigurationManager
        let newConfigManager = ConfigurationManager()
        
        // Assert: New instance should have configuration loaded
        XCTAssertTrue(newConfigManager.hasConfiguration(), "Configuration should persist after app restart")
        XCTAssertEqual(newConfigManager.apiKey, testApiKey, "API key should be loaded")
        XCTAssertEqual(newConfigManager.brandId, testBrandId, "Brand ID should be loaded")
        XCTAssertEqual(newConfigManager.userId, testUserId, "User ID should be loaded")
        XCTAssertEqual(newConfigManager.environment, testEnvironment, "Environment should be loaded")
        XCTAssertTrue(newConfigManager.isInitialized, "Should be marked as initialized")
    }
    
    // MARK: - Test 8.3: Reconfiguration Flow
    
    /// Test that reconfiguration works correctly:
    /// Initialize with config A → Click settings → Change to config B → Verify reinitialize
    /// Requirements: 3.2, 3.3, 3.4
    func testReconfigurationFlow() {
        // Arrange: Create and save initial configuration
        let initialConfig = TrackerConfiguration(
            apiKey: "initial-key",
            brandId: "initial-brand",
            userId: "initial-user",
            environment: .qc
        )
        
        let configManager = ConfigurationManager()
        configManager.saveConfiguration(initialConfig)
        
        // Assert: Initial configuration is saved
        XCTAssertEqual(configManager.apiKey, "initial-key", "Initial API key should be saved")
        XCTAssertEqual(configManager.brandId, "initial-brand", "Initial brand ID should be saved")
        
        // Act: Create and save new configuration (reconfiguration)
        let newConfig = TrackerConfiguration(
            apiKey: "new-key",
            brandId: "new-brand",
            userId: "new-user",
            environment: .production
        )
        
        configManager.saveConfiguration(newConfig)
        
        // Assert: New configuration should be persisted
        XCTAssertEqual(configManager.apiKey, "new-key", "New API key should be saved")
        XCTAssertEqual(configManager.brandId, "new-brand", "New brand ID should be saved")
        XCTAssertEqual(configManager.userId, "new-user", "New user ID should be saved")
        XCTAssertEqual(configManager.environment, .production, "New environment should be saved")
        
        // Act: Simulate app restart to verify new configuration persists
        let verifyConfigManager = ConfigurationManager()
        
        // Assert: Restarted app should have new configuration
        XCTAssertEqual(verifyConfigManager.apiKey, "new-key", "New API key should persist after restart")
        XCTAssertEqual(verifyConfigManager.brandId, "new-brand", "New brand ID should persist after restart")
    }
    
    // MARK: - Test 8.4: Error Handling
    
    /// Test error handling for invalid inputs:
    /// Try to initialize with blank fields → Verify error display
    /// Try to initialize with invalid credentials → Verify error handling
    /// Requirements: 1.3
    func testErrorHandlingForBlankFields() {
        // Test 1: Blank API key
        let configWithBlankApiKey = TrackerConfiguration(
            apiKey: "",
            brandId: "valid-brand",
            userId: "",
            environment: .qc
        )
        
        let result1 = configWithBlankApiKey.validate()
        XCTAssertFalse(result1.isValid, "Configuration with blank API key should be invalid")
        XCTAssertNotNil(result1.errorMessage, "Error message should be provided")
        XCTAssertTrue(result1.errorMessage?.contains("API Key") ?? false, "Error should mention API Key")
        
        // Test 2: Blank brand ID
        let configWithBlankBrandId = TrackerConfiguration(
            apiKey: "valid-key",
            brandId: "",
            userId: "",
            environment: .qc
        )
        
        let result2 = configWithBlankBrandId.validate()
        XCTAssertFalse(result2.isValid, "Configuration with blank brand ID should be invalid")
        XCTAssertNotNil(result2.errorMessage, "Error message should be provided")
        XCTAssertTrue(result2.errorMessage?.contains("Brand ID") ?? false, "Error should mention Brand ID")
        
        // Test 3: Both blank
        let configWithBothBlank = TrackerConfiguration(
            apiKey: "",
            brandId: "",
            userId: "",
            environment: .qc
        )
        
        let result3 = configWithBothBlank.validate()
        XCTAssertFalse(result3.isValid, "Configuration with both blank should be invalid")
        
        // Test 4: Whitespace-only fields should also be invalid
        let configWithWhitespace = TrackerConfiguration(
            apiKey: "   ",
            brandId: "  \t  ",
            userId: "",
            environment: .qc
        )
        
        let result4 = configWithWhitespace.validate()
        XCTAssertFalse(result4.isValid, "Configuration with whitespace-only fields should be invalid")
    }
    
    /// Test that valid configurations pass validation
    func testErrorHandlingForValidConfigurations() {
        // Test 1: Valid configuration with all fields
        let validConfig = TrackerConfiguration(
            apiKey: "valid-key",
            brandId: "valid-brand",
            userId: "valid-user",
            environment: .qc
        )
        
        let result1 = validConfig.validate()
        XCTAssertTrue(result1.isValid, "Valid configuration should pass validation")
        XCTAssertNil(result1.errorMessage, "No error message for valid configuration")
        
        // Test 2: Valid configuration without user ID
        let validConfigNoUserId = TrackerConfiguration(
            apiKey: "valid-key",
            brandId: "valid-brand",
            userId: "",
            environment: .production
        )
        
        let result2 = validConfigNoUserId.validate()
        XCTAssertTrue(result2.isValid, "Valid configuration without user ID should pass validation")
    }
    
    // MARK: - Test 8.5: Configuration Clearing
    
    /// Test that configuration can be cleared:
    /// Clear configuration → Relaunch app → Verify configuration screen shown
    /// Requirements: 2.3
    func testConfigurationClearing() {
        // Arrange: Create and save a configuration
        let config = TrackerConfiguration(
            apiKey: "test-key",
            brandId: "test-brand",
            userId: "test-user",
            environment: .qc
        )
        
        let configManager = ConfigurationManager()
        configManager.saveConfiguration(config)
        
        // Assert: Configuration exists
        XCTAssertTrue(configManager.hasConfiguration(), "Configuration should exist after saving")
        XCTAssertTrue(configManager.isInitialized, "Should be marked as initialized")
        
        // Act: Clear configuration
        configManager.clearConfiguration()
        
        // Assert: Configuration should be cleared
        XCTAssertFalse(configManager.hasConfiguration(), "Configuration should be cleared")
        XCTAssertFalse(configManager.isInitialized, "Should not be marked as initialized")
        XCTAssertEqual(configManager.apiKey, "", "API key should be empty")
        XCTAssertEqual(configManager.brandId, "", "Brand ID should be empty")
        XCTAssertEqual(configManager.userId, "", "User ID should be empty")
        XCTAssertEqual(configManager.environment, .qc, "Environment should be reset to default")
        
        // Act: Simulate app restart after clearing
        let newConfigManager = ConfigurationManager()
        
        // Assert: New instance should not have configuration
        XCTAssertFalse(newConfigManager.hasConfiguration(), "Configuration should not exist after clearing and restart")
        XCTAssertFalse(newConfigManager.isInitialized, "Should not be marked as initialized after restart")
    }
    
    // MARK: - Additional Integration Tests
    
    /// Test environment URL mapping for both environments
    func testEnvironmentURLMapping() {
        // Test QC environment
        let qcConfig = TrackerConfiguration(
            apiKey: "key",
            brandId: "brand",
            userId: "",
            environment: .qc
        )
        
        XCTAssertEqual(
            qcConfig.apiUrl,
            "https://tracking.api.qc.founder-os.ai/api",
            "QC environment should map to correct URL"
        )
        
        // Test Production environment
        let prodConfig = TrackerConfiguration(
            apiKey: "key",
            brandId: "brand",
            userId: "",
            environment: .production
        )
        
        XCTAssertEqual(
            prodConfig.apiUrl,
            "https://tracking.api.founder-os.ai/api",
            "Production environment should map to correct URL"
        )
    }
    
    /// Test that ConfigurationManager properly initializes with existing configuration
    func testConfigurationManagerInitializationWithExistingConfig() {
        // Arrange: Save a configuration first
        let config = TrackerConfiguration(
            apiKey: "init-test-key",
            brandId: "init-test-brand",
            userId: "init-test-user",
            environment: .production
        )
        
        let initialManager = ConfigurationManager()
        initialManager.saveConfiguration(config)
        
        // Act: Create a new ConfigurationManager (simulating app restart)
        let newManager = ConfigurationManager()
        
        // Assert: New manager should have loaded the configuration
        XCTAssertEqual(newManager.apiKey, "init-test-key", "API key should be loaded on init")
        XCTAssertEqual(newManager.brandId, "init-test-brand", "Brand ID should be loaded on init")
        XCTAssertEqual(newManager.userId, "init-test-user", "User ID should be loaded on init")
        XCTAssertEqual(newManager.environment, .production, "Environment should be loaded on init")
        XCTAssertTrue(newManager.isInitialized, "Should be marked as initialized on init")
    }
    
    // MARK: - Helper Methods
    
    /// Clear all UserDefaults for clean test state
    private func clearAllUserDefaults() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.apiKey)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.brandId)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userId)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.environment)
    }
}
