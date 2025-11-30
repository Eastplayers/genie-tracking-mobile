import { ApiClient } from "./api";
import type { TrackerConfig } from "../types";

/**
 * Cross-domain tracking utilities
 * Helps maintain visitor identity across different domains
 */

export const TRACKING_PARAM = "gt_session_id"; // URL parameter name for visitor ID

/**
 * Get cross-domain tracking link
 * Appends the session ID to outgoing links to different domains
 *
 * @param url The target URL to modify
 * @param sessionId The current session ID to pass along
 * @returns Modified URL with tracking parameter
 */
export function getCrossDomainLink(url: string, sessionId: string): string {
  try {
    const targetUrl = new URL(url);
    targetUrl.searchParams.set(TRACKING_PARAM, sessionId);
    return targetUrl.toString();
  } catch (e) {
    // If URL parsing fails, append as string
    if (url.indexOf("?") !== -1) {
      return `${url}&${TRACKING_PARAM}=${encodeURIComponent(sessionId)}`;
    }
    return `${url}?${TRACKING_PARAM}=${encodeURIComponent(sessionId)}`;
  }
}

/**
 * Parse cross-domain session ID from URL
 * Called during initialization to see if this page load has a session ID passed
 *
 * @returns The session ID from URL or null if not found
 */
export function parseCrossDomainSessionId(): string | null {
  if (typeof window === "undefined" || !window.location) return null;

  try {
    const urlParams = new URLSearchParams(window.location.search);
    const sessionId = urlParams.get(TRACKING_PARAM);
    return sessionId;
  } catch (e) {
    return null;
  }
}

/**
 * Setup automatic link decoration for cross-domain tracking
 * Finds links to different domains and adds the session ID parameter
 *
 * @param config Tracker configuration
 * @param sessionId Current session ID
 * @param allowedDomains Optional list of domains to add parameters to (if omitted, adds to all external domains)
 */
export function setupLinkDecoration(
  config: TrackerConfig,
  sessionId: string,
  allowedDomains?: string[],
): void {
  if (typeof document === "undefined") return;

  // Only do this if cross-site cookie is enabled
  if (!config.cross_site_cookie) return;

  const currentHost = window.location.hostname;

  // Process existing links on page
  const processLinks = () => {
    const links = document.getElementsByTagName("a");

    for (let i = 0; i < links.length; i++) {
      const link = links[i];
      if (!link.href || !link.hostname || link.hostname === currentHost) continue;

      // If allowedDomains is specified, only decorate links to those domains
      if (allowedDomains && !allowedDomains.some((domain) => link.hostname.endsWith(domain))) {
        continue;
      }

      // Don't modify if already has our parameter
      if (link.href.includes(TRACKING_PARAM)) continue;

      link.href = getCrossDomainLink(link.href, sessionId);
    }
  };

  // Process links now and whenever DOM changes
  processLinks();

  // Set up a mutation observer to handle dynamically added links
  if (typeof MutationObserver !== "undefined") {
    const observer = new MutationObserver((mutations) => {
      let shouldProcess = false;

      // Check if any mutations involve adding nodes that might be or contain links
      for (const mutation of mutations) {
        if (mutation.type === "childList" && mutation.addedNodes.length) {
          shouldProcess = true;
          break;
        }
      }

      if (shouldProcess) {
        processLinks();
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });
  }
}

/**
 * Initialize cross-domain tracking
 * Called during tracker initialization
 *
 * @param apiClient API client instance
 * @param config Tracker configuration
 * @param domains Optional array of domains to enable cross-domain tracking for
 */
export async function initCrossDomainTracking(
  apiClient: ApiClient,
  config: TrackerConfig & { brand_id?: string },
  domains?: string[],
): Promise<void> {
  if (!config.cross_site_cookie) return;

  // Check for incoming session ID in URL
  const urlSessionId = parseCrossDomainSessionId();

  // Get the current device ID and session ID
  let deviceId = apiClient.getDeviceId();
  let sessionId = apiClient.getSessionId();
  if (!sessionId && urlSessionId) {
    apiClient.setSessionId(urlSessionId);
    sessionId = urlSessionId;
    console.log("Set session ID from URL param:", sessionId);
    // We'll clean the URL later once all processing is done
  }
  if (!deviceId && urlSessionId) {
    deviceId = await apiClient.writeDeviceId();
  }
  if (!deviceId || !sessionId) return;

  // If we have a session ID from URL parameter, use it for linking
  if (urlSessionId && urlSessionId !== sessionId) {
    try {
      // Make API call to link the session IDs in the backend
      // This is just a placeholder, actual implementation would depend on your API
      await apiClient.linkVisitorToSession({
        source_session_id: urlSessionId,
        current_session_id: sessionId,
        device_id: deviceId,
        brand_id: config?.brand_id ? parseInt(config?.brand_id) : undefined,
      });

      if (config.debug) {
        console.log("[FounderOS] Linked cross-domain session ID:", urlSessionId);
      }
    } catch (error) {
      if (config.debug) {
        console.error("[FounderOS] Error linking cross-domain session:", error);
      }
    }
  }

  // Setup automatic link decoration for outgoing links
  setupLinkDecoration(config, sessionId, domains);

  // Now that we've processed the URL parameter, clean it from the URL
  // We need to import this dynamically to avoid circular dependencies
  import("./url-cleaner").then((module) => {
    module.cleanTrackingParamFromUrl();
  });
}
