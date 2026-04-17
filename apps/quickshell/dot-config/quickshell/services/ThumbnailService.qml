// services/ThumbnailService.qml
// XDG-compliant thumbnail cache for image files.
// Cache path: $XDG_CACHE_HOME/thumbnails/large/<md5(file-uri)>.png (256px tall).
// Sequential on-demand generation — delegates rely on `readyTick` changes to
// refresh their bound Image source.
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

    // Bumped after every worker exit. Consumers include this property in an
    // Image.source binding to force Qt to re-load from disk once the cache
    // file has been written. Cheap: cached reloads hit the Qt image cache.
    property int readyTick: 0

    function thumbPath(srcPath: string): string {
        if (!srcPath) return "";
        return _cacheDir + "/" + Qt.md5("file://" + srcPath) + ".png";
    }

    // Queue is a plain JS array of paths. `_current` is the path being
    // processed right now (empty when idle). Both are only mutated from
    // ensure/cancel/pump, which run on the main thread.
    property var _queue: []
    property string _current: ""

    function ensure(srcPath: string): void {
        if (!srcPath) return;
        if (srcPath === root._current) return;
        if (root._queue.indexOf(srcPath) !== -1) return;
        root._queue.push(srcPath);
        _pump();
    }

    function cancel(srcPath: string): void {
        if (!srcPath) return;
        const idx = root._queue.indexOf(srcPath);
        if (idx !== -1) root._queue.splice(idx, 1);
    }

    function _pump(): void {
        if (worker.running) return;
        if (root._queue.length === 0) return;
        const src = root._queue.shift();
        root._current = src;
        worker._src = src;
        worker._dst = thumbPath(src);
        worker.running = true;
    }

    // Single static worker. Skip generation if cache exists and is newer
    // than source. Atomic via .tmp + mv so partial files never load.
    property var worker: Process {
        id: worker

        property string _src: ""
        property string _dst: ""

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
            root._current = "";
            root.readyTick++;
            root._pump();
        }
    }
}
