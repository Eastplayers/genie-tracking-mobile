import SwiftUI
import MobileTracker

@main
struct MobileTrackerExampleApp: App {
    init() {
        // Initialize the SDK when app launches
        // Configuration is loaded from environment variables via Config helper
        Task {
            do {
                // Validate configuration
                try Config.validate()
                
                print("🔄 Starting MobileTracker initialization...")
                print("   Brand ID: \(Config.brandId)")
                print("   API URL: \(Config.apiUrl ?? "default")")
                print("   API Key: \(Config.xApiKey?.prefix(8) ?? "")...")
                
                try await MobileTracker.shared.initialize(
                    brandId: Config.brandId,
                    config: TrackerConfig(
                        debug: Config.debug,
                        apiUrl: Config.apiUrl,
                        xApiKey: Config.xApiKey
                    )
                )
                print("✅ MobileTracker initialized successfully")
            } catch {
                print("❌ Failed to initialize MobileTracker: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
