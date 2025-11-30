/**
 * Auto-initialization utilities for FounderOS
 * Reads configuration from script tag data attributes
 */

import { FounderOS } from "../core/tracker";
import type { TrackerConfig } from "../types";
import { parseCrossDomainSessionId } from "./cross-domain";

/**
 * Get current script tag (the one loading this tracker)
 */
function getCurrentScript(): HTMLScriptElement | null {
  if (typeof document === "undefined") return null;

  // Try document.currentScript first (modern browsers)
  if (document.currentScript instanceof HTMLScriptElement) {
    return document.currentScript;
  }

  // Fallback: find script with data-brand-id attribute (most reliable)
  const scripts = document.getElementsByTagName("script");
  for (let i = scripts.length - 1; i >= 0; i--) {
    const script = scripts[i];
    if (script.dataset && script.dataset.brandId) {
      return script;
    }
  }

  // Last fallback: find script by src pattern
  for (let i = scripts.length - 1; i >= 0; i--) {
    const script = scripts[i];
    if (script.src && script.src.includes("tracker")) {
      return script;
    }
  }

  return null;
}

/**
 * Parse configuration from script tag data attributes
 */
function parseScriptConfig(script: HTMLScriptElement): {
  brandId?: string;
  config: Partial<TrackerConfig>;
} {
  const dataset = script.dataset;

  const brandId = dataset.brandId;

  const config: Partial<TrackerConfig> = {};

  // Parse string values
  if (dataset.apiKey) config.x_api_key = dataset.apiKey;
  if (dataset.apiUrl) config.api_url = dataset.apiUrl;
  if (dataset.persistenceName) config.persistence_name = dataset.persistenceName;
  if (dataset.cookieName) config.cookie_name = dataset.cookieName;
  if (dataset.cookieDomain) config.cookie_domain = dataset.cookieDomain;

  // Parse environment and widget_url values
  if (dataset.environment) {
    config.environment = dataset.environment as any; // "local" | "development" | "qc" | "production"
    console.log("[FounderOS] Environment from script tag:", dataset.environment);
  }
  if (dataset.widgetUrl) {
    config.widget_url = dataset.widgetUrl;
    console.log("[FounderOS] Widget URL from script tag:", dataset.widgetUrl);
  }

  // Parse boolean values
  if (dataset.debug) config.debug = dataset.debug === "true";
  if (dataset.flow) config.flow = dataset.flow === "true";
  if (dataset.crossSiteCookie) config.cross_site_cookie = dataset.crossSiteCookie === "true";
  if (dataset.crossSubdomainCookie)
    config.cross_subdomain_cookie = dataset.crossSubdomainCookie === "true";
  if (dataset.batchRequests) config.batch_requests = dataset.batchRequests === "true";
  if (dataset.batchAutostart) config.batch_autostart = dataset.batchAutostart === "true";
  if (dataset.disablePersistence)
    config.disable_persistence = dataset.disablePersistence === "true";
  if (dataset.disableCookie) config.disable_cookie = dataset.disableCookie === "true";
  if (dataset.ip) config.ip = dataset.ip === "true";
  if (dataset.upgrade) config.upgrade = dataset.upgrade === "true";

  // Widget configuration
  if (dataset.enableWidget) config.enable_widget = dataset.enableWidget === "true";
  if (dataset.widgetAutoStart) config.widget_auto_start = dataset.widgetAutoStart === "true";

  // Parse numeric values
  if (dataset.batchSize) config.batch_size = parseInt(dataset.batchSize, 10);
  if (dataset.batchFlushIntervalMs)
    config.batch_flush_interval_ms = parseInt(dataset.batchFlushIntervalMs, 10);
  if (dataset.batchRequestTimeoutMs)
    config.batch_request_timeout_ms = parseInt(dataset.batchRequestTimeoutMs, 10);
  if (dataset.trackLinksTimeout)
    config.track_links_timeout = parseInt(dataset.trackLinksTimeout, 10);
  if (dataset.cookieExpiration) config.cookie_expiration = parseInt(dataset.cookieExpiration, 10);
  if (dataset.sessionTimeout) config.session_timeout = parseInt(dataset.sessionTimeout, 10);

  // Parse persistence type
  if (dataset.persistence) {
    const persistence = dataset.persistence;
    if (persistence === "cookie" || persistence === "localstorage" || persistence === "none") {
      config.persistence = persistence;
    }
  }

  // Parse array values (comma separated)
  if (dataset.propertyBlacklist) {
    config.property_blacklist = dataset.propertyBlacklist.split(",").map((s) => s.trim());
  }

  return { brandId, config };
}

/**
 * Auto-initialize tracker from script tag data attributes
 */
export async function autoInitFromScript(tracker: FounderOS): Promise<boolean> {
  if (typeof window === "undefined") return false;

  try {
    const script = getCurrentScript();
    
    if (!script) {
      console.warn("[FounderOS] Could not find current script tag for auto-init");
      return false;
    }

    // Check if auto-init is enabled
    const autoInit = script.dataset.autoInit;
    
    if (autoInit !== "true") {
      return false; // Auto-init not requested
    }

    const { brandId, config } = parseScriptConfig(script);

    if (!brandId) {
      console.error("[FounderOS] data-brand-id is required for auto-init");
      return false;
    }

    if (config.debug) {
      const urlSessionId = parseCrossDomainSessionId();

      console.log("[FounderOS] Auto-initializing from script tag (debug):", {
        brandId,
        config: {
          ...config,
          x_api_key: config.x_api_key ? "***" : undefined,
          environment: config.environment || "default",
          widget_url: config.widget_url || "auto-detected",
        },
        urlSessionId: urlSessionId || "none",
      });
    }

    await tracker.init(brandId, config);

    // Handle widget auto-start after initialization
    if (config.enable_widget && config.widget_auto_start) {
      if (config.debug) {
        console.log("[FounderOS] Widget auto-start enabled, starting widget...");
      }

      // Force remove any existing widget from DOM before starting
      if (typeof document !== "undefined") {
        const existingWidgets = document.querySelectorAll(
          "#genie-tracker-widget, [data-genie-widget], .genie-widget",
        );
        if (existingWidgets.length > 0) {
          existingWidgets.forEach((widget) => widget.remove());
          console.log("[FounderOS] Removed existing widgets before auto-start");
        }
      }

      try {
        await tracker.startWidget();
        if (config.debug) {
          console.log("[FounderOS] Widget auto-start completed successfully");
        }
      } catch (error) {
        if (config.debug) {
          console.error("[FounderOS] Widget auto-start failed:", error);
        }
      }
    }

    if (config.debug) {
      console.log("[FounderOS] Auto-initialization completed successfully");
    }

    return true;
  } catch (error) {
    console.error("[FounderOS] Auto-initialization failed:", error);
    return false;
  }
}

/**
 * Initialize tracker from global window config
 */
export async function initFromGlobalConfig(tracker: FounderOS): Promise<boolean> {
  if (typeof window === "undefined") return false;

  // Check for global config
  const globalConfig = (window as any).FounderOSConfig;
  if (!globalConfig || !globalConfig.brandId) {
    return false;
  }

  try {
    const { brandId, ...config } = globalConfig;

    if (config.debug) {
      console.log("[FounderOS] Initializing from global config:", {
        brandId,
        config: { ...config, x_api_key: config.x_api_key ? "***" : undefined },
      });
    }

    await tracker.init(brandId, config);
    return true;
  } catch (error) {
    console.error("[FounderOS] Global config initialization failed:", error);
    return false;
  }
}
