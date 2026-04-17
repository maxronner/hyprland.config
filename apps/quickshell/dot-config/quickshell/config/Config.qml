// config/Config.qml
// JSON-backed config singleton with dual pending/persisted state,
// FileView hot-reload, self-write detection, and migration support.
pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // --- Schema ---
    readonly property int currentVersion: 1

    // --- Dual state ---
    // pending: in-memory, immediate updates for live preview.
    // Appearance and Colours bind to pending properties.
    // Access triggers ensureInitialized() via lazy guard.
    property var pending: ({})

    // --- Internal ---
    property bool _initialized: false
    property string _lastWrittenHash: ""

    // --- File I/O ---
    // blockLoading: true makes the initial text() call synchronous.
    // watchChanges: true enables onFileChanged for hot-reload.
    property var _fileView: FileView {
        path: StandardPaths.writableLocation(StandardPaths.GenericConfigLocation) + "/quickshell/config.json"
        watchChanges: true
        blockLoading: true
        printErrors: false

        onFileChanged: {
            if (!root._initialized) return;
            if (root._writeGuard) return;
            const content = this.text();
            if (!content || content.length === 0) return;
            root._parseAndApply(content);
        }
    }

    // Suppresses file watcher reloads briefly after our own writes
    property bool _writeGuard: false
    property var _writeGuardTimer: Timer {
        interval: 200
        repeat: false
        onTriggered: root._writeGuard = false
    }

    // --- Lazy init guard ---
    // Called before any consumer reads pending. Safe to call multiple times.
    function ensureInitialized() {
        if (_initialized) return;
        _initialized = true;

        let content = "";
        try {
            content = _fileView.text();
        } catch (e) {
            console.warn("Config: failed to read config.json, using defaults:", e);
        }

        if (content && content.length > 0) {
            const parsed = _parseAndApply(content);
            // Use the already-parsed object returned by _parseAndApply — no second JSON.parse.
            const parsedVersion = (parsed && parsed.version) ? parsed.version : 0;
            if (parsedVersion > currentVersion) {
                console.warn("Config: config.json version", parsedVersion,
                    "is newer than supported (", currentVersion, "), falling back to defaults");
                pending = _defaults();
            } else if (parsedVersion < currentVersion) {
                _migrate(parsedVersion);
            }
        } else {
            console.log("Config: config.json not found or empty, using defaults");
            pending = _defaults();
        }
    }

    // --- Default config ---
    function _defaults() {
        return {
            version: currentVersion,
            appearance: {
                rounding: { scale: 1.0 },
                spacing: { scale: 1.0 },
                padding: { scale: 1.0 },
                font: { sizeScale: 1.0 },
                anim: { preset: "m3" },
                transparency: { enabled: false, base: 0.85 }
            },
            bar: {
                groupSeparators: false,
                persistent: true
            },
            dashboard: {},
            controlcenter: {},
            background: {
                enabled: true,
                wallpaperEnabled: true,
                inset: {
                    gap: null,
                    gapOuter: null,
                    gapInner: null,
                    radius: null
                },
                desktopClock: {
                    enabled: false,
                    position: "bottom-right",
                    scale: 1.0
                }
            },
            services: {}
        };
    }

    // --- Parse and merge ---
    // Returns the raw parsed object on success, or null on failure.
    function _parseAndApply(content) {
        try {
            const parsed = JSON.parse(content);
            pending = _merge(_defaults(), parsed);
            return parsed;
        } catch (e) {
            console.warn("Config: malformed config.json, using defaults:", e);
            pending = _defaults();
            return null;
        }
    }

    // Deep merge: defaults provides structure, overrides wins on leaf values.
    // Arrays are replaced wholesale (not merged).
    function _merge(defaults, overrides) {
        const result = Object.assign({}, defaults);
        for (const key of Object.keys(overrides)) {
            if (
                defaults[key] !== null &&
                typeof defaults[key] === "object" &&
                !Array.isArray(defaults[key]) &&
                typeof overrides[key] === "object" &&
                overrides[key] !== null &&
                !Array.isArray(overrides[key])
            ) {
                result[key] = _merge(defaults[key], overrides[key]);
            } else {
                result[key] = overrides[key];
            }
        }
        return result;
    }

    // --- Migration ---
    // Called from ensureInitialized() when persisted version < currentVersion.
    // Runs synchronously before any consumer reads.
    function _migrate(fromVersion) {
        console.log("Config: migrating from version", fromVersion, "to", currentVersion);
        // Future migrations go here.
        // Each case should transform pending to match the next schema version.
        // Example pattern:
        //   if (fromVersion < 2) { pending.newKey = defaultValue; }
        pending.version = currentVersion;
        pendingChanged();
        flush();
    }

    // --- Public API ---

    // set(path, value): update a nested key by dot-separated path.
    // Example: Config.set("appearance.rounding.scale", 1.5)
    // Triggers a debounced 500ms write. Use flush() for immediate write.
    function set(path, value) {
        ensureInitialized();
        const keys = path.split(".");
        // Clone each level along the path so QML sees new object references
        // and re-evaluates downstream bindings.
        let newRoot = Object.assign({}, pending);
        let obj = newRoot;
        for (let i = 0; i < keys.length - 1; i++) {
            if (typeof obj[keys[i]] !== "object" || obj[keys[i]] === null) {
                console.warn("Config: set(\"" + path + "\"): overwriting non-object value at key \"" + keys[i] + "\" with {}");
                obj[keys[i]] = {};
            } else {
                obj[keys[i]] = Object.assign({}, obj[keys[i]]);
            }
            obj = obj[keys[i]];
        }
        obj[keys[keys.length - 1]] = value;
        pending = newRoot;
        _writeToDisk();
    }

    // flush(): write immediately, bypassing the debounce timer.
    // Call this when the user closes the Appearance pane.
    function flush() {
        _saveTimer.stop();
        _writeToDisk();
    }

    function _writeToDisk() {
        ensureInitialized();
        _writeGuard = true;
        _writeGuardTimer.restart();
        const content = JSON.stringify(pending, null, 2);
        _fileView.setText(content);
    }

    // Trigger initialization at startup so the first binding read is already warm.
    Component.onCompleted: ensureInitialized()
}
