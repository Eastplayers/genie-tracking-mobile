# Requirements Document

## Introduction

The Android example app currently requires users to manually edit the `local.env` file to configure the API key, brand ID, and API URL. This creates friction for new users trying to test the SDK. This feature adds an interactive configuration screen that allows users to input these settings directly in the app UI before initializing the tracker, with a dropdown for selecting between QC and production environments.

## Glossary

- **Brand ID**: Unique identifier for the tracking brand/organization
- **API Key**: Authentication token for backend API requests (X-API-KEY header)
- **API URL**: Backend endpoint for sending tracking events
- **QC Environment**: Quality Control/staging environment for testing
- **Production Environment**: Live production environment for real tracking
- **Configuration Screen**: Initial UI screen shown before SDK initialization
- **MobileTracker**: The core tracking SDK being demonstrated

## Requirements

### Requirement 1

**User Story:** As a developer testing the Android SDK, I want to configure the API key, brand ID, and API URL directly in the app UI, so that I don't need to manually edit configuration files.

#### Acceptance Criteria

1. WHEN the app starts and the SDK is not yet initialized THEN the system SHALL display a configuration screen with input fields for API key, brand ID, and API URL selection
2. WHEN a user enters valid values in all required fields and clicks initialize THEN the system SHALL validate the inputs and initialize the MobileTracker with the provided configuration
3. WHEN a user attempts to initialize without filling all required fields THEN the system SHALL prevent initialization and display an error message indicating which fields are missing
4. WHEN a user selects "QC" from the environment dropdown THEN the system SHALL set the API URL to "https://tracking.api.qc.founder-os.ai/api"
5. WHEN a user selects "Production" from the environment dropdown THEN the system SHALL set the API URL to "https://tracking.api.founder-os.ai/api"
6. WHEN the user successfully initializes the tracker THEN the system SHALL dismiss the configuration screen and display the main tracking demo interface

### Requirement 2

**User Story:** As a developer, I want the configuration to persist across app restarts, so that I don't need to re-enter the same values every time I launch the app.

#### Acceptance Criteria

1. WHEN the user successfully initializes the tracker with configuration values THEN the system SHALL persist the API key, brand ID, selected environment, and user ID to local storage
2. WHEN the app is restarted after a successful initialization THEN the system SHALL load the persisted configuration and automatically initialize the tracker without showing the configuration screen
3. WHEN a user manually clears the stored configuration THEN the system SHALL display the configuration screen on the next app launch
4. WHEN the app loads persisted configuration THEN the system SHALL pre-fill the configuration screen with the saved API key, brand ID, environment, and user ID for easy modification

### Requirement 3

**User Story:** As a developer, I want to be able to change the configuration after initialization, so that I can switch between different environments or accounts without reinstalling the app.

#### Acceptance Criteria

1. WHEN the tracker is initialized and the main demo screen is displayed THEN the system SHALL provide a button to access configuration settings
2. WHEN a user clicks the configuration button THEN the system SHALL display the configuration screen with the current values pre-filled
3. WHEN a user modifies configuration values and confirms the changes THEN the system SHALL reset the tracker and reinitialize it with the new configuration
4. WHEN configuration is changed THEN the system SHALL persist the new values to local storage

</content>
</invoke>
