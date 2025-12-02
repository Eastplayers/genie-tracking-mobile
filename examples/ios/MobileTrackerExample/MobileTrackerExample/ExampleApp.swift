import SwiftUI
import MobileTracker

@main
struct MobileTrackerExampleApp: App {
    /// State object for configuration management
    @StateObject private var configManager = ConfigurationManager()
    
    /// Track whether to show configuration view or demo view
    @State private var showConfigurationView: Bool = false
    
    /// Track initialization state
    @State private var isInitializing: Bool = false
    
    /// Callback for when user resets all data
    var onResetAll: () -> Void {
        return {
            configManager.clearConfiguration()
            showConfigurationView = true
        }
    }
    
    init() {
        // Check if configuration exists on startup
        let configManager = ConfigurationManager()
        if configManager.hasConfiguration() {
            // Configuration exists, will initialize automatically
        } else {
            // No configuration, show configuration view
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showConfigurationView {
                    // Show configuration screen
                    ConfigurationView { config in
                        initializeTrackerWithConfiguration(config)
                    }
                } else if configManager.isInitialized {
                    // Show demo screen after successful initialization
                    ContentView(onResetAll: onResetAll)
                } else {
                    // Show configuration screen on first launch
                    ConfigurationView { config in
                        initializeTrackerWithConfiguration(config)
                    }
                }
            }
            .task {
                // Check if configuration exists and initialize automatically
                if configManager.hasConfiguration() {
                    if let config = configManager.loadConfiguration() {
                        initializeTrackerWithConfiguration(config)
                    }
                } else {
                    // Show configuration view
                    showConfigurationView = true
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Initialize the tracker with the provided configuration
    /// - Parameter config: The TrackerConfiguration to use for initialization
    private func initializeTrackerWithConfiguration(_ config: TrackerConfiguration) {
        isInitializing = true
        
        Task {
            do {
                print("🔄 Starting MobileTracker initialization...")
                print("   Brand ID: \(config.brandId)")
                print("   API URL: \(config.apiUrl)")
                print("   API Key: \(config.apiKey.prefix(8))...")
                
                try await MobileTracker.shared.initialize(
                    brandId: config.brandId,
                    config: TrackerConfig(
                        debug: true,
                        apiUrl: config.apiUrl,
                        xApiKey: config.apiKey
                    )
                )
                
                print("✅ MobileTracker initialized successfully")
                
                // Update state to show demo view
                DispatchQueue.main.async {
                    configManager.isInitialized = true
                    showConfigurationView = false
                    isInitializing = false
                }
            } catch {
                print("❌ Failed to initialize MobileTracker: \(error)")
                
                // Update error state
                DispatchQueue.main.async {
                    configManager.errorMessage = "Failed to initialize: \(error.localizedDescription)"
                    isInitializing = false
                }
            }
        }
    }
}
