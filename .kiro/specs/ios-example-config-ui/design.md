# Design Document

## Overview

This design adds an interactive configuration screen to the iOS example app that allows users to input API credentials and select their environment before initializing the MobileTracker SDK. The configuration persists to UserDefaults, enabling automatic initialization on subsequent app launches.

The implementation follows a two-screen pattern:

1. **Configuration Screen**: Shown on first launch or when user requests to change settings
2. **Demo Screen**: Main tracking demo interface shown after successful initialization

## Architecture

### Component Structure

```
MobileTrackerExampleApp
├── ConfigurationView (SwiftUI View)
│   ├── API Key SecureField
│   ├── Brand ID TextField
│   ├── User ID TextField (optional)
│   ├── Environment Picker (QC / Production)
│   ├── Initialize Button
│   └── Error Message Display
├── ContentView (SwiftUI View)
│   ├── Status Display
│   ├── Tracking Demo Sections
│   └── Settings Button (to reconfigure)
└── ConfigurationManager (ObservableObject)
    ├── Load Configuration
    ├── Save Configuration
    ├── Clear Configuration
    └── Check if Configuration Exists
```

### Data Flow

```
App Launch
    ↓
Check if configuration exists in UserDefaults
    ↓
    ├─→ YES: Load config → Initialize SDK → Show Demo Screen
    └─→ NO: Show Configuration Screen
         ↓
    User enters credentials
         ↓
    Validate inputs
         ↓
    ├─→ Valid: Save to UserDefaults → Initialize SDK → Show Demo Screen
    └─→ Invalid: Show error message
```

## Components and Interfaces

### ConfigurationManager

Handles persistence of configuration to UserDefaults and state management.

```swift
class ConfigurationManager: ObservableObject {
    @Published var apiKey: String = ""
    @Published var brandId: String = ""
    @Published var userId: String = ""
    @Published var environment: Environment = .qc
    @Published var errorMessage: String?
    @Published var isInitialized: Bool = false

    // Load configuration from UserDefaults
    func loadConfiguration() -> TrackerConfiguration?

    // Save configuration to UserDefaults
    func saveConfiguration(_ config: TrackerConfiguration)

    // Clear configuration from UserDefaults
    func clearConfiguration()

    // Check if configuration exists
    func hasConfiguration() -> Bool

    // Initialize tracker with current configuration
    func initializeTracker() async

    // Reset tracker and clear configuration
    func resetTracker()
}

struct TrackerConfiguration {
    let apiKey: String
    let brandId: String
    let userId: String
    let environment: Environment

    var apiUrl: String {
        switch environment {
        case .qc:
            return "https://tracking.api.qc.founder-os.ai/api"
        case .production:
            return "https://tracking.api.founder-os.ai/api"
        }
    }

    func validate() -> ValidationResult {
        if apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("API Key is required")
        }
        if brandId.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("Brand ID is required")
        }
        return .valid
    }
}

enum Environment: String, CaseIterable {
    case qc = "QC"
    case production = "Production"

    var displayName: String {
        self.rawValue
    }
}

enum ValidationResult {
    case valid
    case error(String)
}
```

### UI Components

#### ConfigurationView

Displays input fields for API key, brand ID, user ID, and environment selection.

```swift
struct ConfigurationView: View {
    @StateObject private var configManager = ConfigurationManager()
    @State private var showError = false

    var body: some View {
        // Configuration form with:
        // - SecureField for API Key
        // - TextField for Brand ID
        // - TextField for User ID (optional)
        // - Picker for Environment selection
        // - Initialize button (enabled only when required fields are filled)
        // - Error message display
    }
}
```

Features:

- SecureField for API Key input (masked for security)
- TextField for Brand ID input
- TextField for User ID input (optional for convenience during testing)
- Picker for environment selection (QC / Production)
- Initialize button (enabled only when required fields are filled)
- Error message display area
- Clear visual hierarchy with SwiftUI styling
- Pre-fills fields if configuration was previously saved

#### ContentView Enhancement

Enhanced version of existing demo screen with settings access.

```swift
struct ContentView: View {
    @StateObject private var configManager = ConfigurationManager()

    var body: some View {
        // Existing demo functionality with:
        // - Settings button in navigation bar
        // - Sheet presentation for configuration changes
        // - Ability to reconfigure and reinitialize
    }
}
```

Features:

- All existing demo functionality preserved
- Settings button in navigation bar
- Sheet presentation for configuration changes
- Ability to reconfigure and reinitialize

## Data Models

### TrackerConfiguration

```swift
struct TrackerConfiguration: Codable {
    let apiKey: String
    let brandId: String
    let userId: String
    let environment: Environment

    var apiUrl: String {
        switch environment {
        case .qc:
            return "https://tracking.api.qc.founder-os.ai/api"
        case .production:
            return "https://tracking.api.founder-os.ai/api"
        }
    }

    func validate() -> ValidationResult {
        if apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("API Key is required")
        }
        if brandId.trimmingCharacters(in: .whitespaces).isEmpty {
            return .error("Brand ID is required")
        }
        return .valid
    }
}

enum Environment: String, Codable, CaseIterable {
    case qc = "QC"
    case production = "Production"

    var displayName: String {
        self.rawValue
    }
}

enum ValidationResult {
    case valid
    case error(String)
}
```

### UserDefaults Keys

```swift
struct UserDefaultsKeys {
    static let apiKey = "tracker_api_key"
    static let brandId = "tracker_brand_id"
    static let environment = "tracker_environment"
    static let userId = "tracker_user_id"
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do.
Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Configuration Persistence Round Trip

_For any_ valid TrackerConfiguration with non-blank apiKey, non-blank brandId, and any environment, encoding it to UserDefaults and then decoding it should produce an equivalent configuration with the same apiKey, brandId, and environment.

**Validates: Requirements 2.1, 2.2**

### Property 2: QC Environment URL Mapping

_For any_ TrackerConfiguration with environment set to qc, the apiUrl property should return exactly "https://tracking.api.qc.founder-os.ai/api".

**Validates: Requirements 1.4**

### Property 3: Production Environment URL Mapping

_For any_ TrackerConfiguration with environment set to production, the apiUrl property should return exactly "https://tracking.api.founder-os.ai/api".

**Validates: Requirements 1.5**

### Property 4: Validation Rejects Invalid Input

_For any_ TrackerConfiguration where either apiKey is blank or brandId is blank (or both), calling validate() should return a ValidationResult.error.

**Validates: Requirements 1.3**

### Property 5: Validation Accepts Valid Input

_For any_ TrackerConfiguration with non-blank apiKey and non-blank brandId, calling validate() should return ValidationResult.valid.

**Validates: Requirements 1.2**

### Property 6: Configuration Change Persistence

_For any_ valid TrackerConfiguration that is modified and saved, loading the configuration should return the modified values, not the original values.

**Validates: Requirements 3.3, 3.4**

## Error Handling

### Input Validation

- **Empty API Key**: Display error "API Key is required"
- **Empty Brand ID**: Display error "Brand ID is required"
- **Invalid Configuration**: Prevent initialization and show validation error

### SDK Initialization Errors

- **Network Error**: Display "Failed to connect to API. Check your API URL and network connection."
- **Authentication Error**: Display "Invalid API Key. Please check your credentials."
- **Invalid Brand ID**: Display "Invalid Brand ID. Please verify and try again."

### Storage Errors

- **UserDefaults Write Failure**: Log error and continue (non-blocking)
- **UserDefaults Read Failure**: Treat as no configuration and show setup screen

## Testing Strategy

### Unit Testing

- Test TrackerConfiguration.validate() with various input combinations
- Test Environment enum URL mapping
- Test ConfigurationManager save/load/clear operations
- Test ValidationResult enum behavior

### Property-Based Testing

- **Property 1**: Generate random valid configurations, save and load, verify equality
- **Property 2**: Generate configurations with QC environment, verify URL is correct
- **Property 3**: Generate configurations with Production environment, verify URL is correct
- **Property 4**: Generate configurations with blank/non-blank values, verify validation rejects invalid
- **Property 5**: Generate valid configurations, verify validation accepts valid
- **Property 6**: Generate valid configurations, modify and save, verify loaded values match modified values

### Integration Testing

- Test full flow: Configuration Screen → Initialize → Demo Screen
- Test reconfiguration: Demo Screen → Settings → Configuration Screen → Reinitialize
- Test persistence: Save config → Kill app → Relaunch → Verify auto-initialization
- Test error handling: Invalid inputs → Error display → Correction → Success

### Testing Framework

- **Unit Tests**: XCTest
- **Property-Based Tests**: SwiftCheck (configured for minimum 100 iterations)
