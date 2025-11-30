import type { TrackerConfig } from "../types";

export const DEFAULT_CONFIG: TrackerConfig = {
  flow: false,
  cross_site_cookie: false,
  cross_subdomain_cookie: true,
  persistence: "cookie",
  persistence_name: "genie_tracker",
  cookie_domain: undefined,
  cookie_name: "genie_session",
  debug: false,
  track_links_timeout: 300,
  cookie_expiration: 365,
  upgrade: false,
  disable_persistence: false,
  disable_cookie: false,
  ip: true,
  property_blacklist: [],
  batch_requests: true,
  batch_size: 50,
  batch_flush_interval_ms: 5000,
  batch_request_timeout_ms: 30000,
  batch_autostart: true,
  api_url: import.meta.env.VITE_API_URL,
  x_api_key: undefined, // Optional API key
  // Widget defaults
  enable_widget: false,
  widget_auto_start: true, // Default to true when widget is enabled
};

export function mergeConfig(userConfig: Partial<TrackerConfig> = {}): TrackerConfig {
  return { ...DEFAULT_CONFIG, ...userConfig };
}

export function validateConfig(config: TrackerConfig): void {
  if (config.batch_size <= 0) {
    throw new Error("batch_size must be greater than 0");
  }

  if (config.batch_flush_interval_ms <= 0) {
    throw new Error("batch_flush_interval_ms must be greater than 0");
  }

  if (config.cookie_expiration <= 0) {
    throw new Error("cookie_expiration must be greater than 0");
  }

  if (config.batch_request_timeout_ms <= 0) {
    throw new Error("batch_request_timeout_ms must be greater than 0");
  }
  if (config.session_timeout !== undefined && config.session_timeout <= 0) {
    throw new Error("session_timeout must be greater than 0 when provided");
  }
}
