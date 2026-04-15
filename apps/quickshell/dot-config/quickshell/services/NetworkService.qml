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
        interval: {
            if (root.status === "unavailable") return 60000;
            return 10000;
        }
        running: true
        repeat: true
        onTriggered: {
            root._connProc.running = true;
            if (root.connectionType === "wifi")
                root._signalProc.running = true;
        }
    }

    function _handleConnResult(text) {
        if (text === "") {
            activeConnection = "";
            connectionType = "";
            signalStrength = 0;
            if (status === "loading" || status === "available") {
                status = "unavailable";
                _timer.interval = 60000;
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

        status = "available";
        _timer.interval = 10000;
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
