import SwiftUI

/// Configuration screen for the MobileTracker SDK
/// Allows users to input API key, brand ID, and select environment
struct ConfigurationView: View {
    /// Local state for form inputs
    @State private var localApiKey: String = ""
    @State private var localBrandId: String = ""
    @State private var localEnvironment: Environment = .qc
    
    /// Track validation error state
    @State private var validationError: String?
    
    /// Callback when initialization succeeds
    var onInitializationSuccess: (TrackerConfiguration) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gear.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Configure MobileTracker")
                            .font(.system(size: 22, weight: .bold))
                        
                        Text("Enter your API credentials and select your environment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    
                    // Error message display
                    if let error = validationError {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Configuration form
                    VStack(spacing: 16) {
                        // API Key input (SecureField for security)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("API Key", systemImage: "key.fill")
                                .font(.system(size: 14, weight: .semibold))
                            
                            SecureField("Enter your API key", text: $localApiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                            
                            Text("Your API key is masked for security")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Brand ID input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Brand ID", systemImage: "building.2.fill")
                                .font(.system(size: 14, weight: .semibold))
                            
                            TextField("Enter your brand ID", text: $localBrandId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        
                        // Environment picker
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Environment", systemImage: "globe")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Picker("Environment", selection: $localEnvironment) {
                                ForEach(Environment.allCases, id: \.self) { env in
                                    Text(env.displayName).tag(env)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Initialize button (enabled only when required fields are filled)
                    Button(action: initializeTracker) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Initialize Tracker")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Pre-fill fields with loaded configuration if available
            let configManager = ConfigurationManager()
            if let config = configManager.loadConfiguration() {
                localApiKey = config.apiKey
                localBrandId = config.brandId
                localEnvironment = config.environment
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if form is valid (required fields are non-blank)
    private var isFormValid: Bool {
        !localApiKey.trimmingCharacters(in: .whitespaces).isEmpty &&
        !localBrandId.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Actions
    
    /// Initialize the tracker with current form values
    private func initializeTracker() {
        // Clear previous error
        validationError = nil
        
        // Create configuration from form inputs
        let config = TrackerConfiguration(
            apiKey: localApiKey,
            brandId: localBrandId,
            environment: localEnvironment
        )
        
        // Validate configuration
        let validationResult = config.validate()
        
        switch validationResult {
        case .valid:
            // Save configuration to UserDefaults
            let configManager = ConfigurationManager()
            configManager.saveConfiguration(config)
            
            // Call success callback to initialize tracker
            onInitializationSuccess(config)
            
        case .error(let message):
            // Display validation error
            validationError = message
        }
    }
}

#Preview {
    ConfigurationView { _ in }
}
