// services/Colours.qml
// M3 color system singleton. Loads palette from ~/.local/share/theme/palette.json
// and exposes raw (palette) and transparency-aware (tPalette) color tokens.
//
// Supports two palette schemas:
//   v2: M3-native keys (m3primary, m3surface, term0-15, etc.)
//   v1: Generic keys (bg, fg, primary, color0-15, etc.) — auto-normalized to v2
//       with container/onX tokens derived via color blending.
//
// API:
//   Colours.tPalette.m3X         — default access, base alpha applied to surface tokens
//   Colours.palette.m3X          — raw palette (use for derived colors)
//   Colours.term[N]              — terminal colors (0-15)
//   Colours.layer(color, level)  — manual depth darkening (4% per level, 2% floor)
//   Colours.palette.m3scrim      — raw scrim, bypasses tPalette
pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import "../config" as Conf

QtObject {
    id: root

    Component.onCompleted: {
        Conf.Config.ensureInitialized();
        _reloadPalette();
    }

    // --- Palette file ---
    // Reads from ~/.local/share/theme/palette.json
    // watchChanges may lose its inotify watcher after atomic renames (tmp+mv),
    // so _reloadPalette re-toggles it to re-attach to the new inode.
    property var _fileView: FileView {
        path: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/theme/palette.json"
        watchChanges: true
        blockLoading: true
        printErrors: false

        onFileChanged: root._reloadPalette()
    }

    // Parsed JSON data. Rebuilt on each reload.
    property var _data: ({})

    // Schema version derived from parsed data.
    // Version 2 = M3 format. 0 = file missing or version 1.
    readonly property int _schemaVersion: _data.version ?? 0
    readonly property bool _isV2: _schemaVersion >= 2

    function _reloadPalette() {
        // Force FileView to fully re-open the file by cycling the path.
        // Atomic renames replace the inode, so the old fd is stale.
        let p = _fileView.path;
        _fileView.path = "";
        _fileView.path = p;

        let content = "";
        try {
            content = _fileView.text();
        } catch (e) {
            console.warn("Colours: failed to read palette.json:", e);
            _data = {};
            return;
        }
        if (!content || content.length === 0) {
            _data = {};
            return;
        }
        try {
            let parsed = JSON.parse(content);
            // Detect v1 schema (has schema_version key or generic keys without v2 version)
            if (parsed.schema_version || (parsed.bg && parsed.version !== 2)) {
                parsed = _normalizeV1(parsed);
            }
            _data = parsed;
        } catch (e) {
            console.warn("Colours: malformed palette.json, using defaults:", e);
            _data = {};
        }
    }

    // --- V1 schema normalization ---
    // Converts v1 palette keys (bg, fg, primary, color0-15, etc.) to v2 M3 format.
    // Derives container/onX tokens via color blending when not explicitly provided.
    function _normalizeV1(d) {
        function hexToRgb(hex) {
            return [parseInt(hex.slice(1,3),16)/255, parseInt(hex.slice(3,5),16)/255, parseInt(hex.slice(5,7),16)/255];
        }
        function rgbToHex(rgb) {
            return "#" + rgb.map(function(c) {
                return Math.round(Math.min(1, Math.max(0, c)) * 255).toString(16).padStart(2, '0');
            }).join('');
        }
        function blend(hex1, hex2, t) {
            const a = hexToRgb(hex1), b = hexToRgb(hex2);
            return rgbToHex(a.map(function(v, i) { return v + (b[i] - v) * t; }));
        }
        function lum(hex) {
            const rgb = hexToRgb(hex);
            return 0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2];
        }

        // Source tokens from v1 keys
        const bg        = d.bg       || d.base    || "#141218";
        const fg        = d.fg       || d.text    || "#E6E1E5";
        const primary   = d.primary  || d.accent  || "#D0BCFF";
        const secondary = d.secondary             || "#CCC2DC";
        const tertiary  = d.warning  || d.info    || "#EFB8C8";
        const error     = d.critical              || "#F2B8B5";
        const success   = d.success               || "#A8DAB5";
        const muted     = d.muted    || d.overlay || "#938F99";

        // Derivation: "on" = high-contrast foreground for the given base
        function onColor(base) {
            return lum(base) > 0.4 ? blend(base, "#000000", 0.8) : blend(base, "#ffffff", 0.85);
        }
        // Container = base blended 65% toward bg (subdued fill)
        function container(base) { return blend(base, bg, 0.65); }
        // onContainer = base blended 30% toward fg (readable on container)
        function onContainer(base) { return blend(base, fg, 0.3); }

        const r = { version: 2 };

        r.m3primary            = primary;
        r.m3onPrimary          = onColor(primary);
        r.m3primaryContainer   = container(primary);
        r.m3onPrimaryContainer = onContainer(primary);

        r.m3secondary            = secondary;
        r.m3onSecondary          = onColor(secondary);
        r.m3secondaryContainer   = container(secondary);
        r.m3onSecondaryContainer = onContainer(secondary);

        r.m3tertiary            = tertiary;
        r.m3onTertiary          = onColor(tertiary);
        r.m3tertiaryContainer   = container(tertiary);
        r.m3onTertiaryContainer = onContainer(tertiary);

        r.m3error            = error;
        r.m3onError          = onColor(error);
        r.m3errorContainer   = container(error);
        r.m3onErrorContainer = onContainer(error);

        r.m3success            = success;
        r.m3onSuccess          = onColor(success);
        r.m3successContainer   = container(success);
        r.m3onSuccessContainer = onContainer(success);

        r.m3surface          = bg;
        r.m3onSurface        = fg;
        r.m3onSurfaceVariant = blend(fg, muted, 0.35);

        r.m3outline        = muted;
        r.m3outlineVariant = blend(muted, bg, 0.5);
        r.m3scrim          = "#000000";
        r.m3shadow         = "#000000";

        for (let i = 0; i < 16; i++) {
            r["term" + i] = d["color" + i] || "#000000";
        }

        return r;
    }

    // --- Color utility helpers ---

    // Decompose a color into {h, s, l, a} components using QML color properties.
    // Qt returns hslHue = -1 for achromatic colors; clamp to 0.
    function _colorToHsla(c) {
        const h = c.hslHue;
        return { h: h < 0 ? 0 : h, s: c.hslSaturation, l: c.lightness, a: c.a };
    }

    // Return color with luminance replaced.
    function _setLuminance(c, newL) {
        // Adjust lightness in RGB space to avoid Qt.hsla quirks with achromatic colors.
        const curL = _getLuminance(c);
        if (curL <= 0) return Qt.rgba(newL, newL, newL, c.a); // black → gray
        const scale = newL / curL;
        return Qt.rgba(
            Math.max(0, Math.min(1, c.r * scale)),
            Math.max(0, Math.min(1, c.g * scale)),
            Math.max(0, Math.min(1, c.b * scale)),
            c.a);
    }

    function _getLuminance(c) {
        // HSL lightness = (max + min) / 2
        const mx = Math.max(c.r, c.g, c.b);
        const mn = Math.min(c.r, c.g, c.b);
        return (mx + mn) / 2;
    }

    // --- Raw palette token reader ---
    // Returns Qt.color(val) if v2 and key present, else fallback.
    // Version 1 files ignore coincidental M3-named keys.
    function _tok(name, fallback) {
        if (!_isV2) return Qt.color(fallback);
        const val = _data[name];
        if (val && typeof val === "string" && val.length > 0) return Qt.color(val);
        return Qt.color(fallback);
    }

    // --- Wallpaper luminance adaptation ---
    // Read from palette.json (computed by thememanager). Default 0.3 if absent.
    readonly property real wallpaperLuminance: {
        const v = _data.wallpaperLuminance;
        return (typeof v === "number" && v >= 0 && v <= 1) ? v : 0.3;
    }

    // Computes pre-alpha surface color that, after compositing at the minimum
    // gamut-safe alpha over a wallpaper of the given luminance, reproduces `c`.
    //   composited = α * altered + (1−α) * wallpaper
    //   altered    = (c_ch − (1−α) * wp) / α
    // α is the maximum of the user's transparency base and the per-channel minimum
    // needed to keep `altered` in [0, 1].  tPalette._surfaceAlpha must agree —
    // it mirrors this calculation from raw _data to avoid binding loops.
    function alterColour(c, a, layer, luminance) {
        const userAlpha = Conf.Appearance.transparency.enabled
            ? Conf.Appearance.transparency.base : 1.0;
        if (userAlpha >= 1.0) return Qt.rgba(c.r, c.g, c.b, a);

        const wp = luminance;
        let alphaMin = userAlpha;
        const ch = [c.r, c.g, c.b];
        for (let i = 0; i < 3; i++) {
            if (ch[i] > wp && wp < 1.0)
                alphaMin = Math.max(alphaMin, (ch[i] - wp) / (1.0 - wp));
            else if (ch[i] < wp && wp > 0.0)
                alphaMin = Math.max(alphaMin, 1.0 - ch[i] / wp);
        }
        const alpha = Math.min(1.0, alphaMin);

        const inv = (1.0 - alpha) * wp;
        return Qt.rgba(
            Math.max(0, Math.min(1, (c.r - inv) / alpha)),
            Math.max(0, Math.min(1, (c.g - inv) / alpha)),
            Math.max(0, Math.min(1, (c.b - inv) / alpha)),
            a);
    }

    // --- Surface container derivation ---
    // All-or-nothing: if any level-qualified key exists, all 5 must be present.
    // Providing only m3surfaceContainer (no level-qualified) = custom derivation base.
    readonly property bool _hasLevelQualified: {
        if (!_isV2) return false;
        const d = _data;
        return !!(d.m3surfaceContainerLowest || d.m3surfaceContainerLow
                || d.m3surfaceContainerHigh || d.m3surfaceContainerHighest);
    }

    // Derive a surface container with the given luminance offset, or read from explicit key.
    // If _hasLevelQualified, explicit key is required; warns and falls back to derivation if missing.
    // Direction is theme-aware: dark themes step lighter (+), light themes step darker (−).
    function _deriveSurface(offset, explicitKey, baseColor) {
        if (_hasLevelQualified && _isV2) {
            const explicit = _data[explicitKey];
            if (explicit && typeof explicit === "string" && explicit.length > 0) {
                return Qt.color(explicit);
            }
            console.warn("Colours: partial container override — " + explicitKey + " missing, deriving from base");
        }
        const baseLum = _getLuminance(baseColor);
        const direction = baseLum > 0.5 ? -1 : 1;
        return _setLuminance(baseColor, baseLum + direction * offset);
    }

    // --- M3 Palette (raw, no transparency) ---
    readonly property QtObject palette: QtObject {
        id: palObj

        // Primary
        readonly property color m3primary:              root._tok("m3primary", "#D0BCFF")
        readonly property color m3onPrimary:            root._tok("m3onPrimary", "#381E72")
        readonly property color m3primaryContainer:     root._tok("m3primaryContainer", "#4F378B")
        readonly property color m3onPrimaryContainer:   root._tok("m3onPrimaryContainer", "#EADDFF")

        // Secondary
        readonly property color m3secondary:            root._tok("m3secondary", "#CCC2DC")
        readonly property color m3onSecondary:          root._tok("m3onSecondary", "#332D41")
        readonly property color m3secondaryContainer:   root._tok("m3secondaryContainer", "#4A4458")
        readonly property color m3onSecondaryContainer: root._tok("m3onSecondaryContainer", "#E8DEF8")

        // Tertiary
        readonly property color m3tertiary:             root._tok("m3tertiary", "#EFB8C8")
        readonly property color m3onTertiary:           root._tok("m3onTertiary", "#492532")
        readonly property color m3tertiaryContainer:    root._tok("m3tertiaryContainer", "#633B48")
        readonly property color m3onTertiaryContainer:  root._tok("m3onTertiaryContainer", "#FFD8E4")

        // Error
        readonly property color m3error:                root._tok("m3error", "#F2B8B5")
        readonly property color m3onError:              root._tok("m3onError", "#601410")
        readonly property color m3errorContainer:       root._tok("m3errorContainer", "#8C1D18")
        readonly property color m3onErrorContainer:     root._tok("m3onErrorContainer", "#F9DEDC")

        // Success (M3 extension)
        readonly property color m3success:              root._tok("m3success", "#A8DAB5")
        readonly property color m3onSuccess:            root._tok("m3onSuccess", "#0D3818")
        readonly property color m3successContainer:     root._tok("m3successContainer", "#1B5E2E")
        readonly property color m3onSuccessContainer:   root._tok("m3onSuccessContainer", "#C8EED0")

        // Surface — raw palette bg, no adaptation. Transparency compensation
        // is handled by tPalette._surfaceAlpha.
        readonly property color m3surface:              root._tok("m3surface", "#141218")
        readonly property color m3onSurface:            root._tok("m3onSurface", "#E6E1E5")
        readonly property color m3onSurfaceVariant:     root._tok("m3onSurfaceVariant", "#CAC4D0")

        // Surface containers — derived from m3surface unless explicit overrides provided.
        // 2%/4%/6%/8%/10% luminance steps: lighter for dark themes, darker for light.
        readonly property color m3surfaceContainerLowest:  root._deriveSurface(0.02, "m3surfaceContainerLowest", m3surface)
        readonly property color m3surfaceContainerLow:     root._deriveSurface(0.04, "m3surfaceContainerLow", m3surface)
        readonly property color m3surfaceContainer: {
            // m3surfaceContainer alone (without level-qualified siblings) = custom derivation base.
            if (root._hasLevelQualified && root._isV2) {
                const explicit = root._data.m3surfaceContainer;
                if (explicit && typeof explicit === "string" && explicit.length > 0) return Qt.color(explicit);
                console.warn("Colours: partial container override — m3surfaceContainer missing, deriving");
            } else if (root._isV2) {
                const explicit = root._data.m3surfaceContainer;
                if (explicit && typeof explicit === "string" && explicit.length > 0) return Qt.color(explicit);
            }
            return root._deriveSurface(0.06, "m3surfaceContainer", m3surface);
        }
        readonly property color m3surfaceContainerHigh:    root._deriveSurface(0.08, "m3surfaceContainerHigh", m3surface)
        readonly property color m3surfaceContainerHighest: root._deriveSurface(0.10, "m3surfaceContainerHighest", m3surface)

        // Utility
        readonly property color m3outline:              root._tok("m3outline", "#938F99")
        readonly property color m3outlineVariant:       root._tok("m3outlineVariant", "#49454F")
        // Scrim: raw, bypasses tPalette. Used directly by the Scrim component.
        readonly property color m3scrim:                root._tok("m3scrim", "#000000")
        readonly property color m3shadow:               root._tok("m3shadow", "#000000")
    }

    // --- M3 Transparency Palette ---
    // Applies base alpha to surface/container tokens. Text (onX) tokens pass through.
    // Use tPalette for all component backgrounds; use palette for derived/computed colors.
    readonly property QtObject tPalette: QtObject {
        // Alpha = transparency.base when enabled, else 1.0 (fully opaque).
        readonly property real _alpha: Conf.Appearance.transparency.enabled
            ? Conf.Appearance.transparency.base
            : 1.0

        // Boost surface alpha only when the surface is lighter than the wallpaper
        // (light-on-dark), so transparency doesn't wash out the light bg.
        // Dark-on-dark keeps the user's configured alpha for glassy effect.
        readonly property real _surfaceAlpha: {
            if (_alpha >= 1.0) return _alpha;
            const hex = root._data.m3surface;
            if (!hex || typeof hex !== "string" || hex.length < 7) return _alpha;
            const ch = [parseInt(hex.slice(1,3),16)/255,
                        parseInt(hex.slice(3,5),16)/255,
                        parseInt(hex.slice(5,7),16)/255];
            const sLum = (Math.max(ch[0],ch[1],ch[2]) + Math.min(ch[0],ch[1],ch[2])) / 2;
            const wp = root.wallpaperLuminance;
            // Dark surface over similar/lighter wallpaper — legibility boost.
            if (sLum <= wp) return _alpha + (1.0 - _alpha) * 0.6;
            // Per-channel minimum so composited result preserves the light surface.
            let needed = _alpha;
            for (let i = 0; i < 3; i++) {
                if (ch[i] > wp && wp < 1.0)
                    needed = Math.max(needed, (ch[i] - wp) / (1.0 - wp));
            }
            // Pad toward 95% opaque for solidity.
            needed += (1.0 - needed) * 0.75;
            return Math.min(1.0, needed);
        }

        // Primary — alpha applied to fill, not text
        readonly property color m3primary:              Qt.alpha(root.palette.m3primary, _alpha)
        readonly property color m3onPrimary:            root.palette.m3onPrimary
        readonly property color m3primaryContainer:     Qt.alpha(root.palette.m3primaryContainer, _alpha)
        readonly property color m3onPrimaryContainer:   root.palette.m3onPrimaryContainer

        // Secondary
        readonly property color m3secondary:            Qt.alpha(root.palette.m3secondary, _alpha)
        readonly property color m3onSecondary:          root.palette.m3onSecondary
        readonly property color m3secondaryContainer:   Qt.alpha(root.palette.m3secondaryContainer, _alpha)
        readonly property color m3onSecondaryContainer: root.palette.m3onSecondaryContainer

        // Tertiary
        readonly property color m3tertiary:             Qt.alpha(root.palette.m3tertiary, _alpha)
        readonly property color m3onTertiary:           root.palette.m3onTertiary
        readonly property color m3tertiaryContainer:    Qt.alpha(root.palette.m3tertiaryContainer, _alpha)
        readonly property color m3onTertiaryContainer:  root.palette.m3onTertiaryContainer

        // Error
        readonly property color m3error:                Qt.alpha(root.palette.m3error, _alpha)
        readonly property color m3onError:              root.palette.m3onError
        readonly property color m3errorContainer:       Qt.alpha(root.palette.m3errorContainer, _alpha)
        readonly property color m3onErrorContainer:     root.palette.m3onErrorContainer

        // Success
        readonly property color m3success:              Qt.alpha(root.palette.m3success, _alpha)
        readonly property color m3onSuccess:            root.palette.m3onSuccess
        readonly property color m3successContainer:     Qt.alpha(root.palette.m3successContainer, _alpha)
        readonly property color m3onSuccessContainer:   root.palette.m3onSuccessContainer

        // Surface — uses adaptive alpha to preserve luminance over wallpaper
        readonly property color m3surface:              Qt.rgba(root.palette.m3surface.r, root.palette.m3surface.g, root.palette.m3surface.b, _surfaceAlpha)
        readonly property color m3onSurface:            root.palette.m3onSurface
        readonly property color m3onSurfaceVariant:     root.palette.m3onSurfaceVariant

        // Surface containers — same adaptive alpha
        // Uses Qt.rgba instead of Qt.alpha to avoid Qt.hsla achromatic quirks.
        function _sa(c) { return Qt.rgba(c.r, c.g, c.b, _surfaceAlpha); }
        readonly property color m3surfaceContainerLowest:  _sa(root.palette.m3surfaceContainerLowest)
        readonly property color m3surfaceContainerLow:     _sa(root.palette.m3surfaceContainerLow)
        readonly property color m3surfaceContainer:        _sa(root.palette.m3surfaceContainer)
        readonly property color m3surfaceContainerHigh:    _sa(root.palette.m3surfaceContainerHigh)
        readonly property color m3surfaceContainerHighest: _sa(root.palette.m3surfaceContainerHighest)

        // Utility — not alpha-modified (structural lines, not fills)
        readonly property color m3outline:              root.palette.m3outline
        readonly property color m3outlineVariant:       root.palette.m3outlineVariant
    }

    // --- Terminal colors ---
    // JS array, rebuilt on each palette reload. 16 entries (term0-term15).
    // Falls back to black for missing entries.
    property var term: {
        // Depend on _data and _isV2 so this re-evaluates on reload.
        const d = _data;
        const arr = [];
        for (let i = 0; i < 16; i++) {
            const key = "term" + i;
            const val = d[key];
            arr.push((val && typeof val === "string" && val.length > 0)
                ? Qt.color(val)
                : Qt.color("#000000"));
        }
        return arr;
    }

    // --- Manual depth layer ---
    // Darkens a color's luminance by 4% per level (floor: 2%).
    // When transparency is enabled, also applies base alpha.
    // Intended for manual surface elevation, e.g. overlaid drawers.
    function layer(color, level) {
        const darken = 0.04 * level;
        const currentLum = _getLuminance(color);
        const newLum = Math.max(currentLum - darken, 0.02);
        const darkened = _setLuminance(color, newLum);
        if (Conf.Appearance.transparency.enabled) {
            return Qt.alpha(darkened, Conf.Appearance.transparency.base);
        }
        return darkened;
    }
}
