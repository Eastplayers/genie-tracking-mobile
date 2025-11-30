/*
 * Popup Settings API client
 * - Fetches brand-specific popup configuration
 * - Always fail-safe: logs warnings and returns a disabled configuration on error
 */

export type PopupTrigger = "exit-intent" | "beforeunload" | "both";

export interface PopupCTA {
  label: string;
  href: string;
  target?: string;
}

export interface PopupTheme {
  zIndex?: number;
  // Optional minimal theming hooks
  colors?: {
    overlayBg?: string;
    dialogBg?: string;
    title?: string;
    text?: string;
    primaryBtnBg?: string;
    primaryBtnText?: string;
    secondaryBtnBg?: string;
    secondaryBtnText?: string;
  };
  radius?: number;
  shadow?: string;
}

// Button payload supports both new camelCase and legacy snake_case properties
export interface ButtonPayload {
  text?: string;
  // New API fields
  color?: string;
  textColor?: string;
  // Legacy fields
  bg_color?: string;
  text_color?: string;
}

export interface SettingsResponse {
  enable: boolean;
  title?: string;
  content?: string;
  // Customizable button labels
  confirmText?: string;
  cancelText?: string;
  displayOncePerSession?: boolean;
  trigger?: PopupTrigger;
  delayMs?: number;
  cta?: PopupCTA | null;
  theme?: PopupTheme;
  // Optional telemetry callbacks (not provided by API, but supported if present)
  onShown?: () => void;
  onClose?: () => void;
  onLeave?: () => void;
  onCtaClick?: () => void;
}

const disabledDefaults: SettingsResponse = {
  enable: false,
  title: "Are you leaving?",
  content: "Wait! Check this before you go.",
  displayOncePerSession: true,
  trigger: "both",
  delayMs: 150,
  cta: null,
  theme: { zIndex: 2147483647 },
};

export async function getPopupSettings(
  apiBaseUrl: string,
  brandId: string,
): Promise<SettingsResponse> {
  // SSR-safe: if no window/document, still allow fetch; caller decides to show UI.
  try {
    const base = (apiBaseUrl || "").replace(/\/$/, "");
    const url = `${base}/v1/pop-up-settings/brands/${encodeURIComponent(brandId)}`;

    const res = await fetch(url, {
      method: "GET",
      credentials: "omit",
      headers: { "Content-Type": "application/json" },
    });

    if (!res.ok) {
      return disabledDefaults;
    }

    const json = (await res.json()) as Partial<SettingsResponse> &
      Partial<{
        data: {
          enabled?: boolean;
          title?: string;
          content?: string;
          displayOncePerSession?: boolean;
          trigger?: PopupTrigger;
          delayMs?: number;
          cta?: PopupCTA | null;
          theme?: PopupTheme;
          // Button payload may include text and optional colors (new + legacy)
          confirm_button_props?: ButtonPayload;
          cancel_button_props?: ButtonPayload;
        };
        enabled?: boolean;
        confirm_button_props?: ButtonPayload;
        cancel_button_props?: ButtonPayload;
      }>;

    // Support APIs that wrap settings under `data` and use `enabled` naming
    const data = (json as any)?.data ?? json;

    // Basic shape validation and defaulting
    // Extract button props (support both root-level and data-level)
    const confirmProps = (data as any)?.confirm_button_props ?? (json as any)?.confirm_button_props;
    const cancelProps = (data as any)?.cancel_button_props ?? (json as any)?.cancel_button_props;

    // Normalize button props to a consistent shape
    const normalizeButtonProps = (btn?: ButtonPayload | null) => {
      const text = btn?.text;
      const bg = btn?.color ?? btn?.bg_color;
      const fg = btn?.textColor ?? btn?.text_color;
      return { text, bg, fg };
    };

    const normConfirm = normalizeButtonProps(confirmProps);
    const normCancel = normalizeButtonProps(cancelProps);

    const settings: SettingsResponse = {
      enable: !!(data.enabled ?? (data as any).enable),
      title: data.title || disabledDefaults.title,
      content: data.content || disabledDefaults.content,
      confirmText: normConfirm.text,
      cancelText: normCancel.text,
      displayOncePerSession:
        data.displayOncePerSession !== undefined
          ? !!data.displayOncePerSession
          : disabledDefaults.displayOncePerSession,
      trigger: (data.trigger as PopupTrigger) || disabledDefaults.trigger,
      delayMs: typeof data.delayMs === "number" ? data.delayMs : disabledDefaults.delayMs,
      cta: data.cta || null,
      theme: (() => {
        const base = { ...(data.theme || {}) };
        const colors = {
          ...(base.colors || {}),
          primaryBtnBg: normConfirm.bg ?? base.colors?.primaryBtnBg,
          primaryBtnText: normConfirm.fg ?? base.colors?.primaryBtnText,
          secondaryBtnBg: normCancel.bg ?? base.colors?.secondaryBtnBg,
          secondaryBtnText: normCancel.fg ?? base.colors?.secondaryBtnText,
        };
        return { ...base, colors, zIndex: base.zIndex ?? 2147483647 } as PopupTheme;
      })(),
      onShown: (data as any).onShown,
      onClose: (data as any).onClose,
      onLeave: (data as any).onLeave,
      onCtaClick: (data as any).onCtaClick,
    };

    return settings;
  } catch (err) {
    return disabledDefaults;
  }
}
