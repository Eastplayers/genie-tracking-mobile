import Foundation
import Combine

/// Manages configuration persistence and state for the MobileTracker SDK
/// Handles loading, saving, and clearing configuration from UserDefaults
class ConfigurationManager: ObservableObject {
    /// Published property for API key
    @Published var apiKey: String = ""
    
    /// Published property for brand ID
    @Published var brandId: String = ""
    
    /// Published property for selected environment
    @Published var environment: Environment = .qc
    
    /// Published property for error messages
    @Published var errorMessage: String?
    
    /// Published property indicating if tracker is initialized
    @Published var isInitialized: Bool = false
    
    /// Initialize ConfigurationManager
    init() {
        // Load configuration if it exists
        if let config = loadConfiguration() {
            self.apiKey = config.apiKey
            self.brandId = config.brandId
            self.environment = config.environment
            self.isInitialized = true
        }
    }
    
    /// Load configuration from UserDefaults
    /// - Returns: TrackerConfiguration if one exists, nil otherwise
    func loadConfiguration() -> TrackerConfiguration? {
        guard let apiKeyData = UserDefaults.standard.data(forKey: UserDefaultsKeys.apiKey),
              let brandIdData = UserDefaults.standard.data(forKey: UserDefaultsKeys.brandId),
              let environmentData = UserDefaults.standard.data(forKey: UserDefaultsKeys.environment) else {
            return nil
        }
        
        do {
            let apiKey = try JSONDecoder().decode(String.self, from: apiKeyData)
            let brandId = try JSONDecoder().decode(String.self, from: brandIdData)
            let environment = try JSONDecoder().decode(Environment.self, from: environmentData)
            
            return TrackerConfiguration(
                apiKey: apiKey,
                brandId: brandId,
                environment: environment
            )
        } catch {
            return nil
        }
    }
    
    /// Save configuration to UserDefaults
    /// - Parameter config: The TrackerConfiguration to save
    func saveConfiguration(_ config: TrackerConfiguration) {
        do {
            let apiKeyData = try JSONEncoder().encode(config.apiKey)
            let brandIdData = try JSONEncoder().encode(config.brandId)
            let environmentData = try JSONEncoder().encode(config.environment)
            
            UserDefaults.standard.set(apiKeyData, forKey: UserDefaultsKeys.apiKey)
            UserDefaults.standard.set(brandIdData, forKey: UserDefaultsKeys.brandId)
            UserDefaults.standard.set(environmentData, forKey: UserDefaultsKeys.environment)
            
            // Update published properties
            DispatchQueue.main.async {
                self.apiKey = config.apiKey
                self.brandId = config.brandId
                self.environment = config.environment
                self.isInitialized = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save configuration: \(error.localizedDescription)"
            }
        }
    }
    
    /// Clear configuration from UserDefaults
    func clearConfiguration() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.apiKey)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.brandId)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.environment)
        
        DispatchQueue.main.async {
            self.apiKey = ""
            self.brandId = ""
            self.environment = .qc
            self.isInitialized = false
            self.errorMessage = nil
        }
    }
    
    /// Check if configuration exists in UserDefaults
    /// - Returns: true if configuration exists, false otherwise
    func hasConfiguration() -> Bool {
        return UserDefaults.standard.data(forKey: UserDefaultsKeys.apiKey) != nil &&
               UserDefaults.standard.data(forKey: UserDefaultsKeys.brandId) != nil &&
               UserDefaults.standard.data(forKey: UserDefaultsKeys.environment) != nil
    }
}
