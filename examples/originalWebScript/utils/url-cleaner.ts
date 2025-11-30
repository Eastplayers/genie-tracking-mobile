/**
 * URL Cleaner utility
 * Removes tracking parameters from the URL after they have been processed
 */

import { TRACKING_PARAM } from "./cross-domain";

/**
 * Removes the tracking parameter from the URL without page refresh
 * Call this function after processing the tracking parameter
 */
export function cleanTrackingParamFromUrl(): void {
  if (typeof window === "undefined" || !window.history || !window.location) return;

  try {
    // Only proceed if the tracking parameter is in the URL
    if (window.location.search.includes(TRACKING_PARAM)) {
      // Get current URL and create URL object
      const currentUrl = new URL(window.location.href);

      // Remove our tracking parameter from search params
      currentUrl.searchParams.delete(TRACKING_PARAM);

      // Generate the new URL string
      const newUrl =
        currentUrl.pathname +
        (currentUrl.searchParams.toString() ? "?" + currentUrl.searchParams.toString() : "") +
        (currentUrl.hash || "");

      // Use history.replaceState to update the URL without causing a page reload
      window.history.replaceState({}, document.title, newUrl);

      // Avoid ReferenceError in browsers: guard against undefined process
      const isDev = (typeof process !== "undefined" && process.env && process.env.NODE_ENV !== "production") ||
        (typeof import.meta !== "undefined" && import.meta.env && import.meta.env.MODE !== "production");

      console.log("[FounderOS] isDev: ", isDev);
      if (isDev) {
        console.log("[FounderOS] Removed tracking parameter from URL");
      }
    }
  } catch (error) {
    console.error("[FounderOS] Error cleaning URL:", error);
  }
}
