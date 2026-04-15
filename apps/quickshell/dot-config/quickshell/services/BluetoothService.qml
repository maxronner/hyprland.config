pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Tri-state: "loading" | "available" | "unavailable"
    property string status: "loading"

    property bool powered: false
    property string connectedDevice: ""
    property string connectedDeviceAddress: ""
    property int batteryPercent: -1  // -1 = unknown/unavailable

    // --- Internal ---

    property bool _poweredResult: false
    property string _deviceResult: ""
    property string _deviceAddress: ""
    property bool _poweredReady: false
    property bool _deviceReady: false

    function _checkReady() {
        if (!_poweredReady || !_deviceReady)
            return;
        _poweredReady = false;
        _deviceReady = false;

        if (!_poweredResult && _deviceResult === "" && status === "loading") {
            status = "unavailable";
            _sharedTimer.interval = 60000;
            return;
        }

        powered = _poweredResult;
        connectedDevice = _deviceResult;
        connectedDeviceAddress = _deviceAddress;
        status = "available";
        _sharedTimer.interval = 10000;

        // Fetch battery if we have a connected device
        if (_deviceAddress !== "") {
            _batteryProc.command = ["bluetoothctl", "info", _deviceAddress];
            _batteryProc.running = true;
        } else {
            batteryPercent = -1;
        }
    }

    // Process 1: check powered state
    property var _poweredProc: Process {
        command: ["bluetoothctl", "show"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root._poweredResult = this.text.indexOf("Powered: yes") >= 0;
                root._poweredReady = true;
                root._checkReady();
            }
        }
    }

    // Process 2: list connected devices — grab first device name + address
    property var _deviceProc: Process {
        command: ["bluetoothctl", "devices", "Connected"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim().split("\n")[0];
                // Format: "Device AA:BB:CC:DD:EE:FF <Name>"
                const match = line.match(/^Device\s+([\dA-Fa-f:]+)\s+(.+)$/);
                root._deviceAddress = match ? match[1] : "";
                root._deviceResult = match ? match[2].trim() : "";
                root._deviceReady = true;
                root._checkReady();
            }
        }
    }

    // Process 3: get battery percentage from connected device info
    property var _batteryProc: Process {
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const match = this.text.match(/Battery Percentage:\s*0x[\da-fA-F]+\s*\((\d+)\)/);
                root.batteryPercent = match ? parseInt(match[1]) : -1;
            }
        }
    }

    // Single shared timer — triggers both processes together
    property var _sharedTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            root._poweredProc.running = true;
            root._deviceProc.running = true;
        }
    }

    Component.onCompleted: {
        _poweredProc.running = true;
        _deviceProc.running = true;
    }
}
