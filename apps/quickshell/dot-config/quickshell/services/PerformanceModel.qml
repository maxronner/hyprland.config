pragma Singleton
import QtQuick
import "../components" as Components

QtObject {
    id: root

    readonly property real cpuUsage: internal.cpuUsage
    readonly property real memUsedGb: internal.memUsedGb
    readonly property real memTotalGb: internal.memTotalGb
    readonly property int tempC: internal.tempC
    readonly property real batteryPercent: internal.batteryPercent

    readonly property var cpuHistory: internal.cpuHistory
    readonly property var memHistory: internal.memHistory
    readonly property var tempHistory: internal.tempHistory
    readonly property var batteryHistory: internal.batteryHistory

    readonly property string cpuSeverity: cpuUsage > 80 ? "critical" : cpuUsage > 60 ? "warning" : "normal"
    readonly property string memSeverity: memTotalGb > 0 && (memUsedGb / memTotalGb) > 0.85 ? "critical" : "normal"
    readonly property string tempSeverity: tempC >= 80 ? "critical" : tempC >= 60 ? "warning" : "normal"
    readonly property string batterySeverity: batteryPercent < 15 ? "critical" : batteryPercent < 30 ? "warning" : "normal"

    property var internal: QtObject {
        readonly property int maxSamples: 60

        property real cpuUsage: 0
        property real memUsedGb: 0
        property real memTotalGb: 0
        property int tempC: 0

        property var cpuHistory: []
        property var memHistory: []
        property var tempHistory: []

        property real batteryPercent: 0
        property var batteryHistory: []

        function pushSample(arr, value) {
            let copy = arr.slice();
            copy.push(value);
            if (copy.length > maxSamples) copy = copy.slice(copy.length - maxSamples);
            return copy;
        }

        // CPU polling
        property var prevIdle: 0
        property var prevTotal: 0

        property var cpuPoller: Components.PollingProcess {
            command: ["sh", "-c", "head -1 /proc/stat"]
            interval: 2000
            onResult: (text) => {
                let parts = text.split(/\s+/).slice(1).map(Number);
                let idle = parts[3] + (parts[4] || 0);
                let total = parts.reduce((a, b) => a + b, 0);

                if (internal.prevTotal > 0) {
                    let dTotal = total - internal.prevTotal;
                    let dIdle = idle - internal.prevIdle;
                    internal.cpuUsage = dTotal > 0 ? ((dTotal - dIdle) / dTotal) * 100 : 0;
                }

                internal.prevIdle = idle;
                internal.prevTotal = total;
                internal.cpuHistory = internal.pushSample(internal.cpuHistory, internal.cpuUsage);
            }
        }

        // Memory polling
        property var memPoller: Components.PollingProcess {
            command: ["sh", "-c", "awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf \"%d %d\", t, a}' /proc/meminfo"]
            interval: 2000
            onResult: (text) => {
                let parts = text.split(/\s+/).map(Number);
                if (parts.length >= 2) {
                    internal.memTotalGb = parts[0] / 1048576;
                    internal.memUsedGb = (parts[0] - parts[1]) / 1048576;
                }
                internal.memHistory = internal.pushSample(internal.memHistory, internal.memUsedGb);
            }
        }

        // Temperature polling
        // Probes Intel coretemp, AMD k10temp, and a specific PCI hwmon path.
        // Adjust paths for your hardware — falls back to 0 if none match.
        property var tempPoller: Components.PollingProcess {
            command: ["sh", "-c", "for f in /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input /sys/devices/platform/k10temp.0/hwmon/hwmon*/temp1_input /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input; do [ -f \"$f\" ] && cat \"$f\" && exit; done; echo 0"]
            interval: 2000
            onResult: (text) => {
                let val = parseInt(text);
                if (val > 0) internal.tempC = Math.round(val / 1000);
                internal.tempHistory = internal.pushSample(internal.tempHistory, internal.tempC);
            }
        }

        // Battery polling
        property var batteryPoller: Components.PollingProcess {
            command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0"]
            interval: 30000
            onResult: (text) => {
                let val = parseInt(text);
                internal.batteryPercent = isNaN(val) ? 0 : val;
                internal.batteryHistory = internal.pushSample(internal.batteryHistory, internal.batteryPercent);
            }
        }
    }
}
