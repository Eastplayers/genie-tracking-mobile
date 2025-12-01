import SwiftUI
import MobileTracker

@main
struct MobileTrackerExampleApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await appState.initializeTracker()
                }
        }
    }
}

/// App-level state to manage tracker initialization
class AppState: ObservableObject {
    @Published var isInitialized = false
    @Published var initializationError: String?
    
    func initializeTracker() async {
        // Initialize the SDK when app launches
        // Configuration is loaded from environment variables via Config helper
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
            await MainActor.run {
                self.isInitialized = true
            }
        } catch {
            print("❌ Failed to initialize MobileTracker: \(error)")
            await MainActor.run {
                self.initializationError = error.localizedDescription
            }
        }
    }
}
