# Design Document

## Overview

This design adds an interactive configuration screen to the React Native example app that allows users to input API credentials, select their environment, and manage user ID before initializing the MobileTracker SDK. The configuration persists to AsyncStorage, enabling automatic initialization on subsequent app launches.

The implementation follows a two-screen pattern:

1. **Configuration Screen**: Shown on first launch or when user requests to change settings
2. **Demo Screen**: Main tracking demo interface shown after successful initialization

## Architecture

### Component Structure

```
App (Root Component)
├── useEffect (Load persisted config on mount)
├── ConfigurationScreen (Conditional)
│   ├── API Key TextInput
│   ├── Brand ID TextInput
│   ├── User ID TextInput (optional)
│   ├── Environment Picker (QC / Production)
│   ├── Initialize Button
│   └── Error Message Display
└── DemoScreen (Conditional)
    ├── Status Display
    ├── Tracking Demo Sections
    └── Settings Button (to reconfigure)
```

### Data Flow

```
App Launch
    ↓
Load persisted configuration from AsyncStorage
    ↓
    ├─→ Configuration exists: Initialize SDK → Show Demo Screen
    └─→ No configuration: Show Configuration Screen
         ↓
    User enters credentials
         ↓
    Validate inputs
         ↓
    ├─→ Valid: Save to AsyncStorage → Initialize SDK → Show Demo Screen
    └─→ Invalid: Show error message
```

## Components and Interfaces

### Configuration Manager Hook

Handles persistence of configuration to AsyncStorage and state management.

```typescript
interface TrackerConfiguration {
  apiKey: string
  brandId: string
  userId: string
  environment: 'qc' | 'production'
}

interface ValidationResult {
  valid: boolean
  errors: string[]
}

function useConfigurationManager() {
  // Load configuration from AsyncStorage
  async function loadConfiguration(): Promise<TrackerConfiguration | null>

  // Save configuration to AsyncStorage
  async function saveConfiguration(config: TrackerConfiguration): Promise<void>

  // Clear configuration from AsyncStorage
  async function clearConfiguration(): Promise<void>

  // Check if configuration exists
  async function hasConfiguration(): Promise<boolean>

  // Validate configuration
  function validateConfiguration(
    config: Partial<TrackerConfiguration>
  ): ValidationResult

  // Get API URL based on environment
  function getApiUrl(environment: 'qc' | 'production'): string

  return {
    loadConfiguration,
    saveConfiguration,
    clearConfiguration,
    hasConfiguration,
    validateConfiguration,
    getApiUrl,
  }
}
```

### Configuration Utilities

```typescript
const ENVIRONMENT_URLS = {
  qc: 'https://tracking.api.qc.founder-os.ai/api',
  production: 'https://tracking.api.founder-os.ai/api',
}

const ASYNC_STORAGE_KEYS = {
  apiKey: 'tracker_api_key',
  brandId: 'tracker_brand_id',
  environment: 'tracker_environment',
  userId: 'tracker_user_id',
}

function validateConfiguration(
  config: Partial<TrackerConfiguration>
): ValidationResult {
  const errors: string[] = []

  if (!config.apiKey?.trim()) {
    errors.push('API Key is required')
  }
  if (!config.brandId?.trim()) {
    errors.push('Brand ID is required')
  }

  return {
    valid: errors.length === 0,
    errors,
  }
}

function getApiUrl(environment: 'qc' | 'production'): string {
  return ENVIRONMENT_URLS[environment]
}
```

### UI Components

#### ConfigurationScreen

Displays input fields for API key, brand ID, user ID, and environment selection.

```typescript
interface ConfigurationScreenProps {
  onInitialize: (config: TrackerConfiguration) => Promise<void>
  initialValues?: Partial<TrackerConfiguration>
}

function ConfigurationScreen({
  onInitialize,
  initialValues,
}: ConfigurationScreenProps) {
  const [apiKey, setApiKey] = useState(initialValues?.apiKey || '')
  const [brandId, setBrandId] = useState(initialValues?.brandId || '')
  const [userId, setUserId] = useState(initialValues?.userId || '')
  const [environment, setEnvironment] = useState<'qc' | 'production'>(
    initialValues?.environment || 'qc'
  )
  const [errors, setErrors] = useState<string[]>([])
  const [isLoading, setIsLoading] = useState(false)

  const handleInitialize = async () => {
    const config = { apiKey, brandId, userId, environment }
    const validation = validateConfiguration(config)

    if (!validation.valid) {
      setErrors(validation.errors)
      return
    }

    setIsLoading(true)
    try {
      await onInitialize(config)
    } catch (error) {
      setErrors([`Initialization failed: ${error.message}`])
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Configure Tracker</Text>

      <TextInput
        style={styles.input}
        placeholder="API Key"
        value={apiKey}
        onChangeText={setApiKey}
        secureTextEntry
        editable={!isLoading}
      />

      <TextInput
        style={styles.input}
        placeholder="Brand ID"
        value={brandId}
        onChangeText={setBrandId}
        editable={!isLoading}
      />

      <TextInput
        style={styles.input}
        placeholder="User ID (optional)"
        value={userId}
        onChangeText={setUserId}
        editable={!isLoading}
      />

      <Picker
        selectedValue={environment}
        onValueChange={setEnvironment}
        enabled={!isLoading}
        style={styles.picker}
      >
        <Picker.Item label="QC" value="qc" />
        <Picker.Item label="Production" value="production" />
      </Picker>

      {errors.length > 0 && (
        <View style={styles.errorContainer}>
          {errors.map((error, index) => (
            <Text key={index} style={styles.errorText}>
              • {error}
            </Text>
          ))}
        </View>
      )}

      <TouchableOpacity
        style={[styles.button, isLoading && styles.buttonDisabled]}
        onPress={handleInitialize}
        disabled={isLoading}
      >
        <Text style={styles.buttonText}>
          {isLoading ? 'Initializing...' : 'Initialize Tracker'}
        </Text>
      </TouchableOpacity>
    </ScrollView>
  )
}
```

Features:

- TextInput for API Key (masked for security)
- TextInput for Brand ID
- TextInput for User ID (optional)
- Picker for environment selection (QC / Production)
- Initialize button (enabled only when required fields are filled)
- Error message display area
- Loading state during initialization
- Pre-fills fields if configuration was previously saved

#### Enhanced App Component

Enhanced version of existing demo screen with configuration management.

```typescript
function App(): React.JSX.Element {
  const [isInitialized, setIsInitialized] = useState(false)
  const [showConfigScreen, setShowConfigScreen] = useState(false)
  const [currentConfig, setCurrentConfig] =
    useState<TrackerConfiguration | null>(null)
  const configManager = useConfigurationManager()

  useEffect(() => {
    const initializeApp = async () => {
      try {
        const savedConfig = await configManager.loadConfiguration()
        if (savedConfig) {
          setCurrentConfig(savedConfig)
          await initializeTracker(savedConfig)
          setIsInitialized(true)
        } else {
          setShowConfigScreen(true)
        }
      } catch (error) {
        console.error('Failed to load configuration:', error)
        setShowConfigScreen(true)
      }
    }

    initializeApp()
  }, [])

  const initializeTracker = async (config: TrackerConfiguration) => {
    const apiUrl = configManager.getApiUrl(config.environment)
    await MobileTracker.init({
      apiKey: config.brandId,
      x_api_key: config.apiKey,
      endpoint: apiUrl,
      debug: true,
    })
    if (config.userId) {
      MobileTracker.identify(config.userId)
    }
  }

  const handleInitialize = async (config: TrackerConfiguration) => {
    await configManager.saveConfiguration(config)
    setCurrentConfig(config)
    await initializeTracker(config)
    setIsInitialized(true)
    setShowConfigScreen(false)
  }

  const handleReconfigure = async (config: TrackerConfiguration) => {
    MobileTracker.reset(true)
    await handleInitialize(config)
  }

  if (showConfigScreen) {
    return (
      <SafeAreaView style={styles.container}>
        <ConfigurationScreen
          onInitialize={handleInitialize}
          initialValues={currentConfig || undefined}
        />
      </SafeAreaView>
    )
  }

  return (
    <SafeAreaView style={styles.container}>
      <DemoScreen
        onSettings={() => setShowConfigScreen(true)}
        currentConfig={currentConfig}
      />
    </SafeAreaView>
  )
}
```

Features:

- Loads persisted configuration on app startup
- Shows configuration screen if no configuration exists
- Automatically initializes tracker with saved configuration
- Provides settings button to reconfigure
- Handles configuration changes with tracker reset and reinitialization

## Data Models

### TrackerConfiguration

```typescript
interface TrackerConfiguration {
  apiKey: string
  brandId: string
  userId: string
  environment: 'qc' | 'production'
}
```

### Environment Mapping

```typescript
const ENVIRONMENT_URLS = {
  qc: 'https://tracking.api.qc.founder-os.ai/api',
  production: 'https://tracking.api.founder-os.ai/api',
}
```

### AsyncStorage Keys

```typescript
const ASYNC_STORAGE_KEYS = {
  apiKey: 'tracker_api_key',
  brandId: 'tracker_brand_id',
  environment: 'tracker_environment',
  userId: 'tracker_user_id',
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do.
Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Configuration Persistence Round Trip

_For any_ valid TrackerConfiguration with non-blank apiKey, non-blank brandId, and any environment, saving it to AsyncStorage and then loading it should produce an equivalent configuration with the same apiKey, brandId, environment, and userId.

**Validates: Requirements 2.1, 2.2**

### Property 2: QC Environment URL Mapping

_For any_ TrackerConfiguration with environment set to 'qc', calling getApiUrl('qc') should return exactly "https://tracking.api.qc.founder-os.ai/api".

**Validates: Requirements 1.4**

### Property 3: Production Environment URL Mapping

_For any_ TrackerConfiguration with environment set to 'production', calling getApiUrl('production') should return exactly "https://tracking.api.founder-os.ai/api".

**Validates: Requirements 1.5**

### Property 4: Validation Rejects Invalid Input

_For any_ TrackerConfiguration where either apiKey is blank or brandId is blank (or both), calling validateConfiguration() should return a ValidationResult with valid=false and errors array containing at least one error message.

**Validates: Requirements 1.3**

### Property 5: Validation Accepts Valid Input

_For any_ TrackerConfiguration with non-blank apiKey and non-blank brandId, calling validateConfiguration() should return a ValidationResult with valid=true and an empty errors array.

**Validates: Requirements 1.2**

### Property 6: Configuration Change Persistence

_For any_ valid TrackerConfiguration that is modified and saved, loading the configuration should return the modified values, not the original values.

**Validates: Requirements 3.3, 3.4**

### Property 7: Pre-filled Configuration Values

_For any_ saved TrackerConfiguration, when the configuration screen is displayed with initialValues set to the saved configuration, all input fields should be pre-filled with the corresponding saved values.

**Validates: Requirements 2.4**

## Error Handling

### Input Validation

- **Empty API Key**: Display error "API Key is required"
- **Empty Brand ID**: Display error "Brand ID is required"
- **Invalid Configuration**: Prevent initialization and show validation errors

### SDK Initialization Errors

- **Network Error**: Display "Failed to connect to API. Check your API URL and network connection."
- **Authentication Error**: Display "Invalid API Key. Please check your credentials."
- **Invalid Brand ID**: Display "Invalid Brand ID. Please verify and try again."

### Storage Errors

- **AsyncStorage Write Failure**: Log error and display "Failed to save configuration. Please try again."
- **AsyncStorage Read Failure**: Treat as no configuration and show setup screen

## Testing Strategy

### Unit Testing

- Test validateConfiguration() with various input combinations
- Test getApiUrl() with both environments
- Test configuration serialization/deserialization
- Test AsyncStorage key constants

### Property-Based Testing

- **Property 1**: Generate random valid configurations, save and load, verify equality
- **Property 2**: Generate configurations with QC environment, verify URL is correct
- **Property 3**: Generate configurations with Production environment, verify URL is correct
- **Property 4**: Generate configurations with blank/non-blank values, verify validation rejects invalid
- **Property 5**: Generate valid configurations, verify validation accepts valid
- **Property 6**: Generate valid configurations, modify and save, verify loaded values match modified values
- **Property 7**: Generate valid configurations, verify pre-filled values match saved values

### Integration Testing

- Test full flow: Configuration Screen → Initialize → Demo Screen
- Test reconfiguration: Demo Screen → Settings → Configuration Screen → Reinitialize
- Test persistence: Save config → Simulate app restart → Verify auto-initialization
- Test error handling: Invalid inputs → Error display → Correction → Success

### Testing Framework

- **Unit Tests**: Jest
- **Property-Based Tests**: fast-check (configured for minimum 100 iterations)
