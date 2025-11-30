import type {
  TrackerConfig,
  TrackerInstance,
  UpdateProfileData,
  CommonEventNames,
  CommonEventAttributes,
  CommonProfileData,
} from '../types'
import { DEFAULT_CONFIG, mergeConfig, validateConfig } from './config'
import { ApiClient } from '../utils/api'
import { autoInitFromScript, initFromGlobalConfig } from '../utils/auto-init'
// import { WidgetManager } from "./widget-manager";
import popupSettings from './popup-settings'
import {
  initCrossDomainTracking,
  getCrossDomainLink,
  parseCrossDomainSessionId,
} from '../utils/cross-domain'
import * as psl from 'psl'

export class FounderOS implements TrackerInstance {
  private getParentDomain(hostname: string): string | null {
    try {
      if (
        !hostname ||
        hostname === 'localhost' ||
        /^\d+\.\d+\.\d+\.\d+$/.test(hostname)
      ) {
        return null
      }
      const registrable =
        (psl as any).get?.(hostname) || (psl as any).parse?.(hostname)?.domain
      if (registrable && typeof registrable === 'string') {
        return `.${registrable}`
      }
      return null
    } catch {
      return null
    }
  }
  private config: TrackerConfig = DEFAULT_CONFIG
  private apiClient?: ApiClient
  private brandId: string = ''
  private initialized = false
  private isInitPending = false
  private initPromise: Promise<void> | null = null
  private initTimeout: NodeJS.Timeout | null = null
  private pendingTrackCalls: Array<
    [string, Record<string, any>?, Record<string, any>?]
  > = []
  private lastTrackedUrl?: string
  // private widgetManager?: WidgetManager;

  /**
   * Initialize the tracker with brand ID and configuration
   * @param brandId - Your brand ID (string or number)
   * @param config - Configuration options like {debug: true, api_url: 'https://api.example.com'}
   * @example
   * await tracker.init('925', {debug: true, api_url: 'https://tracking.api.dev.cxgenie.ai/api'})
   */
  async init(
    brandId: string,
    config: Partial<TrackerConfig> = {}
  ): Promise<void> {
    // If already initialized, return immediately
    if (this.initialized) {
      if (this.config.debug) {
        console.warn('[FounderOS] Already initialized')
      }
      return
    }

    // If initialization is already in progress, wait for it to complete
    if (this.isInitPending && this.initPromise) {
      if (this.config.debug) {
        console.warn(
          '[FounderOS] Initialization already in progress, waiting...'
        )
      }
      return this.initPromise
    }

    // Set pending state and create promise
    this.isInitPending = true

    // Create timeout to prevent stuck initialization (30 seconds)
    this.initTimeout = setTimeout(() => {
      if (this.config.debug) {
        console.error('[FounderOS] Initialization timeout - resetting state')
      }
      this.isInitPending = false
      this.initPromise = null
    }, 30000) as any

    // Create and store the initialization promise
    this.initPromise = this.performInitialization(brandId, config)

    try {
      await this.initPromise
    } finally {
      // Clear timeout if initialization completes normally
      if (this.initTimeout) {
        clearTimeout(this.initTimeout)
        this.initTimeout = null
      }
    }
  }

  private async performInitialization(
    brandId: string,
    config: Partial<TrackerConfig> = {}
  ): Promise<void> {
    try {
      if (!brandId) {
        throw new Error('Brand ID is required')
      }

      if (isNaN(Number(brandId))) {
        throw new Error('Brand ID must be a number')
      }

      // Store brandId and merge config first
      this.brandId = String(brandId)
      this.config = mergeConfig(config)

      try {
        validateConfig(this.config)
      } catch (error) {
        throw new Error(
          `[FounderOS] Invalid configuration: ${(error as Error).message}`
        )
      }

      // Initialize API client (but don't create session yet)
      this.apiClient = new ApiClient(this.config, this.brandId)
      this.apiClient.setBrandId(parseInt(this.brandId, 10))

      // Mark as initialized immediately to allow tracking to start
      this.initialized = true

      // Initialize popup settings (non-blocking)
      try {
        popupSettings.init({ apiBaseUrl: this.config.api_url || '', brandId })
      } catch (e) {
        if (this.config.debug) {
          console.warn('[FounderOS] Popup settings init error:', e)
        }
      }

      if (this.config.debug) {
        console.log(
          '[FounderOS] Fast initialization completed - loading consent config in background'
        )
      }

      // Initialize all background services without blocking
      setTimeout(() => {
        this.initializeBackgroundServices()
      }, 0)
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Initialization failed:', error)
      }
      // DO NOT re-throw error to prevent crashing the embedding page
      // Just log and gracefully degrade
    } finally {
      this.isInitPending = false
      // Only flush pending calls if tracking is allowed
      if (this.initialized) {
        await this.flushPendingTrackCalls()
      }
    }
  }

  /**
   * Initialize background services (widget and consent) without blocking
   */
  private async initializeBackgroundServices(): Promise<void> {
    // Setup page view tracking
    this.setupPageViewTracking()
  }

  /**
   * Check if tracking operations are allowed based on consent
   */
  private isTrackingAllowed(): boolean {
    return true
  }

  /**
   * Create tracking session asynchronously without blocking
   */
  private async createSessionAsync(): Promise<void> {
    try {
      if (!this.apiClient || !this.brandId) return

      // Check for existing session
      let sessionId = this.apiClient.getSessionId()

      if (!sessionId) {
        // Create new session in background
        sessionId = await this.apiClient.createTrackingSession(
          parseInt(this.brandId, 10)
        )

        if (this.config.debug) {
          console.log(
            '[FounderOS] Session created asynchronously:',
            sessionId ? 'success' : 'failed'
          )
        }

        // Flush any pending events now that session exists
        if (sessionId && this.pendingTrackCalls.length > 0) {
          await this.flushPendingTrackCalls()
          if (this.config.debug) {
            console.log(
              '[FounderOS] Flushed pending track calls after session creation'
            )
          }
        }
      }

      // Initialize cross-domain tracking if enabled
      if (this.config.cross_site_cookie) {
        const urlSessionId = parseCrossDomainSessionId()
        if (urlSessionId) {
          await initCrossDomainTracking(this.apiClient, {
            ...this.config,
            brand_id: this.brandId,
          })
          if (this.config.debug) {
            console.log('[FounderOS] Cross-domain tracking initialized')
          }
        }
      }
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Error creating session:', error)
      }
    }
  }

  /**
   * Auto-initialize tracker from script tag or global config
   * @returns Promise<boolean> - true if initialization was successful
   * @example
   * const success = await tracker.autoInit()
   * if (success) console.log('Auto-init successful')
   */
  async autoInit(): Promise<boolean> {
    if (this.initialized || this.isInitPending) {
      if (this.config.debug) {
        console.warn(
          '[FounderOS] Already initialized or initialization pending'
        )
      }
      return true
    }

    try {
      // Try auto-init from script tag first
      const scriptInitSuccess = await autoInitFromScript(this)

      if (!scriptInitSuccess) {
        // Fallback to global config
        const globalInitSuccess = await initFromGlobalConfig(this)

        if (!globalInitSuccess) {
          if (this.config.debug) {
            console.log('[FounderOS] No auto-init configuration found')
          }
          return false
        }
      }

      return true
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Auto-initialization error:', error)
      }
      return false
    }
  }

  /**
   * Track an event with optional attributes and metadata
   * @param eventName - The name of the event (e.g., 'BUTTON_CLICK', 'PAGE_VIEW', 'USER_SIGNUP')
   * @param attributes - Event properties like {button: 'primary', page: '/home', user_id: '123'}
   * @param metadata - Technical metadata like {flow_id: 'abc', session_context: {}}
   * @example
   * tracker.Event.track('BUTTON_CLICK', {button: 'primary', section: 'header'})
   * tracker.Event.track('PAGE_VIEW', {page: '/home', title: 'Homepage'})
   * tracker.Event.track('USER_SIGNUP', {email: 'user@example.com', source: 'google'})
   */
  async track(
    eventName: CommonEventNames,
    attributes?: CommonEventAttributes,
    metadata?: Record<string, any>
  ): Promise<void> {
    // If init is pending, queue the track call
    if (this.isInitPending) {
      this.pendingTrackCalls.push([eventName, attributes, metadata])
      return
    }

    if (!this.initialized || !this.apiClient) {
      if (this.config.debug) {
        console.warn('[FounderOS] Not initialized. Call Tracker.init() first.')
      }
      return
    }

    const sessionId = this.apiClient.getSessionId()
    const brandId = this.apiClient.getBrandId()

    if (!sessionId) {
      // Queue the event if session is missing but tracker is initialized
      this.pendingTrackCalls.push([eventName, attributes, metadata])
      if (this.config.debug) {
        console.warn(
          '[FounderOS] Missing session ID - queuing event:',
          eventName
        )
      }
      return
    }

    // Additional consent check for tracking
    if (!this.isTrackingAllowed()) {
      if (this.config.debug) {
        console.warn(
          '[FounderOS] Event blocked - consent not granted:',
          eventName
        )
      }
      return
    }
    if (!brandId) {
      if (this.config.debug) {
        console.warn('[FounderOS] Missing brand ID')
      }
      return
    }
    const eventData = { ...attributes, ...metadata }

    try {
      await this.apiClient.trackEvent(brandId, sessionId, eventName, eventData)

      if (this.config.debug) {
        console.log('[FounderOS] Event tracked:', eventName, attributes)
      }
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Error tracking event:', error)
      }
    }
  }

  /**
   * Identify a user with their ID and profile data
   * @param user_id - Unique user identifier (string)
   * @param profileData - User profile information like {name: 'John', email: 'john@example.com', age: 25}
   * @example
   * tracker.identify('user_123', {name: 'John Doe', email: 'john@example.com'})
   * tracker.identify('user_456', {name: 'Jane', phone: '+1234567890', location: 'Vietnam'})
   */
  async identify(user_id: string, profileData?: CommonProfileData) {
    if (!this.initialized || !this.apiClient) {
      if (this.config.debug) {
        console.warn('[FounderOS] Not initialized. Call Tracker.init() first.')
      }
      return
    }

    // Check consent before sending user data
    if (!this.isTrackingAllowed()) {
      if (this.config.debug) {
        console.warn('[FounderOS] identify() blocked - consent not granted')
      }
      return
    }

    if (!user_id) {
      if (this.config.debug) {
        console.warn('[FounderOS] user_id is required for identify()')
      }
      return
    }

    if (profileData) {
      await this.updateProfile({ ...profileData, user_id })
    }
  }
  /**
   * Update user profile with new data
   * @param profileData - Profile data to update like {name: 'New Name', age: 30, preferences: {}}
   * @example
   * tracker.set({name: 'Updated Name', last_login: '2024-01-01'})
   * tracker.set({preferences: {theme: 'dark', language: 'en'}})
   */
  async set(profileData: CommonProfileData) {
    if (!this.initialized || !this.apiClient) {
      if (this.config.debug) {
        console.warn('[FounderOS] Not initialized. Call Tracker.init() first.')
      }
      return
    }

    // Check consent before sending user data
    if (!this.isTrackingAllowed()) {
      if (this.config.debug) {
        console.warn('[FounderOS] set() blocked - consent not granted')
      }
      return
    }

    await this.updateProfile(profileData)
  }

  /**
   * Update user profile with detailed data (internal method)
   * @param data - UpdateProfileData with specific fields like {name, email, phone, metadata}
   */
  async updateProfile(data: UpdateProfileData) {
    if (!this.initialized || !this.apiClient) {
      if (this.config.debug) {
        console.warn('[FounderOS] Not initialized. Call Tracker.init() first.')
      }
      return
    }

    const brandId = this.apiClient.getBrandId()
    if (!brandId) {
      if (this.config.debug) {
        console.error('[FounderOS] No brand_id available')
      }
      return
    }

    try {
      // If email is provided, update session email first

      await this.apiClient.updateProfile(data, brandId)

      if (this.config.debug) {
        console.log('[FounderOS] Profile updated successfully')
      }
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Error updating profile:', error)
      }
    }
  }

  /**
   * Set metadata for tracking context
   * @param metadata - Metadata object like {session_context: {}, custom_fields: {}}
   * @example
   * tracker.setMetadata({session_type: 'premium', feature_flags: ['new_ui']})
   */
  async setMetadata(metadata: Record<string, any>) {
    if (!this.initialized || !this.apiClient) {
      if (this.config.debug) {
        console.warn('[FounderOS] Not initialized. Call Tracker.init() first.')
      }
      return
    }

    // Check consent before sending metadata
    if (!this.isTrackingAllowed()) {
      if (this.config.debug) {
        console.warn('[FounderOS] setMetadata() blocked - consent not granted')
      }
      return
    }

    try {
      const brandId = this.apiClient.getBrandId()
      if (!brandId) {
        if (this.config.debug) {
          console.error('[FounderOS] No brand_id available')
        }
        return
      }

      await this.apiClient.setMetadata(metadata, brandId)

      if (this.config.debug) {
        console.log('[FounderOS] Metadata set successfully')
      }
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Error setting metadata:', error)
      }
    }
  }

  /**
   * Reset tracker state and clear all stored data
   * @example
   * tracker.reset() // Clears cookies, localStorage, and resets session
   */
  reset(all?: boolean): void {
    if (typeof document !== 'undefined') {
      // Clear all tracking cookies
      const domain = this.config.cookie_domain || window.location.hostname
      const cookiePrefix = `__GT_${this.brandId}_`

      // build parent domain like `.example.com` using PSL for accuracy
      const hostname = (domain || '').split(':')[0]
      const parentDomain = this.getParentDomain(hostname)

      const cookiesToClear = [
        'session_id',
        'device_id',
        'session_email',
        'identify_id',
      ]
      if (all) {
        cookiesToClear.push('brand_id')
      }
      cookiesToClear.forEach((cookie) => {
        if (parentDomain) {
          this.apiClient?.clearCookieByName(
            `${cookiePrefix}${cookie}`,
            parentDomain
          )
        }
        this.apiClient?.clearCookieByName(`${cookiePrefix}${cookie}`, domain)
      })
    }

    if (typeof localStorage !== 'undefined') {
      // Clear localStorage items
      const keys = Object.keys(localStorage)
      keys.forEach((key) => {
        if (key.startsWith(`__GT_${this.brandId}_`)) {
          localStorage.removeItem(key)
        }
      })
    }

    // Reset internal state
    this.isInitPending = false
    this.pendingTrackCalls = []
    this.lastTrackedUrl = undefined
    if (this.brandId) {
      this.apiClient?.createTrackingSession(parseInt(this.brandId, 10))
    }

    if (this.config.debug) {
      console.log('[FounderOS] Reset completed')
    }
  }

  /**
   * Clean tracking parameters from the current URL
   * This method is automatically called during initialization
   * but can be manually called if needed
   *
   * @example
   * // Remove tracking parameters from the current URL
   * tracker.cleanUrl();
   */
  cleanUrl(): void {
    import('../utils/url-cleaner').then((module) => {
      module.cleanTrackingParamFromUrl()
    })
  }

  /**
   * Generate a URL with cross-domain tracking parameters
   * This allows tracking the same user across different domains
   *
   * @param url The destination URL to add tracking parameters to
   * @returns URL with tracking parameters added
   * @example
   * // Returns: https://example.com?gt_session_id=abc123
   * const trackingUrl = tracker.getCrossDomainUrl('https://example.com');
   */
  getCrossDomainUrl(url: string): string {
    if (!this.initialized || !this.apiClient) {
      if (this.config.debug) {
        console.warn(
          '[FounderOS] Cannot get cross-domain URL: Tracker not initialized'
        )
      }
      return url
    }

    // Get the session ID for cross-domain tracking
    const sessionId = this.apiClient.getSessionId()
    if (!sessionId) {
      if (this.config.debug) {
        console.warn('[FounderOS] Cannot get cross-domain URL: No session ID')
      }
      return url
    }

    // Generate the cross-domain link with the session ID
    return getCrossDomainLink(url, sessionId)
  }

  /**
   * Reinitialize the tracker with a new brand ID and configuration
   * @param brandId - Your brand ID (string or number)
   * @param config - Configuration options
   * @example
   * await tracker.reInit('925', {debug: true, api_url: 'https://tracking.api.dev.cxgenie.ai/api'})
   */
  async reInit(
    brandId: string,
    config: Partial<TrackerConfig> = {}
  ): Promise<void> {
    if (!this.initialized) {
      if (this.config.debug) {
        console.warn('[FounderOS] Not initialized yet. Call init() first.')
      }
      return
    }

    this.isInitPending = true
    this.reset()

    try {
      if (!brandId) {
        throw new Error('Brand ID is required')
      }

      if (isNaN(Number(brandId))) {
        throw new Error('Brand ID must be a number')
      }

      // brandId stored in apiClient instead
      this.config = mergeConfig(config)

      try {
        validateConfig(this.config)
      } catch (error) {
        throw new Error(
          `[FounderOS] Invalid configuration: ${(error as Error).message}`
        )
      }

      // Initialize API client
      this.apiClient = new ApiClient(this.config, brandId)
      this.apiClient.setBrandId(parseInt(brandId, 10))

      // Check for existing session
      let sessionId = this.apiClient.getSessionId()

      if (!sessionId) {
        // Create new session without email
        sessionId = await this.apiClient.createTrackingSession(
          parseInt(brandId, 10)
        )

        if (!sessionId) {
          throw new Error('Failed to create tracking session')
        }
      }

      this.initialized = true

      // Initialize popup settings (non-blocking) on reinit as well
      try {
        popupSettings.init({ apiBaseUrl: this.config.api_url || '', brandId })
      } catch (e) {
        if (this.config.debug) {
          console.warn('[FounderOS] Popup settings reinit error:', e)
        }
      }

      // Setup page view tracking
      this.setupPageViewTracking()
    } catch (error) {
      if (this.config.debug) {
        console.error('[FounderOS] Initialization failed:', error)
      }
      // DO NOT re-throw error to prevent crashing the embedding page
      // Just log and gracefully degrade
    } finally {
      this.isInitPending = false
      this.initPromise = null
      // Clear timeout if initialization completes
      if (this.initTimeout) {
        clearTimeout(this.initTimeout)
        this.initTimeout = null
      }
      // Pending calls will be flushed by createSessionAsync() after session creation
      // No need to flush here as it could cause infinite loops without a session
    }
  }

  private async flushPendingTrackCalls(): Promise<void> {
    while (this.pendingTrackCalls.length > 0) {
      const [eventName, attributes, metadata] = this.pendingTrackCalls.shift()!
      await this.track(eventName, attributes, metadata)
    }
  }

  private setupPageViewTracking(): void {
    if (typeof window === 'undefined') return

    const url = window.location.href

    // Track initial page view
    this.track('VIEW_PAGE', { url })
    this.lastTrackedUrl = url

    const trackPageView = () => {
      const currentUrl = window.location.href
      if (currentUrl !== this.lastTrackedUrl) {
        this.lastTrackedUrl = currentUrl
        this.track('VIEW_PAGE', { url: currentUrl })
      }
    }

    // Override history methods to detect navigation
    const originalPushState = history.pushState
    history.pushState = function (...args) {
      originalPushState.apply(this, args)
      trackPageView()
    }

    const originalReplaceState = history.replaceState
    history.replaceState = function (...args) {
      originalReplaceState.apply(this, args)
      trackPageView()
    }

    // Listen to popstate for browser navigation (back/forward)
    window.addEventListener('popstate', trackPageView)
  }
}

// Create singleton instance
const tracker = new FounderOS()

export default tracker
