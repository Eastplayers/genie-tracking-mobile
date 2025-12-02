# Implementation Plan

- [x] 1. Create data models and configuration management

  - [x] 1.1 Create TrackerConfiguration struct with apiKey, brandId, userId, and environment fields

    - Implement apiUrl computed property that maps environment to correct URL
    - Implement validate() method that checks for blank apiKey and brandId
    - Make struct Codable for UserDefaults serialization
    - _Requirements: 1.2, 1.3, 1.4, 1.5_

  - [x] 1.2 Create Environment enum with qc and production cases

    - Implement displayName property for UI display
    - Make enum Codable and CaseIterable
    - _Requirements: 1.4, 1.5_

  - [x] 1.3 Create ValidationResult enum with valid and error cases

    - _Requirements: 1.3_

  - [x]\* 1.4 Write property test for environment URL mapping

    - **Feature: ios-example-config-ui, Property 2: QC Environment URL Mapping**
    - **Validates: Requirements 1.4**

  - [x]\* 1.5 Write property test for production environment URL mapping
    - **Feature: ios-example-config-ui, Property 3: Production Environment URL Mapping**
    - **Validates: Requirements 1.5**

- [x] 2. Implement configuration persistence layer

  - [x] 2.1 Create UserDefaultsKeys struct with constants for UserDefaults keys

    - Include keys for apiKey, brandId, environment, and userId
    - _Requirements: 2.1, 2.2_

  - [x] 2.2 Create ConfigurationManager as ObservableObject

    - Implement loadConfiguration() to read from UserDefaults
    - Implement saveConfiguration(\_ config:) to write to UserDefaults
    - Implement clearConfiguration() to remove stored configuration
    - Implement hasConfiguration() to check if configuration exists
    - Add @Published properties for apiKey, brandId, userId, environment, errorMessage, isInitialized
    - _Requirements: 2.1, 2.2, 2.3_

  - [x]\* 2.3 Write property test for configuration persistence round trip

    - **Feature: ios-example-config-ui, Property 1: Configuration Persistence Round Trip**
    - **Validates: Requirements 2.1, 2.2**

  - [x]\* 2.4 Write property test for configuration change persistence
    - **Feature: ios-example-config-ui, Property 6: Configuration Change Persistence**
    - **Validates: Requirements 3.3, 3.4**

- [x] 3. Implement validation logic

  - [x] 3.1 Implement TrackerConfiguration.validate() method

    - Return ValidationResult.error for blank apiKey
    - Return ValidationResult.error for blank brandId
    - Return ValidationResult.valid for valid configurations
    - _Requirements: 1.2, 1.3_

  - [x]\* 3.2 Write property test for validation rejecting invalid input

    - **Feature: ios-example-config-ui, Property 4: Validation Rejects Invalid Input**
    - **Validates: Requirements 1.3**

  - [x]\* 3.3 Write property test for validation accepting valid input
    - **Feature: ios-example-config-ui, Property 5: Validation Accepts Valid Input**
    - **Validates: Requirements 1.2**

- [x] 4. Create configuration UI screen

  - [x] 4.1 Create ConfigurationView SwiftUI view

    - Add SecureField for API Key input (masked for security)
    - Add TextField for Brand ID input
    - Add TextField for User ID input (optional)
    - Add Picker for environment selection (QC / Production)
    - Add Initialize button (enabled only when apiKey and brandId are non-blank)
    - Add error message display area
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [x] 4.2 Implement ConfigurationView state management

    - Use @StateObject for ConfigurationManager
    - Track validation error state
    - Handle environment picker selection
    - _Requirements: 1.1, 1.4, 1.5_

  - [x] 4.3 Implement ConfigurationView initialization logic
    - Load persisted configuration if available
    - Pre-fill fields with loaded values
    - _Requirements: 2.4_

- [x] 5. Update MobileTrackerExampleApp to support configuration flow

  - [x] 5.1 Modify MobileTrackerExampleApp to check for persisted configuration on startup

    - If configuration exists, load it and initialize tracker automatically
    - If no configuration exists, show ConfigurationView
    - _Requirements: 2.2, 2.3_

  - [x] 5.2 Implement initialization callback from ConfigurationView

    - Validate configuration
    - Save configuration to UserDefaults
    - Initialize MobileTracker with configuration
    - Transition to demo screen on success
    - Display error message on failure
    - _Requirements: 1.2, 1.6, 2.1_

  - [x] 5.3 Add state management for screen transitions
    - Track whether configuration view or demo view should be shown
    - Handle initialization state
    - _Requirements: 1.1, 1.6_

- [x] 6. Enhance demo screen with settings access

  - [x] 6.1 Add settings button to ContentView navigation bar

    - Button should be visible when tracker is initialized
    - _Requirements: 3.1_

  - [x] 6.2 Implement settings button click handler

    - Show ConfigurationView with current configuration pre-filled
    - _Requirements: 3.2_

  - [x] 6.3 Implement reconfiguration flow
    - Reset tracker when configuration changes
    - Reinitialize tracker with new configuration
    - Save new configuration to UserDefaults
    - Return to demo screen
    - _Requirements: 3.3, 3.4_

- [x] 7. Checkpoint - Ensure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Integration testing and refinement

  - [x] 8.1 Test full configuration flow end-to-end

    - Launch app → Show configuration screen → Enter values → Initialize → Show demo screen
    - _Requirements: 1.1, 1.2, 1.6_

  - [x] 8.2 Test persistence across app restarts

    - Save configuration → Kill app → Relaunch → Verify auto-initialization
    - _Requirements: 2.2_

  - [x] 8.3 Test reconfiguration flow

    - Initialize with config A → Click settings → Change to config B → Verify reinitialize
    - _Requirements: 3.2, 3.3, 3.4_

  - [x] 8.4 Test error handling

    - Try to initialize with blank fields → Verify error display
    - Try to initialize with invalid credentials → Verify error handling
    - _Requirements: 1.3_

  - [x] 8.5 Test configuration clearing
    - Clear configuration → Relaunch app → Verify configuration screen shown
    - _Requirements: 2.3_

- [x] 9. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
