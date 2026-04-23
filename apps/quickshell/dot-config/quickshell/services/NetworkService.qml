pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Tri-state: "loading" | "available" | "unavailable"
    property string status: "loading"

    property string activeConnection: ""
    // "wifi" | "ethernet" | ""
    property string connectionType: ""
    // 0-100, only meaningful when connectionType === "wifi"
    property int signalStrength: 0

    readonly property int _normalPollInterval: 10000
    readonly property int _unavailablePollInterval: 60000

    // --- Internal ---

    // Connection info: NAME,TYPE,DEVICE
    property var _connProc: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show", "--active"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root._handleConnResult(this.text.trim())
        }
    }

    // Signal strength: SIGNAL,ACTIVE from wifi list
    property var _signalProc: Process {
        command: ["nmcli", "-t", "-f", "SIGNAL,ACTIVE", "device", "wifi", "list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root._handleSignalResult(this.text.trim())
        }
    }

    property var _timer: Timer {
        interval: root._normalPollInterval
        running: true
        repeat: true
        onTriggered: {
            root._connProc.running = true;
            if (root.connectionType === "wifi")
                root._signalProc.running = true;
        }
    }

    function _setStatusAndInterval(newStatus) {
        status = newStatus;
        _timer.interval = newStatus === "unavailable"
            ? _unavailablePollInterval
            : _normalPollInterval;
    }

    function _handleConnResult(text) {
        if (text === "") {
            activeConnection = "";
            connectionType = "";
            signalStrength = 0;
            if (status === "loading" || status === "available") {
                _setStatusAndInterval("unavailable");
            }
            return;
        }

        const firstLine = text.split("\n")[0];
        const parts = firstLine.split(":");
        const name = parts[0] || "";
        const type = parts[1] || "";

        activeConnection = name;
        if (type.indexOf("wireless") >= 0 || type.indexOf("wifi") >= 0) {
            connectionType = "wifi";
            _signalProc.running = true;
        } else if (type.indexOf("ethernet") >= 0) {
            connectionType = "ethernet";
            signalStrength = 100;
        } else {
            connectionType = "";
            signalStrength = 0;
        }

        _setStatusAndInterval("available");
    }

    function _handleSignalResult(text) {
        if (text === "") return;
        for (const line of text.split("\n")) {
            const parts = line.split(":");
            if (parts[1] === "yes") {
                signalStrength = parseInt(parts[0]) || 0;
                return;
            }
        }
    }

    Component.onCompleted: {
        _connProc.running = true;
    }
}
