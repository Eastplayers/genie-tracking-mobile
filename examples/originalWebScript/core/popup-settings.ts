import { getPopupSettings, type SettingsResponse, type PopupTrigger } from "./api";

type InitParams = { apiBaseUrl: string; brandId: string };

// Track listeners per brand to ensure idempotency and enable cleanup
const brandListenerMap = new Map<string, () => void>();

// ---- Structured Logger ------------------------------------------------------
// Consistent, structured logs for filtering and analysis.
// Format: [ISO timestamp] [level] [component] message \n context
const COMPONENT = "PopupSettings";
type LogLevel = "debug" | "info" | "warn" | "error";

function errorPayload(err: unknown) {
  if (err instanceof Error) {
    return { message: err.message, stack: err.stack };
  }
  try {
    // Some environments throw non-Error values
    return { message: String(err) };
  } catch {
    return { message: "<unserializable error>" };
  }
}

const Logger = {
  log(level: LogLevel, msg: string, ctx?: unknown) {
    const ts = new Date().toISOString();
    const header = `[${ts}] [${level}] [${COMPONENT}] ${msg}`;
    try {
      // Print a human-readable header and a structured context object
      (console as any)[level]?.call(console, header, ctx ?? "");
    } catch {
      // Fallback to console.log to avoid throwing in restricted consoles
      console.log(header, ctx ?? "");
    }
  },
  debug(msg: string, ctx?: unknown) {
    Logger.log("debug", msg, ctx);
  },
  info(msg: string, ctx?: unknown) {
    Logger.log("info", msg, ctx);
  },
  warn(msg: string, ctx?: unknown) {
    Logger.log("warn", msg, ctx);
  },
  error(msg: string, ctx?: unknown) {
    Logger.log("error", msg, ctx);
  },
};

// ---- Session Helpers --------------------------------------------------------
function getSessionId(settings: any, brandId: string) {
  try {
    const sid = (settings as any)?.sessionId || `${brandId}:${location.pathname}`;
    return sid;
  } catch {
    return `${brandId}:unknown`;
  }
}
const interactedKey = (sid: string) => `esp-popup:interacted:${sid}`;

// Debounce helper (~200ms)
// function debounce<T extends (...args: any[]) => void>(fn: T, wait = 200) {
//   let timer: number | undefined;
//   return (...args: Parameters<T>) => {
//     if (typeof window === "undefined") return;
//     if (timer !== undefined) {
//       window.clearTimeout(timer);
//     }
//     timer = window.setTimeout(() => fn(...args), wait);
//   };
// }

// Remove <script> and inline event handlers (on*) from HTML string
export function sanitizeContent(input: string): string {
  Logger.debug("sanitizeContent:start", { hasInput: !!input });
  if (!input) {
    Logger.debug("sanitizeContent:emptyInput");
    return "";
  }
  try {
    if (typeof window !== "undefined" && typeof document !== "undefined") {
      const parser = new DOMParser();
      const doc = parser.parseFromString(input, "text/html");
      // Remove all <script> tags
      doc.querySelectorAll("script").forEach((el) => el.remove());
      // Remove inline event handlers
      doc.querySelectorAll("*").forEach((el) => {
        [...el.attributes].forEach((attr) => {
          if (/^on/i.test(attr.name)) {
            el.removeAttribute(attr.name);
          }
        });
      });
      const sanitized = doc.body.innerHTML;
      Logger.debug("sanitizeContent:done", { strategy: "DOMParser", length: sanitized.length });
      return sanitized;
    }
  } catch (err) {
    // Fallback to regex-based sanitization if DOMParser fails or not available
    Logger.warn("sanitizeContent:DOMParserFailed; using regex fallback", errorPayload(err));
  }

  // Basic regex-based sanitizer (limited)
  const sanitized = input
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/ on[a-z]+\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/gi, "");
  Logger.debug("sanitizeContent:done", { strategy: "regex", length: sanitized.length });
  return sanitized;
}

// Session guard: returns true the first time for a key, false thereafter
export function oncePerSession(key: string): boolean {
  try {
    if (typeof window === "undefined" || !(window as any).sessionStorage) return true;
    const k = `esp-popup:${key}`;
    const seen = sessionStorage.getItem(k) === "1";
    Logger.debug("oncePerSession:check", { key, seen });
    if (seen) return false;
    sessionStorage.setItem(k, "1");
    Logger.debug("oncePerSession:set", { key });
    return true;
  } catch (err) {
    // If sessionStorage is not available (CSP/SSR), allow once
    Logger.warn("oncePerSession:error; allowing once", errorPayload(err));
    return true;
  }
}

// External link detection
export function isExternalLink(href: string | null, locationObj: Location): boolean {
  if (!href) return false;
  try {
    const url = new URL(href, locationObj.href);
    const result = url.origin !== locationObj.origin;
    Logger.debug("isExternalLink:evaluated", { href, origin: locationObj.origin, result });
    return result;
  } catch (err) {
    Logger.warn("isExternalLink:URLParseFailed", { href, ...errorPayload(err) });
    return false;
  }
}

// Active beforeunload handler reference to manage listener lifecycle
let activeBeforeUnloadHandler: ((e: BeforeUnloadEvent) => void) | null = null;

function createOverlay(settings: SettingsResponse, pendingExternalHref?: string | null) {
  Logger.info("overlay:create", {
    title: settings.title,
    externalHref: pendingExternalHref ?? null,
  });
  if (typeof document === "undefined") return null;
  if (document.querySelector('[data-esp-popup="1"]')) {
    Logger.debug("overlay:create:duplicatePrevented");
    return null; // prevent duplicates
  }

  const themeZ = settings.theme?.zIndex ?? 2147483647;
  const overlay = document.createElement("div");
  overlay.setAttribute("data-esp-popup", "1");
  overlay.style.position = "fixed";
  overlay.style.inset = "0";
  overlay.style.background = settings.theme?.colors?.overlayBg || "rgba(0,0,0,0.48)";
  overlay.style.zIndex = String(themeZ);
  overlay.style.display = "flex";
  overlay.style.alignItems = "center";
  overlay.style.justifyContent = "center";
  // Ensure overlay and children accept pointer interactions
  overlay.style.pointerEvents = "auto";
  // Smooth fade transition
  overlay.style.opacity = "0";
  overlay.style.transition = "opacity 200ms ease";

  const dialog = document.createElement("div");
  dialog.setAttribute("role", "dialog");
  dialog.setAttribute("aria-modal", "true");
  dialog.tabIndex = -1; // focus target
  // Centered fixed dialog mimicking Radix-like layout
  dialog.style.position = "fixed";
  dialog.style.left = "50%";
  dialog.style.top = "50%";
  dialog.style.zIndex = String(themeZ);
  dialog.style.display = "grid";
  dialog.style.gap = "16px";
  dialog.style.width = "calc(100% - 32px)";
  dialog.style.maxWidth = "480px";
  dialog.style.background = settings.theme?.colors?.dialogBg || "#fff";
  dialog.style.borderRadius = `${settings.theme?.radius ?? 12}px`;
  dialog.style.boxShadow = settings.theme?.shadow || "0 10px 30px rgba(0,0,0,0.25)";
  dialog.style.border = (settings.theme as any)?.border || "1px solid #ddd";
  dialog.style.outline = "none";
  dialog.style.padding = "20px";
  dialog.style.fontFamily = "system-ui, -apple-system, Segoe UI, Roboto, Arial";
  dialog.style.pointerEvents = "auto";
  dialog.style.opacity = "0";
  dialog.style.transform = "translate(-50%, -50%) scale(0.95)";
  dialog.style.transition = "transform 200ms ease, opacity 200ms ease";

  const title = document.createElement("h2");
  title.textContent = settings.title || "Leave Page";
  title.style.margin = "0";
  title.style.color = settings.theme?.colors?.title || "#111";
  title.style.fontSize = "18px";
  title.style.fontWeight = "600";
  title.style.lineHeight = "1.3";
  try {
    const isMobile = /Mobi|Android/i.test(navigator.userAgent);
    title.style.textAlign = isMobile ? "center" : "left";
  } catch {}

  const content = document.createElement("div");
  const safeHtml = sanitizeContent(settings.content || "Are you sure you want to leave this page?");
  content.innerHTML = safeHtml;
  content.style.color = settings.theme?.colors?.text || "#333";
  content.style.margin = "0";
  content.style.fontSize = "14px";
  content.style.lineHeight = "1.5";
  try {
    const isMobile = /Mobi|Android/i.test(navigator.userAgent);
    content.style.textAlign = isMobile ? "center" : "left";
  } catch {}
  content.style.whiteSpace = "pre-line";

  const actions = document.createElement("div");
  actions.style.display = "flex";
  actions.style.gap = "8px";
  actions.style.marginTop = "0";
  actions.style.pointerEvents = "auto";
  try {
    const isMobile = /Mobi|Android/i.test(navigator.userAgent);
    actions.style.flexDirection = isMobile ? "column-reverse" : "row";
    actions.style.justifyContent = isMobile ? "flex-start" : "flex-end";
    actions.style.alignItems = isMobile ? "stretch" : "center";
  } catch {}

  const stayBtn = document.createElement("button");
  // Avoid accidental form submissions if page uses a root <form>
  stayBtn.type = "button";
  stayBtn.textContent = settings.cancelText || "Cancel";
  stayBtn.style.flex = "0";
  stayBtn.style.height = "40px";
  stayBtn.style.padding = "0 12px";
  stayBtn.style.borderRadius = `${settings.theme?.radius ?? 10}px`;
  stayBtn.style.border = "1px solid var(--stroke-1, #ddd)";
  stayBtn.style.background = settings.theme?.colors?.secondaryBtnBg || "#fff";
  stayBtn.style.color = settings.theme?.colors?.secondaryBtnText || "#111";
  stayBtn.style.pointerEvents = "auto";
  stayBtn.style.cursor = "pointer";
  // Ensure long labels truncate with ellipsis inside the button
  stayBtn.style.whiteSpace = "nowrap";
  stayBtn.style.overflow = "hidden";
  stayBtn.style.textOverflow = "ellipsis";
  stayBtn.style.minWidth = "max-content";

  const leaveBtn = document.createElement("button");
  // Avoid accidental form submissions if page uses a root <form>
  leaveBtn.type = "button";
  leaveBtn.textContent = settings.confirmText || "Leave page";
  leaveBtn.style.flex = "0";
  leaveBtn.style.height = "40px";
  leaveBtn.style.padding = "0 12px";
  leaveBtn.style.borderRadius = `${settings.theme?.radius ?? 10}px`;
  leaveBtn.style.border = "1px solid var(--stroke-3, transparent)";
  leaveBtn.style.background = settings.theme?.colors?.primaryBtnBg || "#000";
  leaveBtn.style.color = settings.theme?.colors?.primaryBtnText || "#fff";
  leaveBtn.style.pointerEvents = "auto";
  leaveBtn.style.cursor = "pointer";
  // Ensure long labels truncate with ellipsis inside the button
  leaveBtn.style.whiteSpace = "nowrap";
  leaveBtn.style.overflow = "hidden";
  leaveBtn.style.textOverflow = "ellipsis";
  leaveBtn.style.minWidth = "max-content";

  let ctaBtn: HTMLAnchorElement | null = null;
  if (settings.cta?.label && settings.cta?.href) {
    ctaBtn = document.createElement("a");
    ctaBtn.textContent = settings.cta.label;
    ctaBtn.href = settings.cta.href;
    if (settings.cta.target) ctaBtn.target = settings.cta.target;
    ctaBtn.style.flex = "0";
    ctaBtn.style.height = "40px";
    ctaBtn.style.padding = "0 12px";
    ctaBtn.style.borderRadius = `${settings.theme?.radius ?? 10}px`;
    ctaBtn.style.border = "1px solid var(--stroke-1, #ddd)";
    ctaBtn.style.background = settings.theme?.colors?.secondaryBtnBg || "#fff";
    ctaBtn.style.color = settings.theme?.colors?.secondaryBtnText || "#111";
    ctaBtn.style.textAlign = "center";
    ctaBtn.style.textDecoration = "none";
    // Ensure long labels truncate with ellipsis inside the button
    ctaBtn.style.whiteSpace = "nowrap";
    ctaBtn.style.overflow = "hidden";
    ctaBtn.style.textOverflow = "ellipsis";
    ctaBtn.style.minWidth = "max-content";
  }

  actions.appendChild(stayBtn);
  actions.appendChild(leaveBtn);
  if (ctaBtn) actions.appendChild(ctaBtn);

  dialog.appendChild(title);
  dialog.appendChild(content);
  dialog.appendChild(actions);

  overlay.appendChild(dialog);

  // Simple focus trap within the dialog
  const tabbables = () =>
    Array.from(
      dialog.querySelectorAll<HTMLElement>("a, button, [tabindex]:not([tabindex='-1'])"),
    ).filter((el) => !el.hasAttribute("disabled"));

  const onKeyDown = (e: KeyboardEvent) => {
    if (e.key === "Escape") {
      Logger.info("overlay:key:escape");
      e.preventDefault();
      cleanup();
      if (settings.onClose) settings.onClose();
    } else if (e.key === "Tab") {
      const t = tabbables();
      if (t.length === 0) return;
      const first = t[0];
      const last = t[t.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
  };

  function cleanup() {
    Logger.info("overlay:cleanup");
    document.removeEventListener("keydown", onKeyDown);
    // Animate out then remove for smooth hide
    try {
      overlay.style.opacity = "0";
      dialog.style.opacity = "0";
      dialog.style.transform = "translate(-50%, -50%) scale(0.95)";
      window.setTimeout(() => {
        overlay.remove();
      }, 200);
    } catch {
      overlay.remove();
    }
  }

  stayBtn.addEventListener("click", () => {
    Logger.info("interact:stay");
    try {
      if (typeof window !== "undefined" && (window as any).sessionStorage) {
        const sid = (settings as any).sessionId || getSessionId(settings as any, "");
        sessionStorage.setItem(interactedKey(sid), "1");
      }
    } catch (err) {
      Logger.warn("interact:stay:sessionMarkFailed", errorPayload(err));
    }
    cleanup();
    if (settings.onClose) settings.onClose();
  });

  leaveBtn.addEventListener("click", (e) => {
    Logger.info("interact:leave", { externalHref: pendingExternalHref ?? null });

    // Prevent any default behavior and propagation
    try {
      e?.preventDefault?.();
      e?.stopPropagation?.();
    } catch {}

    // Mark interaction for this session
    try {
      if (typeof window !== "undefined" && (window as any).sessionStorage) {
        const sid = (settings as any).sessionId || getSessionId(settings as any, "");
        sessionStorage.setItem(interactedKey(sid), "1");
      }
    } catch (err) {
      Logger.warn("interact:leave:sessionMarkFailed", errorPayload(err));
    }

    if (settings.onLeave) settings.onLeave();

    // Cancel any pending navigation without modifying browser history
    try {
      pendingExternalHref = null;
    } catch {}

    // Close the overlay and do not navigate
    cleanup();
  });

  if (ctaBtn) {
    ctaBtn.addEventListener("click", () => {
      Logger.info("overlay:action:ctaClick", { href: settings.cta?.href });
      if (settings.onCtaClick) settings.onCtaClick();
    });
  }

  document.addEventListener("keydown", onKeyDown);
  document.body.appendChild(overlay);
  // Animate in
  requestAnimationFrame(() => {
    overlay.style.opacity = "1";
    dialog.style.opacity = "1";
    dialog.style.transform = "translate(-50%, -50%) scale(1)";
  });
  dialog.focus();

  Logger.info("overlay:shown", {
    trigger: settings.trigger ?? undefined,
  });

  return { overlay, cleanup };
}

// Note: Modern browsers restrict custom UI in beforeunload; we only
// trigger our modal and avoid native prompts by not setting returnValue.

async function setupForBrand(brandId: string, settings: SettingsResponse) {
  if (typeof window === "undefined" || typeof document === "undefined") {
    Logger.warn("setupForBrand:noDOM", { brandId });
    return; // SSR/no DOM
  }

  const triggers = (settings.trigger || "both") as PopupTrigger;
  Logger.info("setupForBrand:start", { brandId, triggers });
  let pendingExternalHref: string | null = null;

  // Compute session and gating values
  const sessionId = getSessionId(settings as any, brandId);
  const topThreshold = (settings as any).exitIntentTopThreshold ?? 8;
  const useVis = (settings as any).useVisibilityHidden ?? true;
  const mobileMinScrollPct = (settings as any).mobileMinScrollPct ?? 25;
  const isMobile = /Mobi|Android/i.test(navigator.userAgent);
  let hasOpenedThisView = false;

  // Skip if already interacted in this session
  try {
    if (
      typeof window !== "undefined" &&
      (window as any).sessionStorage &&
      sessionStorage.getItem(interactedKey(sessionId)) === "1"
    ) {
      Logger.info("suppress:session", { brandId, sessionId });
      return;
    }
  } catch (err) {
    Logger.warn("suppress:session:checkFailed", { brandId, sessionId, ...errorPayload(err) });
  }

  const showOnce = (reason?: string) => {
    if (hasOpenedThisView) return;
    try {
      if (
        typeof window !== "undefined" &&
        (window as any).sessionStorage &&
        sessionStorage.getItem(interactedKey(sessionId)) === "1"
      ) {
        return;
      }
    } catch {}
    if (document.querySelector('[data-esp-popup="1"]')) return;
    const delay = (settings as any).delayMs ?? 0;
    Logger.info("popup:show", { brandId, reason, delay });
    window.setTimeout(() => {
      const res = createOverlay({ ...(settings as any), sessionId } as any, pendingExternalHref);
      pendingExternalHref = null;
      if (res) {
        hasOpenedThisView = true;
        if (settings.onShown) settings.onShown();
      }
    }, delay);
  };

  // Define beforeunload handler to exclusively show modal on page unload
  const beforeUnloadHandler = (e: BeforeUnloadEvent) => {
    Logger.info("beforeunload:fired");
    if ((settings as any).shouldBlockClose) {
      try {
        e.preventDefault();
        // Native prompt: only if explicitly enabled
        (e as any).returnValue = "";
      } catch (err) {
        Logger.warn("beforeunload:preventFailed", errorPayload(err));
      }
    } else {
      showOnce("beforeunload");
    }
  };
  activeBeforeUnloadHandler = beforeUnloadHandler;

  const addAll = () => {
    // Idempotency: if already added for this brand, skip
    if (brandListenerMap.has(brandId)) {
      Logger.debug("listeners:add:skip", { brandId });
      return;
    }

    // Attach beforeunload listener for page unload scenario (passive unless shouldBlockClose)
    window.addEventListener("beforeunload", beforeUnloadHandler, { capture: true });
    Logger.info("listeners:add:beforeunload", { brandId });

    // Show popup when mouse leaves the window near the top edge (exit intent)
    const onMouseOut = (e: MouseEvent) => {
      const to = (e.relatedTarget as Node | null) || null;
      if (!to && e.clientY <= topThreshold) {
        Logger.info("trigger:mouseout", { y: e.clientY });
        showOnce("mouseout");
      }
    };

    document.addEventListener("mouseout", onMouseOut, { capture: true });

    // Visibility change trigger with mobile scroll gating
    let mobileEligible = !isMobile;
    const onScroll = () => {
      try {
        const denom = document.documentElement.scrollHeight - window.innerHeight;
        const pct = denom > 0 ? (window.scrollY / denom) * 100 : 100;
        if (pct >= mobileMinScrollPct) {
          mobileEligible = true;
          window.removeEventListener("scroll", onScroll as any);
        }
      } catch (err) {
        Logger.warn("scroll:gatingFailed", errorPayload(err));
      }
    };
    if (isMobile) window.addEventListener("scroll", onScroll as any, { passive: true } as any);

    const onVis = () => {
      if (!useVis) return;
      if (document.visibilityState === "hidden" && mobileEligible) {
        Logger.info("trigger:visibilitychange");
        showOnce("visibilitychange");
      }
    };
    if (useVis) document.addEventListener("visibilitychange", onVis);

    // Store cleanup removing all listeners
    const removeAll = () => {
      // Remove all listeners added for this brand
      try {
        if (activeBeforeUnloadHandler) {
          window.removeEventListener("beforeunload", activeBeforeUnloadHandler, {
            capture: true,
          } as any);
        }
        document.removeEventListener("mouseout", onMouseOut, { capture: true } as any);
        if (useVis) document.removeEventListener("visibilitychange", onVis as any);
        if (isMobile) window.removeEventListener("scroll", onScroll as any);
        Logger.info("listeners:remove:complete", { brandId });
      } catch (err) {
        Logger.warn("listeners:remove:error", { brandId, ...errorPayload(err) });
      }
      brandListenerMap.delete(brandId);
    };

    brandListenerMap.set(brandId, removeAll);
    Logger.info("listeners:add:complete", { brandId });
  };

  addAll();
}

export default {
  async init({ apiBaseUrl, brandId }: InitParams): Promise<void> {
    try {
      // SSR-safe exit
      if (typeof brandId !== "string" || !brandId) {
        return;
      }
      const settings = await getPopupSettings(apiBaseUrl, brandId);
      if (!settings.enable) {
        return; // exit early if disabled
      }
      // Install triggers after we have settings
      await setupForBrand(brandId, settings);
    } catch (err) {
    }
  },
};
