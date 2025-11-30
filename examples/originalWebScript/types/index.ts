export interface TrackerConfig {
  flow: boolean;
  cross_site_cookie: boolean;
  cross_subdomain_cookie: boolean;
  error_reporter?: (error: Error) => void;
  persistence: "cookie" | "localstorage" | "none";
  persistence_name: string;
  cookie_domain?: string;
  cookie_name: string;
  debug: boolean;
  track_links_timeout: number;
  cookie_expiration: number;
  session_timeout?: number; // Session timeout in milliseconds
  upgrade: boolean;
  disable_persistence: boolean;
  disable_cookie: boolean;
  ip: boolean;
  property_blacklist: string[];
  batch_requests: boolean;
  batch_size: number;
  batch_flush_interval_ms: number;
  batch_request_timeout_ms: number;
  batch_autostart: boolean;
  api_url?: string;
  x_api_key?: string; // API key for authentication
  environment?: "local" | "development" | "qc" | "production"; // Add environment setting
  widget_url?: string; // Explicit widget URL to override auto-detection
  // Widget options
  enable_widget?: boolean; // Enable/disable widget functionality
  widget_auto_start?: boolean; // Auto-start widget on page load
}

export interface TrackOptions {
  send_now?: boolean;
  delay_ms?: number;
}

// Common event types for better IntelliSense
export type CommonEventNames =
  | "PAGE_VIEW"
  | "BUTTON_CLICK"
  | "USER_SIGNUP"
  | "USER_LOGIN"
  | "PURCHASE"
  | "ADD_TO_CART"
  | "FORM_SUBMIT"
  | "SCROLL_MILESTONE"
  | "VIDEO_PLAY"
  | "DOWNLOAD"
  | "SEARCH"
  | "SHARE"
  | "ERROR"
  | string; // Allow custom events

// Common profile properties for suggestions
export interface CommonProfileData {
  user_id?: string;
  name?: string;
  email?: string;
  phone?: string;
  age?: number;
  gender?: "male" | "female" | "other";
  location?: string;
  signup_date?: string;
  plan?: string;
  preferences?: Record<string, any>;
  metadata?: Record<string, any>;
  [key: string]: any; // Allow custom properties
}

// Common event attributes for suggestions
export interface CommonEventAttributes {
  page?: string;
  url?: string;
  title?: string;
  button?: string;
  section?: string;
  category?: string;
  action?: string;
  value?: number;
  currency?: string;
  product_id?: string;
  user_id?: string;
  session_id?: string;
  timestamp?: number;
  [key: string]: any; // Allow custom attributes
}

export interface EventData {
  eventName: string;
  attributes?: Record<string, any>;
  timestamp: string;
  sessionId: string;
  userId?: string;
}

export interface ProfileData {
  userId?: string;
  sessionId: string;
  attributes: Record<string, any>;
  timestamp: string;
}

export interface BatchQueue {
  events: EventData[];
  profiles: ProfileData[];
}

export interface StorageInterface {
  get(key: string): string | null;
  set(key: string, value: string, expires?: number): void;
  remove(key: string): void;
  clear(): void;
}

// Event interface for better type checking
export interface EventTracker {
  /**
   * Track an event with attributes and metadata
   * @param eventName - Event name (e.g., 'PAGE_VIEW', 'BUTTON_CLICK', 'USER_SIGNUP')
   * @param attributes - Event properties like {button: 'primary', page: '/home'}
   * @param metadata - Technical metadata like {flow_id: 'abc'}
   */
  track(
    eventName: CommonEventNames,
    attributes?: CommonEventAttributes,
    metadata?: Record<string, any>,
  ): Promise<void>;
}

// Profile interface for better type checking
export interface ProfileManager {
  /**
   * Identify a user with profile data
   * @param userId - Unique user identifier
   * @param profileData - User profile like {name: 'John', email: 'john@example.com'}
   */
  identify(userId: string, profileData?: CommonProfileData): Promise<void>;
  /**
   * Update user profile data
   * @param profileData - Profile data to update
   */
  set(profileData: CommonProfileData): Promise<void>;
  updateProfile(data: UpdateProfileData): Promise<void>;
  setMetadata(metadata: Record<string, any>): Promise<void>;
}

export interface TrackerInstance extends EventTracker, ProfileManager {
  init(brandId: string, config?: Partial<TrackerConfig>): Promise<void>;
  autoInit?(): Promise<boolean>;
  reset(): void;

  /**
   * Generate a URL with cross-domain tracking parameters
   * @param url The destination URL
   * @returns URL with tracking parameters added
   */
  getCrossDomainUrl(url: string): string;

  /**
   * Clean tracking parameters from the current URL
   * This method is automatically called during initialization
   * but can be manually called if needed
   */
  cleanUrl(): void;
}

// API Interfaces based on the provided JavaScript
export interface TrackingSessionRequest {
  os_name: string;
  device_type: string;
  device_id: string;
  email?: string;
  metadata?: Record<string, any>;
  brand_id: number;
}

export interface TrackingSessionResponse {
  data: {
    id: string;
  };
}

export interface UpdateProfileData {
  name?: string;
  phone?: string;
  gender?: string;
  business_domain?: string;
  metadata?: Record<string, any>;
  email?: string;
  source?: string;
  birthday?: string;
  user_id?: string;
  [key: string]: any; // for extra fields
}

export interface TrackEventRequest {
  brand_id: number;
  session_id: string;
  event_name: string;
  data: Record<string, any>;
  metadata?: Record<string, any>;
  flow_context?: {
    url: string;
    room_id?: string;
  };
}

export interface DeviceInfo {
  os_name: string;
  device_type: string;
  device_id: string;
}

export interface LocationData {
  latitude: number;
  longitude: number;
  accuracy: number;
}

export interface LinkVisitorToSession {
  source_session_id: string; // session to link from
  current_session_id: string; // session to link to
  device_id?: string; // device ID associated with the sessions
  brand_id?: number; // brand ID for the sessions
}
