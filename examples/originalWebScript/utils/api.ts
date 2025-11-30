import type {
  TrackerConfig,
  TrackingSessionResponse,
  UpdateProfileData,
  DeviceInfo,
  LocationData,
  LinkVisitorToSession,
} from "../types";

export class ApiClient {
  private config: TrackerConfig;
  private cookiePrefix: string = "__GT_";

  constructor(config: TrackerConfig, brandId: string) {
    this.config = config;
    this.cookiePrefix = `__GT_${brandId}_`;
  }

  private getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      "Content-Type": "application/json",
    };

    // Add x-api-key if provided
    if (this.config.x_api_key) {
      headers["x-api-key"] = this.config.x_api_key;
    }

    return headers;
  }

  private getCookie(name: string): string | null {
    if (typeof document === "undefined") return null;

    const cookies = document.cookie.split("; ");
    let result = null;
    for (const cookie of cookies) {
      const [key, value] = cookie.split("=");
      if (key === this.cookiePrefix + name) {
        result = decodeURIComponent(value);
      }
    }
    return result;
  }

  private writeCookie(
    name: string,
    value: string,
    options: { expires?: number; domain?: string } = {},
  ): void {
    try {
      if (typeof document === "undefined") return;

      let cookieStr =
        encodeURIComponent(this.cookiePrefix + name) + "=" + encodeURIComponent(value);

      if (options.expires) {
        const date = new Date();
        date.setTime(date.getTime() + options.expires * 24 * 60 * 60 * 1000);
        cookieStr += "; Expires=" + date.toUTCString();
      }

      cookieStr += "; Path=/";

      if (options.domain !== undefined) {
        cookieStr += "; Domain=" + options.domain;
      } else if (typeof window !== "undefined") {
        const domain = window.location.hostname;
        cookieStr += "; Domain=" + domain;
      }

      const isLocalhost = typeof window !== "undefined" && window.location.hostname === "localhost";
      console.log("isLocalhost", isLocalhost);

      if (this.config.cross_site_cookie && !isLocalhost) {
        cookieStr += "; SameSite=None; Secure";
      } else {
        cookieStr += "; SameSite=Lax";
      }

      // Also store in localStorage as backup
      if (typeof localStorage !== "undefined") {
        localStorage.setItem(this.cookiePrefix + name, value);
      }

      document.cookie = cookieStr;
    } catch (error) {
      console.error("Error writing cookie:", error);
    }
  }

  private clearCookie(name: string, options: { domain?: string } = {}): void {
    try {
      if (typeof document === "undefined") return;
      // Set cookie with expiration date in the past to clear it
      let cookieStr = name + "=; Expires=Thu, 01 Jan 1970 00:00:00 GMT";

      cookieStr += "; Path=/";

      if (options.domain !== undefined) {
        cookieStr += "; Domain=" + options.domain;
      } else if (typeof window !== "undefined") {
        const domain = window.location.hostname;
        cookieStr += "; Domain=" + domain;
      }

      const isLocalhost = typeof window !== "undefined" && window.location.hostname === "localhost";

      if (this.config.cross_site_cookie && !isLocalhost) {
        cookieStr += "; SameSite=None; Secure";
      } else {
        cookieStr += "; SameSite=Lax";
      }

      // Also remove from localStorage
      if (typeof localStorage !== "undefined") {
        localStorage.removeItem(name);
      }

      document.cookie = cookieStr;
    } catch (error) {
      console.error("Error clearing cookie:", error);
    }
  }

  /**
   * Clear all tracking cookies and localStorage
   */
  clearAllTrackingCookies(): void {
    if (typeof document === "undefined") return;
    
    // CRITICAL: Don't delete consent cookie - only clear tracking cookies
    const cookiesToClear = ['device_id', 'session_id', 'session_email', 'identify_id'];
    
    cookiesToClear.forEach(cookieName => {
      this.clearCookie(this.cookiePrefix + cookieName);
      
      // Also clear from localStorage
      if (typeof localStorage !== "undefined") {
        localStorage.removeItem(this.cookiePrefix + cookieName);
      }
    });
    
    if (this.config.debug) {
      console.log('[ApiClient] All tracking cookies cleared (consent cookie preserved)');
    }
  }

  private consentConfig: any = null;

  /**
   * Set consent configuration from tracker
   */
  setConsentConfig(config: any): void {
    this.consentConfig = config;
  }

  /**
   * Check if consent has been granted for tracking based on consent_mode
   */
  isConsentGranted(): boolean {
    if (typeof document === "undefined") return true; // Skip on server-side
    
    const consentCookie = this.getCookie('gt_consent');
    
    if (!this.consentConfig) {
      return true; // No consent config means no restrictions
    }
    
    if (this.consentConfig.consent_mode === 'opt_in') {
      // Opt-in: Must explicitly accept to allow tracking
      return consentCookie === 'accepted';
    } else if (this.consentConfig.consent_mode === 'opt_out') {
      // Opt-out: Allow tracking unless explicitly declined
      return consentCookie !== 'declined';
    }
    
    return true; // Default to allow if mode unknown
  }

  private generateUUID(): string {
    if (typeof crypto !== "undefined" && crypto.randomUUID) {
      return crypto.randomUUID();
    }

    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      const v = c === "x" ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }

  private detectOS(userAgent: string): string {
    if (/android/i.test(userAgent)) return "Android";
    if (/iphone|ipad|ipod/i.test(userAgent)) return "iOS";
    if (/windows phone/i.test(userAgent)) return "Windows Phone";
    if (/windows/i.test(userAgent)) return "Windows";
    if (/mac os/i.test(userAgent)) return "MacOS";
    if (/cros/i.test(userAgent)) return "ChromeOS";
    if (/linux/i.test(userAgent)) return "Linux";
    return "Unknown OS";
  }

  /**
   * Get the current device ID, used for cross-domain tracking
   */
  getDeviceId(): string | null {
    return this.getCookie("device_id");
  }

  async writeDeviceId(): Promise<string> {
    let deviceId = this.generateUUID();

    this.writeCookie("device_id", deviceId, { expires: 365, domain: this.config.cookie_domain });
    return deviceId;
  }

  async getDeviceInfo(): Promise<DeviceInfo> {
    let userAgent = "";
    if (typeof navigator !== "undefined" && "userAgent" in navigator) {
      userAgent = navigator.userAgent.toLowerCase();
    }

    const osName = this.detectOS(userAgent);
    let deviceType = "Unknown Device";

    // Get or generate unique device ID
    let deviceId = this.getCookie("device_id");
    if (!deviceId) {
      deviceId = this.generateUUID();
      this.writeCookie("device_id", deviceId, { expires: 365, domain: this.config.cookie_domain });
    }

    // Detect Device Type
    if (/mobile|android|iphone|ipad|ipod/.test(userAgent)) {
      deviceType = "Mobile";
    } else if (/tablet/.test(userAgent)) {
      deviceType = "Tablet";
    } else {
      deviceType = "Desktop";
    }

    return {
      os_name: osName,
      device_type: deviceType,
      device_id: deviceId,
    };
  }

  async createTrackingSession(brandId: number): Promise<string | null> {
    // CONSENT GATE: Block session creation without consent
    if (!this.isConsentGranted()) {
      if (this.config.debug) {
        console.log('[ApiClient] Session creation blocked - consent not granted');
      }
      return null;
    }

    try {
      const deviceData = await this.getDeviceInfo();

      // Use exact payload structure from original JS file
      const payload = {
        ...deviceData,
        brand_id: brandId,
      };

      const response = await fetch(`${this.config.api_url}/v2/tracking-session`, {
        method: "POST",
        headers: this.getHeaders(),
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`Failed to create session: ${response.status}`);
      }

      const data = await response.json();
      const sessionId = data.data.id;

      if (sessionId) {
        this.writeCookie("session_id", sessionId, {
          expires: 365,
          domain: this.config.cookie_domain,
        });
        // Request location and update session location (with consent check)
        this.requestLocationUpdate(sessionId);
      }

      return sessionId;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error creating tracking session:", error);
      }
      return null;
    }
  }

  private requestLocationUpdate(sessionId: string): void {
    // CONSENT GATE: Block geolocation requests without consent
    if (!this.isConsentGranted()) {
      if (this.config.debug) {
        console.log('[ApiClient] Geolocation request blocked - consent not granted');
      }
      return;
    }

    if (typeof navigator === "undefined" || !navigator.geolocation) return;

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const locationData: LocationData = {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
        };
        await this.updateSessionLocation(sessionId, locationData);
      },
      (error) => {
        if (this.config.debug) {
          console.error("Error getting geolocation:", error);
        }
      },
    );
  }

  async updateSessionEmail(
    sessionId: string,
    newEmail: string,
    brandId: number,
  ): Promise<string | null> {

    try {
      const response = await fetch(
        `${this.config.api_url}/v2/tracking-session/${sessionId}/email_v2`,
        {
          method: "PUT",
          headers: this.getHeaders(),
          body: JSON.stringify({
            email: newEmail,
            brand_id: brandId,
          }),
        },
      );

      if (!response.ok) {
        throw new Error(`Failed to update session email: ${response.status}`);
      }

      this.writeCookie("session_email", newEmail, {
        expires: 365,
        domain: this.config.cookie_domain,
      });

      const data: TrackingSessionResponse = await response.json();
      const newSessionId = data?.data?.id;

      if (newSessionId && newSessionId !== sessionId) {
        this.writeCookie("session_id", newSessionId, {
          expires: 365,
          domain: this.config.cookie_domain,
        });
        return newSessionId;
      }

      return sessionId;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error updating session email:", error);
      }
      return null;
    }
  }

  async updateSessionLocation(sessionId: string, location: LocationData): Promise<boolean> {
    try {
      const response = await fetch(
        `${this.config.api_url}/v2/tracking-session/${sessionId}/location`,
        {
          method: "PUT",
          headers: this.getHeaders(),
          body: JSON.stringify(location),
        },
      );

      if (!response.ok) {
        throw new Error(`Failed to update session location: ${response.status}`);
      }

      if (this.config.debug) {
        console.log("Session location updated successfully");
      }

      return true;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error updating session location:", error);
      }
      return false;
    }
  }

  async updateProfile(data: UpdateProfileData, brandId: number): Promise<boolean> {
    // Use exact structure from original JS file
    const { name, phone, gender, business_domain, metadata, email, source, birthday, ...extra } =
      data;
    const identify_id = this.getCookie("identify_id");
    const user_id = data.user_id;
    const session_id = this.getCookie("session_id");

    if (user_id && session_id && identify_id !== user_id) {
      await this.identifyById({ session_id, user_id });
    }

    try {
      // Match exact payload structure from original JS
      const response = await fetch(`${this.config.api_url}/v1/customer-profiles/set`, {
        method: "PUT",
        headers: this.getHeaders(),
        body: JSON.stringify({
          email,
          name,
          phone,
          gender,
          business_domain,
          extra,
          birthday,
          metadata,
          brand_id: brandId,
          source,
          user_id,
          session_id,
        }),
      });

      if (!response.ok) {
        throw new Error(`Failed to update profile: ${response.status}`);
      }

      if (this.config.debug) {
        console.log("Customer profile updated successfully");
      }

      return true;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error updating customer profile:", error);
      }
      return false;
    }
  }

  async setMetadata(metadata: Record<string, any>, brand_id: number): Promise<boolean> {
    const session_id = this.getCookie("session_id");
    const user_id = this.getCookie("identify_id");

    if (!session_id && !user_id) {
      if (this.config.debug) {
        console.error("No session_id or user_id available for metadata update");
      }
      return false;
    }

    try {
      const response = await fetch(`${this.config.api_url}/v1/customer-profiles/set`, {
        method: "PUT",
        headers: this.getHeaders(),
        body: JSON.stringify({
          metadata,
          user_id,
          brand_id,
          session_id,
        }),
      });

      if (!response.ok) {
        throw new Error(`Failed to update metadata: ${response.status}`);
      }

      if (this.config.debug) {
        console.log("Metadata updated successfully");
      }

      return true;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error updating metadata:", error);
      }
      return false;
    }
  }

  async trackEvent(
    brandId: number,
    sessionId: string,
    eventName: string,
    eventData?: Record<string, any>,
  ): Promise<boolean> {
    try {
      // Get room_id from sessionStorage like original JS
      const room_id =
        typeof sessionStorage !== "undefined" ? sessionStorage.getItem("USER_JOIN_ROOM") : null;
      const url = typeof window !== "undefined" ? window.location.href : "";

      // Use exact payload structure from original JS
      const payload = {
        brand_id: brandId,
        session_id: sessionId,
        event_name: eventName,
        data: eventData,
        ...(eventName !== "VIEW_PAGE" ? { flow_context: { url, room_id } } : {}),
      };

      const response = await fetch(`${this.config.api_url}/v2/tracking-session-data`, {
        method: "POST",
        headers: this.getHeaders(),
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`Failed to track event: ${response.status}`);
      }

      if (this.config.debug) {
        console.log("Event tracked successfully:", eventName);
      }

      return true;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error tracking event:", error);
      }
      return false;
    }
  }

  getSessionId(): string | null {
    return this.getCookie("session_id");
  }

  setSessionId(sessionId: string): void {
    this.writeCookie("session_id", sessionId, {
      expires: 365,
      domain: this.config.cookie_domain,
    });
  }

  getSessionEmail(): string | null {
    return this.getCookie("session_email");
  }

  getBrandId(): number | null {
    const brandId = this.getCookie("brand_id");
    if (brandId) {
      return parseInt(brandId, 10);
    }
    const globalConfig = (window as any).FounderOSConfig;
    if (!globalConfig || !globalConfig.brandId) {
      return null;
    }
    return parseInt(globalConfig.brandId, 10);
  }

  setBrandId(brandId: number): void {
    this.writeCookie("brand_id", brandId.toString(), {
      expires: 365,
      domain: this.config.cookie_domain,
    });
  }

  async identifyById({
    session_id,
    user_id,
  }: {
    session_id: string;
    user_id: string;
  }): Promise<string | null> {
    try {
      const response = await fetch(
        `${this.config.api_url}/v2/tracking-session/${session_id}/identify/${user_id}`,
        {
          method: "PUT",
          headers: this.getHeaders(),
        },
      );

      if (!response.ok) {
        throw new Error(`Failed to identify user: ${response.status}`);
      }

      this.writeCookie("identify_id", user_id, { expires: 365, domain: this.config.cookie_domain });

      const data: TrackingSessionResponse = await response.json();
      const newSessionId = data?.data?.id;

      if (newSessionId && newSessionId !== session_id) {
        this.writeCookie("session_id", newSessionId, {
          expires: 365,
          domain: this.config.cookie_domain,
        });
        return newSessionId;
      }

      return session_id;
    } catch (error) {
      if (this.config.debug) {
        console.error("Error identify user:", error);
      }
      return null;
    }
  }

  async linkVisitorToSession(payload: LinkVisitorToSession): Promise<boolean> {
    try {
      const response = await fetch(`${this.config.api_url}/v2/tracking-session/link-session`, {
        method: "POST",
        headers: this.getHeaders(),
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        return false;
      }
      const data = await response.json();
      const sessionId = data?.data?.id;
      if (sessionId) {
        this.writeCookie("session_id", sessionId, {
          expires: 365,
          domain: this.config.cookie_domain,
        });
      }
      return true;
    } catch (error) {
      console.log("Error linking visitor to session:", error);
      return false;
    }
  }

  /**
   * Clears a cookie by the given name
   * @param name The name of the cookie to clear
   * @param domain Optional domain for the cookie
   */
  clearCookieByName(name: string, domain?: string): void {
    this.clearCookie(name, { domain: domain || this.config.cookie_domain });
  }
}
