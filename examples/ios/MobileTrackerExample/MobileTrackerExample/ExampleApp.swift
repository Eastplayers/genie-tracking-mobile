import SwiftUI
import MobileTracker

@main
struct MobileTrackerExampleApp: App {
    init() {
        // Initialize the SDK when app launches
        let brandId = "7366"
        let apiKey = "03dbd95123137cc76b075f50107d8d2d"
        let apiUrl = "https://tracking.api.qc.founder-os.ai/api"
        
        Task {
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
