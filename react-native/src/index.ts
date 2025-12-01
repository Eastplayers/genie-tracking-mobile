/**
 * Mobile Tracking SDK - React Native Bridge
 *
 * This module provides a JavaScript API for the Mobile Tracking SDK,
 * bridging to native iOS and Android implementations.
 *
 * @packageDocumentation
 */

import { NativeModules } from 'react-native'

const { MobileTrackerBridge } = NativeModules

if (!MobileTrackerBridge) {
  throw new Error(
    'MobileTrackerBridge native module is not available. ' +
      'Make sure the native module is properly linked.'
  )
}

/**
 * Configuration options for initializing the Mobile Tracking SDK
 * Web Reference: types/index.ts lines 1-30
 */
export interface MobileTrackerConfig {
  /** Brand ID - identifies your application/brand (REQUIRED) */
  apiKey: string
  /** Backend server URL where events are sent (optional, defaults to https://tracking.api.founder-os.ai/api) */
  endpoint?: string
  /** Enable debug logging */
  debug?: boolean
  /** API URL override (deprecated - use endpoint instead) */
  api_url?: string
  /** API key for backend authentication (REQUIRED) */
  x_api_key?: string
  /** Enable cross-site cookie tracking */
  cross_site_cookie?: boolean
  /** Cookie domain configuration */
  cookie_domain?: string
  /** Cookie expiration in days (default: 365) */
  cookie_expiration?: number
}

/**
 * Common profile data properties
 * Web Reference: types/index.ts CommonProfileData interface
 */
export interface CommonProfileData {
  user_id?: string
  name?: string
  email?: string
  phone?: string
  age?: number
  gender?: 'male' | 'female' | 'other'
  location?: string
  signup_date?: string
  plan?: string
  preferences?: Record<string, any>
  metadata?: Record<string, any>
  [key: string]: any
}

/**
 * Mobile Tracking SDK interface
 *
 * Provides methods for tracking events, identifying users, and tracking screen views.
 * Web Reference: types/index.ts TrackerInstance interface
 */
export interface MobileTracker {
  /**
   * Initialize the Mobile Tracking SDK
   *
   * Must be called before any tracking methods. Configures the SDK with
   * API credentials and backend endpoint.
   *
   * @param config - Configuration object with:
   *   - apiKey: Brand ID (REQUIRED)
   *   - x_api_key: API key for authentication (REQUIRED)
   *   - endpoint: Backend API URL (optional, defaults to https://tracking.api.founder-os.ai/api)
   *   - debug: Enable debug logging (optional)
   * @returns Promise that resolves when initialization is complete
   * @throws Error if initialization fails (invalid API key, invalid endpoint, etc.)
   *
   * @example
   * ```typescript
   * // Minimal configuration (uses default API URL)
   * await MobileTracker.init({
   *   apiKey: 'your-brand-id',
   *   x_api_key: 'your-api-key'
   * });
   *
   * // With custom endpoint
   * await MobileTracker.init({
   *   apiKey: 'your-brand-id',
   *   x_api_key: 'your-api-key',
   *   endpoint: 'https://custom-api.example.com'
   * });
   * ```
   */
  init(config: MobileTrackerConfig): Promise<void>

  /**
   * Track a custom event
   *
   * Records a user action or system occurrence with optional properties.
   * Events are queued and sent to the backend asynchronously.
   *
   * @param event - Name of the event to track
   * @param properties - Optional object containing event properties
   *
   * @example
   * ```typescript
   * MobileTracker.track('Button Clicked', {
   *   button_name: 'signup',
   *   screen: 'home'
   * });
   * ```
   */
  track(event: string, properties?: Record<string, any>): void

  /**
   * Identify a user with a unique ID and traits
   *
   * Associates subsequent events with the identified user. User ID and traits
   * are included in all events tracked after identification.
   *
   * @param userId - Unique identifier for the user
   * @param traits - Optional object containing user attributes
   *
   * @example
   * ```typescript
   * MobileTracker.identify('user123', {
   *   email: 'user@example.com',
   *   plan: 'pro',
   *   name: 'John Doe'
   * });
   * ```
   */
  identify(userId: string, traits?: Record<string, any>): void

  /**
   * Track a screen view
   *
   * Records when a user views a screen or page in the application.
   * Useful for understanding navigation patterns.
   *
   * @param name - Name of the screen
   * @param properties - Optional object containing screen properties
   *
   * @example
   * ```typescript
   * MobileTracker.screen('Home Screen', {
   *   section: 'main',
   *   tab: 'feed'
   * });
   * ```
   */
  screen(name: string, properties?: Record<string, any>): void

  /**
   * Update user profile with new data
   *
   * Sets profile data for the current user without requiring a user ID.
   * This is useful for updating profile information after identification.
   *
   * Web Reference: tracker.ts lines 381-403
   *
   * @param profileData - Profile data to update
   * @returns Promise that resolves when profile is updated
   *
   * @example
   * ```typescript
   * await MobileTracker.set({
   *   name: 'John Doe',
   *   email: 'john@example.com',
   *   plan: 'premium'
   * });
   * ```
   */
  set(profileData: CommonProfileData): Promise<void>

  /**
   * Set metadata for session context
   *
   * Sets session-level metadata that will be included with all subsequent events.
   * Metadata is contextual information about the session or environment.
   *
   * Web Reference: tracker.ts lines 426-461
   *
   * @param metadata - Metadata key-value pairs
   * @returns Promise that resolves when metadata is set
   *
   * @example
   * ```typescript
   * await MobileTracker.setMetadata({
   *   app_version: '1.2.3',
   *   feature_flags: ['new_ui', 'beta_feature'],
   *   environment: 'production'
   * });
   * ```
   */
  setMetadata(metadata: Record<string, any>): Promise<void>

  /**
   * Reset tracking data
   *
   * Clears all tracking data including session ID, device ID, and user information.
   * Optionally clears brand ID as well. A new session will be created after reset.
   *
   * Web Reference: tracker.ts lines 463-502
   *
   * @param all - If true, also clear brand_id (default: false)
   *
   * @example
   * ```typescript
   * // Reset session data but keep brand ID
   * MobileTracker.reset();
   *
   * // Reset all data including brand ID
   * MobileTracker.reset(true);
   * ```
   */
  reset(all?: boolean): void
}

/**
 * Mobile Tracking SDK implementation
 *
 * This class implements the MobileTracker interface by delegating to the
 * native bridge module. It handles data serialization and provides a
 * clean JavaScript API.
 */
class MobileTrackerImpl implements MobileTracker {
  /**
   * Initialize the Mobile Tracking SDK
   *
   * Validates configuration and forwards to native SDK.
   *
   * @param config - Configuration object with:
   *   - apiKey: Brand ID (identifies your application/brand) - REQUIRED
   *   - x_api_key: API key for authentication - REQUIRED
   *   - endpoint: Backend API URL (optional, defaults to https://tracking.api.founder-os.ai/api)
   *   - debug: Enable debug logging (optional)
   * @returns Promise that resolves when initialization is complete
   * @throws Error if configuration is invalid or initialization fails
   */
  async init(config: MobileTrackerConfig): Promise<void> {
    if (!config.apiKey || typeof config.apiKey !== 'string') {
      throw new Error('Invalid Brand ID (apiKey): must be a non-empty string')
    }

    if (!config.x_api_key || typeof config.x_api_key !== 'string') {
      throw new Error('Invalid API key (x_api_key): must be a non-empty string')
    }

    // endpoint is optional, will use default if not provided
    if (config.endpoint && typeof config.endpoint !== 'string') {
      throw new Error('Invalid endpoint: must be a string')
    }

    try {
      await MobileTrackerBridge.initialize(config)
    } catch (error: any) {
      // Re-throw with more context
      throw new Error(
        `Failed to initialize Mobile Tracker: ${error.message || error}`
      )
    }
  }

  /**
   * Track a custom event
   *
   * Forwards event data to native SDK. Properties are serialized and
   * passed through the bridge.
   *
   * @param event - Name of the event to track
   * @param properties - Optional object containing event properties
   */
  track(event: string, properties?: Record<string, any>): void {
    if (!event || typeof event !== 'string') {
      console.warn('MobileTracker.track: event name must be a non-empty string')
      return
    }

    MobileTrackerBridge.track(event, properties || null)
  }

  /**
   * Identify a user with a unique ID and traits
   *
   * Forwards user identification data to native SDK. Traits are serialized
   * and passed through the bridge.
   *
   * @param userId - Unique identifier for the user
   * @param traits - Optional object containing user attributes
   */
  identify(userId: string, traits?: Record<string, any>): void {
    if (!userId || typeof userId !== 'string') {
      console.warn('MobileTracker.identify: userId must be a non-empty string')
      return
    }

    MobileTrackerBridge.identify(userId, traits || null)
  }

  /**
   * Track a screen view
   *
   * Forwards screen tracking data to native SDK. Properties are serialized
   * and passed through the bridge.
   *
   * @param name - Name of the screen
   * @param properties - Optional object containing screen properties
   */
  screen(name: string, properties?: Record<string, any>): void {
    if (!name || typeof name !== 'string') {
      console.warn(
        'MobileTracker.screen: screen name must be a non-empty string'
      )
      return
    }

    MobileTrackerBridge.screen(name, properties || null)
  }

  /**
   * Update user profile with new data
   *
   * Forwards profile data to native SDK. Data is serialized and passed
   * through the bridge.
   *
   * Web Reference: tracker.ts lines 381-403
   *
   * @param profileData - Profile data to update
   * @returns Promise that resolves when profile is updated
   */
  async set(profileData: CommonProfileData): Promise<void> {
    if (!profileData || typeof profileData !== 'object') {
      throw new Error('MobileTracker.set: profileData must be an object')
    }

    try {
      await MobileTrackerBridge.set(profileData)
    } catch (error: any) {
      throw new Error(`Failed to set profile data: ${error.message || error}`)
    }
  }

  /**
   * Set metadata for session context
   *
   * Forwards metadata to native SDK. Metadata is serialized and passed
   * through the bridge.
   *
   * Web Reference: tracker.ts lines 426-461
   *
   * @param metadata - Metadata key-value pairs
   * @returns Promise that resolves when metadata is set
   */
  async setMetadata(metadata: Record<string, any>): Promise<void> {
    if (!metadata || typeof metadata !== 'object') {
      throw new Error('MobileTracker.setMetadata: metadata must be an object')
    }

    try {
      await MobileTrackerBridge.setMetadata(metadata)
    } catch (error: any) {
      throw new Error(`Failed to set metadata: ${error.message || error}`)
    }
  }

  /**
   * Reset tracking data
   *
   * Forwards reset command to native SDK. Clears session data, device ID,
   * and optionally brand ID.
   *
   * Web Reference: tracker.ts lines 463-502
   *
   * @param all - If true, also clear brand_id (default: false)
   */
  reset(all: boolean = false): void {
    MobileTrackerBridge.reset(all)
  }
}

/**
 * Default export - singleton instance of the Mobile Tracking SDK
 *
 * @example
 * ```typescript
 * import MobileTracker from '@mobiletracker/react-native';
 *
 * // Initialize (uses default API URL)
 * await MobileTracker.init({
 *   apiKey: 'your-brand-id',
 *   x_api_key: 'your-api-key'
 * });
 *
 * // Track events
 * MobileTracker.track('Button Clicked', { button_name: 'signup' });
 *
 * // Identify users
 * MobileTracker.identify('user123', { email: 'user@example.com' });
 *
 * // Track screens
 * MobileTracker.screen('Home Screen', { section: 'main' });
 * ```
 */
const tracker = new MobileTrackerImpl()

export default tracker

// Also export the class for testing purposes
export { MobileTrackerImpl }
