# Design Document

## Overview

This design adds an interactive configuration screen to the Android example app that allows users to input API credentials and select their environment before initializing the MobileTracker SDK. The configuration persists to local storage, enabling automatic initialization on subsequent app launches.

The implementation follows a two-screen pattern:

1. **Configuration Screen**: Shown on first launch or when user requests to change settings
2. **Demo Screen**: Main tracking demo interface shown after successful initialization

## Architecture

### Component Structure

```
MainActivity
├── ConfigurationScreen (Composable)
│   ├── API Key Input Field
│   ├── Brand ID Input Field
│   ├── Environment Dropdown (QC / Production)
│   ├── Initialize Button
│   └── Error Message Display
├── DemoScreen (Composable)
│   ├── Status Display
│   ├── Tracking Demo Sections
│   └── Settings Button (to reconfigure)
└── ConfigurationManager (Singleton)
    ├── Load Configuration
    ├── Save Configuration
    └── Clear Configuration
```

### Data Flow

```
App Launch
    ↓
Check if configuration exists in SharedPreferences
    ↓
    ├─→ YES: Load config → Initialize SDK → Show Demo Screen
    └─→ NO: Show Configuration Screen
         ↓
    User enters credentials
         ↓
    Validate inputs
         ↓
    ├─→ Valid: Save to SharedPreferences → Initialize SDK → Show Demo Screen
    └─→ Invalid: Show error message
```

## Components and Interfaces

### ConfigurationManager

Handles persistence of configuration to SharedPreferences.

```kotlin
object ConfigurationManager {
    // Load configuration from SharedPreferences
    fun loadConfiguration(context: Context): TrackerConfiguration?

    // Save configuration to SharedPreferences
    fun saveConfiguration(context: Context, config: TrackerConfiguration)

    // Clear configuration from SharedPreferences
    fun clearConfiguration(context: Context)

    // Check if configuration exists
    fun hasConfiguration(context: Context): Boolean
}

data class TrackerConfiguration(
    val apiKey: String,
    val brandId: String,
    val environment: Environment
) {
    val apiUrl: String
        get() = when (environment) {
            Environment.QC -> "https://tracking.api.qc.founder-os.ai/api"
            Environment.PRODUCTION -> "https://tracking.api.founder-os.ai/api"
        }
}

enum class Environment {
    QC,
    PRODUCTION
}
```

### UI Components

#### ConfigurationScreen Composable

Displays input fields for API key, brand ID, and environment selection.

```kotlin
@Composable
fun ConfigurationScreen(
    onInitialize: (TrackerConfiguration) -> Unit,
    initialConfig: TrackerConfiguration? = null
)
```

Features:

- Four input fields: API Key, Brand ID, User ID (optional), Environment dropdown
- Dropdown for environment selection (QC / Production)
- Initialize button (enabled only when required fields are filled)
- Error message display area
- Clear visual hierarchy with Material Design 3
- User ID field is optional for convenience during testing

#### DemoScreen Composable

Enhanced version of existing MobileTrackerExampleApp with settings access.

```kotlin
@Composable
fun DemoScreen(
    isInitialized: Boolean,
    onSettingsClick: () -> Unit
)
```

Features:

- All existing demo functionality
- Settings button in top app bar
- Ability to reconfigure and reinitialize

## Data Models

### TrackerConfiguration

```kotlin
data class TrackerConfiguration(
    val apiKey: String,
    val brandId: String,
    val environment: Environment,
    val userId: String = ""
) {
    val apiUrl: String
        get() = when (environment) {
            Environment.QC -> "https://tracking.api.qc.founder-os.ai/api"
            Environment.PRODUCTION -> "https://tracking.api.founder-os.ai/api"
        }

    fun validate(): ValidationResult {
        return when {
            apiKey.isBlank() -> ValidationResult.Error("API Key is required")
            brandId.isBlank() -> ValidationResult.Error("Brand ID is required")
            else -> ValidationResult.Valid
        }
    }
}

enum class Environment {
    QC,
    PRODUCTION;

    override fun toString(): String = when (this) {
        QC -> "QC"
        PRODUCTION -> "Production"
    }
}

sealed class ValidationResult {
    object Valid : ValidationResult()
    data class Error(val message: String) : ValidationResult()
}
```

### SharedPreferences Keys

```kotlin
object PreferencesKeys {
    const val PREFS_NAME = "tracker_config"
    const val KEY_API_KEY = "api_key"
    const val KEY_BRAND_ID = "brand_id"
    const val KEY_ENVIRONMENT = "environment"
    const val KEY_USER_ID = "user_id"
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do.
Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Configuration Persistence Round Trip

_For any_ valid TrackerConfiguration with non-blank apiKey, non-blank brandId, and any environment, saving it to SharedPreferences and then loading it should produce an equivalent configuration with the same apiKey, brandId, and environment.

**Validates: Requirements 2.1, 2.2**

### Property 2: QC Environment URL Mapping

_For any_ TrackerConfiguration with environment set to QC, the apiUrl property should return exactly "https://tracking.api.qc.founder-os.ai/api".

**Validates: Requirements 1.4**

### Property 3: Production Environment URL Mapping

_For any_ TrackerConfiguration with environment set to Production, the apiUrl property should return exactly "https://tracking.api.founder-os.ai/api".

**Validates: Requirements 1.5**

### Property 4: Validation Rejects Invalid Input

_For any_ TrackerConfiguration where either apiKey is blank or brandId is blank (or both), calling validate() should return a ValidationResult.Error.

**Validates: Requirements 1.3**

### Property 5: Validation Accepts Valid Input

_For any_ TrackerConfiguration with non-blank apiKey and non-blank brandId, calling validate() should return ValidationResult.Valid.

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

- **SharedPreferences Write Failure**: Log error and continue (non-blocking)
- **SharedPreferences Read Failure**: Treat as no configuration and show setup screen

## Testing Strategy

### Unit Testing

- Test TrackerConfiguration.validate() with various input combinations
- Test Environment enum URL mapping
- Test ConfigurationManager save/load/clear operations
- Test ValidationResult sealed class behavior

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

- **Unit Tests**: JUnit 4
- **Property-Based Tests**: Kotest Property Testing (configured for minimum 100 iterations)
- **UI Tests**: Compose Testing Library

</content>
</invoke>
