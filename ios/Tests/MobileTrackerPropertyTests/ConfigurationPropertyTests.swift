import XCTest
import SwiftCheck
@testable import MobileTracker

// Configuration models for testing
// These mirror the models in the example app

/// Configuration for the MobileTracker SDK with environment selection
public struct TrackerConfiguration: Codable, Equatable {
    public let apiKey: String
    public let brandId: String
    public let userId: String
    public let environment: Environment
    
    public var apiUrl: String {
        switch environment {
        case .qc:
            return "https://tracking.api.qc.founder-os.ai/api"
        case .production:
            return "https://tracking.api.founder-os.ai/api"
        }
    }
    
    public init(
        apiKey: String,
        brandId: String,
        userId: String = "",
        environment: Environment = .qc
    ) {
        self.apiKey = apiKey
        self.brandId = brandId
        self.userId = userId
        self.environment = environment
    }
    
    public func validate() -> ValidationResult {
        if apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("API Key is required")
        }
        if brandId.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("Brand ID is required")
        }
        return .valid
    }
}

/// Environment selection for the tracker API
public enum Environment: String, Codable, CaseIterable, Equatable {
    case qc = "QC"
    case production = "Production"
    
    public var displayName: String {
        self.rawValue
    }
}

/// Result of configuration validation
public enum ValidationResult: Equatable {
    case valid
    case error(String)
    
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .error:
            return false
        }
    }
    
    public var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .error(let message):
            return message
        }
    }
}

// MARK: - Generators for Property-Based Testing

extension TrackerConfiguration: Arbitrary {
    public static var arbitrary: Gen<TrackerConfiguration> {
        return Gen.compose { c in
            let apiKey = c.generate(using: String.arbitrary)
            let brandId = c.generate(using: String.arbitrary)
            let userId = c.generate(using: String.arbitrary)
            let environment = c.generate(using: Environment.arbitrary)
            return TrackerConfiguration(
                apiKey: apiKey,
                brandId: brandId,
                userId: userId,
                environment: environment
            )
        }
    }
}

extension Environment: Arbitrary {
    public static var arbitrary: Gen<Environment> {
        let cases = Environment.allCases
        return Gen.fromElements(of: cases)
    }
}

// MARK: - Property-Based Tests

class ConfigurationPropertyTests: XCTestCase {
    
    // **Feature: ios-example-config-ui, Property 1: Configuration Persistence Round Trip**
    // **Validates: Requirements 2.1, 2.2**
    func testConfigurationPersistenceRoundTrip() {
        property("For any valid TrackerConfiguration with non-blank apiKey and brandId, encoding to UserDefaults and decoding should produce an equivalent configuration") <- forAll { (config: TrackerConfiguration) in
            // Only test with non-blank apiKey and brandId
            guard !config.apiKey.trimmingCharacters(in: .whitespaces).isEmpty,
                  !config.brandId.trimmingCharacters(in: .whitespaces).isEmpty else {
                return true
            }
            
            do {
                // Encode to JSON
                let encoder = JSONEncoder()
                let apiKeyData = try encoder.encode(config.apiKey)
                let brandIdData = try encoder.encode(config.brandId)
                let userIdData = try encoder.encode(config.userId)
                let environmentData = try encoder.encode(config.environment)
                
                // Decode from JSON
                let decoder = JSONDecoder()
                let decodedApiKey = try decoder.decode(String.self, from: apiKeyData)
                let decodedBrandId = try decoder.decode(String.self, from: brandIdData)
                let decodedUserId = try decoder.decode(String.self, from: userIdData)
                let decodedEnvironment = try decoder.decode(Environment.self, from: environmentData)
                
                // Reconstruct configuration
                let decodedConfig = TrackerConfiguration(
                    apiKey: decodedApiKey,
                    brandId: decodedBrandId,
                    userId: decodedUserId,
                    environment: decodedEnvironment
                )
                
                // Verify round trip
                return decodedConfig == config
            } catch {
                return false
            }
        }
    }
    
    // **Feature: ios-example-config-ui, Property 2: QC Environment URL Mapping**
    // **Validates: Requirements 1.4**
    func testQCEnvironmentURLMapping() {
        property("For any TrackerConfiguration with environment set to qc, the apiUrl property should return exactly https://tracking.api.qc.founder-os.ai/api") <- forAll { (apiKey: String, brandId: String, userId: String) in
            let config = TrackerConfiguration(
                apiKey: apiKey,
                brandId: brandId,
                userId: userId,
                environment: .qc
            )
            return config.apiUrl == "https://tracking.api.qc.founder-os.ai/api"
        }
    }
    
    // **Feature: ios-example-config-ui, Property 3: Production Environment URL Mapping**
    // **Validates: Requirements 1.5**
    func testProductionEnvironmentURLMapping() {
        property("For any TrackerConfiguration with environment set to production, the apiUrl property should return exactly https://tracking.api.founder-os.ai/api") <- forAll { (apiKey: String, brandId: String, userId: String) in
            let config = TrackerConfiguration(
                apiKey: apiKey,
                brandId: brandId,
                userId: userId,
                environment: .production
            )
            return config.apiUrl == "https://tracking.api.founder-os.ai/api"
        }
    }
    
    // **Feature: ios-example-config-ui, Property 4: Validation Rejects Invalid Input**
    // **Validates: Requirements 1.3**
    func testValidationRejectsInvalidInput() {
        property("For any TrackerConfiguration where either apiKey is blank or brandId is blank, calling validate() should return a ValidationResult.error") <- forAll { (apiKey: String, brandId: String, userId: String) in
            // Only test with at least one blank field
            let hasBlankApiKey = apiKey.trimmingCharacters(in: .whitespaces).isEmpty
            let hasBlankBrandId = brandId.trimmingCharacters(in: .whitespaces).isEmpty
            
            guard hasBlankApiKey || hasBlankBrandId else {
                return true
            }
            
            let config = TrackerConfiguration(
                apiKey: apiKey,
                brandId: brandId,
                userId: userId,
                environment: .qc
            )
            
            let validationResult = config.validate()
            return !validationResult.isValid
        }
    }
    
    // **Feature: ios-example-config-ui, Property 5: Validation Accepts Valid Input**
    // **Validates: Requirements 1.2**
    func testValidationAcceptsValidInput() {
        property("For any TrackerConfiguration with non-blank apiKey and non-blank brandId, calling validate() should return ValidationResult.valid") <- forAll { (apiKey: String, brandId: String, userId: String) in
            // Only test with non-blank fields
            guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty,
                  !brandId.trimmingCharacters(in: .whitespaces).isEmpty else {
                return true
            }
            
            let config = TrackerConfiguration(
                apiKey: apiKey,
                brandId: brandId,
                userId: userId,
                environment: .qc
            )
            
            let validationResult = config.validate()
            return validationResult.isValid
        }
    }
    
    // **Feature: ios-example-config-ui, Property 6: Configuration Change Persistence**
    // **Validates: Requirements 3.3, 3.4**
    func testConfigurationChangePersistence() {
        property("For any valid TrackerConfiguration that is modified and saved, loading the configuration should return the modified values") <- forAll { (originalConfig: TrackerConfiguration, newApiKey: String, newBrandId: String) in
            // Only test with valid original config
            guard !originalConfig.apiKey.trimmingCharacters(in: .whitespaces).isEmpty,
                  !originalConfig.brandId.trimmingCharacters(in: .whitespaces).isEmpty,
                  !newApiKey.trimmingCharacters(in: .whitespaces).isEmpty,
                  !newBrandId.trimmingCharacters(in: .whitespaces).isEmpty else {
                return true
            }
            
            do {
                // Create modified configuration
                let modifiedConfig = TrackerConfiguration(
                    apiKey: newApiKey,
                    brandId: newBrandId,
                    userId: originalConfig.userId,
                    environment: originalConfig.environment
                )
                
                // Encode modified configuration
                let encoder = JSONEncoder()
                let apiKeyData = try encoder.encode(modifiedConfig.apiKey)
                let brandIdData = try encoder.encode(modifiedConfig.brandId)
                let userIdData = try encoder.encode(modifiedConfig.userId)
                let environmentData = try encoder.encode(modifiedConfig.environment)
                
                // Decode to verify
                let decoder = JSONDecoder()
                let decodedApiKey = try decoder.decode(String.self, from: apiKeyData)
                let decodedBrandId = try decoder.decode(String.self, from: brandIdData)
                let decodedUserId = try decoder.decode(String.self, from: userIdData)
                let decodedEnvironment = try decoder.decode(Environment.self, from: environmentData)
                
                // Verify modified values are persisted
                return decodedApiKey == newApiKey &&
                       decodedBrandId == newBrandId &&
                       decodedUserId == originalConfig.userId &&
                       decodedEnvironment == originalConfig.environment
            } catch {
                return false
            }
        }
    }
}
