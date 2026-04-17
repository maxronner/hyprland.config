// services/ThumbnailService.qml
// XDG-compliant thumbnail cache for image files.
// Cache path: $XDG_CACHE_HOME/thumbnails/large/<md5(file-uri)>.png (256px tall).
// Generates on demand with a bounded worker pool; emits ready(srcPath) per file.
pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string _cacheDir: {
        let p = StandardPaths.writableLocation(StandardPaths.GenericCacheLocation).toString();
        if (p.startsWith("file://")) p = p.substring(7);
        return p + "/thumbnails/large";
    }

    readonly property int _thumbSize: 256
    readonly property int _concurrency: 4

    signal ready(string srcPath)

    function thumbPath(srcPath: string): string {
        if (!srcPath) return "";
        const hash = Qt.md5("file://" + srcPath);
        return _cacheDir + "/" + hash + ".png";
    }

    // Enqueue a path for cache-or-generate. Idempotent.
    function ensure(srcPath: string): void {
        if (!srcPath) return;
        if (_inFlight[srcPath]) return;
        if (_queued[srcPath]) return;
        _queued[srcPath] = true;
        _queue.push(srcPath);
        _pump();
    }

    property var _queue: []
    property var _queued: ({})
    property var _inFlight: ({})
    property var _workers: []

    Component.onCompleted: {
        for (let i = 0; i < _concurrency; i++) {
            _workers.push(_workerComponent.createObject(root));
        }
        _pump();
    }

    function _pump(): void {
        for (let i = 0; i < _workers.length; i++) {
            const w = _workers[i];
            if (w.running) continue;
            if (_queue.length === 0) return;
            const src = _queue.shift();
            delete _queued[src];
            _inFlight[src] = true;
            w._src = src;
            w._dst = thumbPath(src);
            w.running = true;
        }
    }

    property Component _workerComponent: Component {
        Process {
            property string _src: ""
            property string _dst: ""

            // Skip generation if cache exists and is newer than source.
            // Atomic via .tmp + mv so partial files never load.
            command: ["sh", "-c",
                "src=\"$1\"; dst=\"$2\"; size=\"$3\"; " +
                "if [ ! -e \"$dst\" ] || [ \"$src\" -nt \"$dst\" ]; then " +
                "  mkdir -p \"$(dirname \"$dst\")\" && " +
                "  magick \"$src\" -auto-orient -thumbnail \"x${size}\" \"${dst}.tmp.png\" && " +
                "  mv \"${dst}.tmp.png\" \"$dst\"; " +
                "fi",
                "_", _src, _dst, String(root._thumbSize)]

            running: false

            onExited: (exitCode, exitStatus) => {
                const src = _src;
                delete root._inFlight[src];
                root.ready(src);
                root._pump();
            }
        }
    }
}
