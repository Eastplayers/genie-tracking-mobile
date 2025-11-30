import SwiftUI
import MobileTracker

struct ContentView: View {
    @State private var userId: String = ""
    @State private var eventName: String = ""
    @State private var screenName: String = ""
    @State private var metadataKey: String = ""
    @State private var metadataValue: String = ""
    @State private var profileName: String = ""
    @State private var profileEmail: String = ""
    @State private var statusMessage: String = "Ready to track events"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status message
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Identify Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Identify User")
                            .font(.headline)
                        
                        TextField("User ID", text: $userId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        Button(action: identifyUser) {
                            Label("Identify", systemImage: "person.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(userId.isEmpty)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Track Event Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Track Event")
                            .font(.headline)
                        
                        TextField("Event Name", text: $eventName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: trackEvent) {
                            Label("Track Event", systemImage: "star.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(eventName.isEmpty)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Screen Tracking Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Track Screen")
                            .font(.headline)
                        
                        TextField("Screen Name", text: $screenName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: trackScreen) {
                            Label("Track Screen", systemImage: "rectangle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(screenName.isEmpty)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Set Metadata Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Set Metadata")
                            .font(.headline)
                        
                        TextField("Metadata Key", text: $metadataKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Metadata Value", text: $metadataValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: setMetadata) {
                            Label("Set Metadata", systemImage: "tag.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .disabled(metadataKey.isEmpty || metadataValue.isEmpty)
                    }
                    .padding()
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Update Profile Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Update Profile (set)")
                            .font(.headline)
                        
                        TextField("Name", text: $profileName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Email", text: $profileEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: updateProfile) {
                            Label("Update Profile", systemImage: "person.crop.circle.badge.checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .disabled(profileName.isEmpty && profileEmail.isEmpty)
                    }
                    .padding()
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        Button(action: trackButtonClick) {
                            Label("Track Button Click", systemImage: "hand.tap.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: trackPurchase) {
                            Label("Track Purchase", systemImage: "cart.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: trackSignup) {
                            Label("Track Signup", systemImage: "person.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Reset Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reset Tracking")
                            .font(.headline)
                        
                        Button(action: resetTracking) {
                            Label("Reset Session", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button(action: resetAll) {
                            Label("Reset All (including Brand ID)", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("MobileTracker Demo")
        }
    }
    
    // MARK: - Actions
    
    private func identifyUser() {
        let profileData: [String: Any] = [
            "email": "\(userId)@example.com",
            "plan": "premium",
            "signupDate": ISO8601DateFormatter().string(from: Date())
        ]
        
        Task {
            await MobileTracker.shared.identify(userId: userId, profileData: profileData)
            statusMessage = "✅ Identified user: \(userId)"
            print("Identified user: \(userId) with profileData: \(profileData)")
        }
    }
    
    private func trackEvent() {
        let attributes: [String: Any] = [
            "source": "ios_example",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        Task {
            await MobileTracker.shared.track(eventName: eventName, attributes: attributes)
            statusMessage = "✅ Tracked event: \(eventName)"
            print("Tracked event: \(eventName) with attributes: \(attributes)")
            eventName = ""
        }
    }
    
    private func trackScreen() {
        let attributes: [String: Any] = [
            "previousScreen": "home",
            "loadTime": 0.5,
            "screen_name": screenName
        ]
        
        Task {
            await MobileTracker.shared.track(eventName: "SCREEN_VIEW", attributes: attributes)
            statusMessage = "✅ Tracked screen: \(screenName)"
            print("Tracked screen: \(screenName) with attributes: \(attributes)")
            screenName = ""
        }
    }
    
    private func trackButtonClick() {
        let attributes: [String: Any] = [
            "buttonName": "quick_action",
            "buttonType": "primary",
            "screen": "home"
        ]
        
        Task {
            await MobileTracker.shared.track(eventName: "BUTTON_CLICKED", attributes: attributes)
            statusMessage = "✅ Tracked: BUTTON_CLICKED"
            print("Tracked: BUTTON_CLICKED")
        }
    }
    
    private func trackPurchase() {
        let attributes: [String: Any] = [
            "productId": "premium_plan",
            "price": 29.99,
            "currency": "USD",
            "items": [
                ["name": "Premium Plan", "quantity": 1]
            ]
        ]
        
        Task {
            await MobileTracker.shared.track(eventName: "PURCHASE_COMPLETED", attributes: attributes)
            statusMessage = "✅ Tracked: PURCHASE_COMPLETED"
            print("Tracked: PURCHASE_COMPLETED")
        }
    }
    
    private func trackSignup() {
        let attributes: [String: Any] = [
            "method": "email",
            "source": "ios_app"
        ]
        
        Task {
            await MobileTracker.shared.track(eventName: "USER_SIGNUP", attributes: attributes)
            statusMessage = "✅ Tracked: USER_SIGNUP"
            print("Tracked: USER_SIGNUP")
        }
    }
    
    private func setMetadata() {
        let metadata: [String: Any] = [
            metadataKey: metadataValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        Task {
            await MobileTracker.shared.setMetadata(metadata)
            statusMessage = "✅ Metadata set: \(metadataKey) = \(metadataValue)"
            print("Set metadata: \(metadata)")
            metadataKey = ""
            metadataValue = ""
        }
    }
    
    private func updateProfile() {
        var profileData: [String: Any] = [:]
        
        if !profileName.isEmpty {
            profileData["name"] = profileName
        }
        if !profileEmail.isEmpty {
            profileData["email"] = profileEmail
        }
        
        Task {
            await MobileTracker.shared.set(profileData: profileData)
            statusMessage = "✅ Profile updated"
            print("Updated profile: \(profileData)")
            profileName = ""
            profileEmail = ""
        }
    }
    
    private func resetTracking() {
        MobileTracker.shared.reset(all: false)
        statusMessage = "✅ Session reset (Brand ID preserved)"
        print("Reset tracking session")
    }
    
    private func resetAll() {
        MobileTracker.shared.reset(all: true)
        statusMessage = "✅ All tracking data reset"
        print("Reset all tracking data including Brand ID")
    }
}

#Preview {
    ContentView()
}
