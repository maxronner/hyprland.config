pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

QtObject {
    id: root

    // Tri-state: "loading" | "available" | "unavailable"
    property string status: "loading"

    readonly property PwNode defaultOutput: Pipewire.defaultAudioSink
    readonly property PwNode defaultInput: Pipewire.defaultAudioSource

    property list<PwNode> sinkList: []
    property list<PwNode> sourceList: []

    // Convenience accessors on the default output
    readonly property real volume: defaultOutput?.audio?.volume ?? 0
    readonly property bool muted: !!defaultOutput?.audio?.muted

    // Convenience accessors on the default input
    readonly property real inputVolume: defaultInput?.audio?.volume ?? 0
    readonly property bool inputMuted: !!defaultInput?.audio?.muted

    // --- Public API ---

    function setVolume(newVolume) {
        if (defaultOutput?.ready && defaultOutput?.audio) {
            defaultOutput.audio.muted = false;
            defaultOutput.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }

    function incrementVolume(delta) {
        setVolume(volume + (delta ?? 0.02));
    }

    function decrementVolume(delta) {
        setVolume(volume - (delta ?? 0.02));
    }

    function toggleMute() {
        if (defaultOutput?.ready && defaultOutput?.audio)
            defaultOutput.audio.muted = !defaultOutput.audio.muted;
    }

    function setInputVolume(newVolume) {
        if (defaultInput?.ready && defaultInput?.audio) {
            defaultInput.audio.muted = false;
            defaultInput.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }

    function toggleInputMute() {
        if (defaultInput?.ready && defaultInput?.audio)
            defaultInput.audio.muted = !defaultInput.audio.muted;
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    // --- Internal ---

    function _checkAvailability() {
        if (Pipewire.defaultAudioSink !== null) {
            root.status = "available";
            _retryTimer.stop();
        } else if (root.status !== "unavailable") {
            root.status = "loading";
            _retryTimer.restart();
        }
    }

    function _enumerateNodes() {
        const newSinks = [];
        const newSources = [];
        for (const node of Pipewire.nodes.values) {
            if (node.isStream)
                continue;
            if (node.isSink)
                newSinks.push(node);
            else if (node.audio)
                newSources.push(node);
        }
        root.sinkList = newSinks;
        root.sourceList = newSources;
    }

    // 2-second retry timer: if still null after 2s → unavailable
    property var _retryTimer: Timer {
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            if (Pipewire.defaultAudioSink === null) {
                root.status = "unavailable";
            } else {
                root.status = "available";
                root._enumerateNodes();
            }
        }
    }

    // Watch for sink appearing / disappearing at runtime
    property var _sinkConnections: Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            if (Pipewire.defaultAudioSink === null) {
                root.status = "loading";
                root._retryTimer.restart();
            } else {
                root.status = "available";
                root._retryTimer.stop();
            }
        }
    }

    // Re-enumerate whenever the node list changes
    property var _nodeConnections: Connections {
        target: Pipewire.nodes
        function onValuesChanged() {
            root._enumerateNodes();
        }
    }

    // Bind all tracked nodes so volume/muted/etc. stay live
    property var _tracker: PwObjectTracker {
        objects: [...root.sinkList, ...root.sourceList,
                  ...(root.defaultOutput ? [root.defaultOutput] : []),
                  ...(root.defaultInput  ? [root.defaultInput]  : [])]
    }

    Component.onCompleted: {
        root._checkAvailability();
        if (root.status === "available")
            root._enumerateNodes();
    }
}
