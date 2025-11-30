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
        let brandId = "7366"
        let apiKey = "03dbd95123137cc76b075f50107d8d2d"
        let apiUrl = "https://tracking.api.qc.founder-os.ai/api"
        
        do {
            try await MobileTracker.shared.initialize(
                brandId: brandId,
                config: TrackerConfig(
                    debug: true,
                    apiUrl: apiUrl,
                    xApiKey: apiKey
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
