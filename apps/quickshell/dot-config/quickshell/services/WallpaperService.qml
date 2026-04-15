// services/WallpaperService.qml
// Resolves ~/.local/share/wallpaper/current (a symlink) for the active wallpaper path.
// No polling — wallpaper changes are signaled via IPC (reload-wallpaper target)
// or the wallpaper set IPC.
pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string _stateDir: {
        let p = StandardPaths.writableLocation(StandardPaths.GenericDataLocation).toString();
        if (p.startsWith("file://")) p = p.substring(7);
        return p + "/wallpaper";
    }
    readonly property string _statePath: _stateDir + "/current"

    property string current: ""

    Component.onCompleted: _resolve()

    // Resolve symlink via readlink -f
    property var _resolveProc: Process {
        command: ["readlink", "-f", root._statePath]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let resolved = text.trim();
                if (resolved && resolved !== root.current) {
                    root.current = resolved;
                }
            }
        }
    }

    function _resolve() {
        _resolveProc.running = true;
    }

    // IPC: quickshell msg wallpaper get / set / reload
    property var _ipc: IpcHandler {
        target: "wallpaper"

        function get(): string { return root.current; }

        function set(path: string): void {
            root._writeAtomic(path);
        }

        function reload(): void {
            root._resolve();
        }
    }

    // Atomic symlink swap: ln -sf
    property var _writeProc: Process {
        id: writeProc
        property string _path: ""
        command: ["ln", "-sf", _path, root._statePath]
        running: false
        onExited: root._resolve()
    }

    function _writeAtomic(path) {
        writeProc._path = path;
        writeProc.running = true;
    }
}
