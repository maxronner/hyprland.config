// panels/SystemInfoPanel.qml
// Hostname, distro, kernel, uptime display.
// Migrated from dashboard/SystemInfo.qml — clock removed (now in DateTimePanel).
// MaterialIcon + StyledText rows. Data from PollingProcess.
// Background: m3surfaceContainerLow, rounding: md.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../../components"

Rectangle {
    id: root

    color:  Colours.tPalette.m3surfaceContainerLow
    radius: Appearance.rounding.md

    Behavior on color { CAnim {} }

    implicitWidth:  300
    implicitHeight: 160

    // ---- System data ----
    property var _info: QtObject {
        property string hostname: ""
        property string distro:   ""
        property string kernel:   ""
        property string uptime:   ""
    }

    PollingProcess {
        command: ["sh", "-c", "hostname; cat /etc/os-release 2>/dev/null | grep '^PRETTY_NAME=' | cut -d'\"' -f2; uname -r; uptime -p"]
        interval: 60000
        onResult: (text) => {
            let lines = text.split("\n")
            if (lines.length >= 1) root._info.hostname = lines[0].trim()
            if (lines.length >= 2) root._info.distro   = lines[1].trim()
            if (lines.length >= 3) root._info.kernel   = lines[2].trim()
            if (lines.length >= 4) root._info.uptime   = lines[3].trim().replace("up ", "")
        }
    }

    // ---- Layout ----
    ColumnLayout {
        anchors {
            fill: parent
            margins: Appearance.padding.md
        }
        spacing: Appearance.spacing.sm

        // Section label
        StyledText {
            text: "System"
            color: Colours.tPalette.m3onSurfaceVariant
            font.pixelSize: Appearance.font.sm
            font.weight:    Font.Medium
        }

        // Distro row
        InfoRow {
            Layout.fillWidth: true
            icon: "terminal"
            iconColor: Colours.tPalette.m3primary
            primaryText: root._info.distro || "—"
        }

        // Hostname row
        InfoRow {
            Layout.fillWidth: true
            icon: "developer_board"
            iconColor: Colours.tPalette.m3primary
            primaryText: root._info.hostname || "—"
        }

        // Kernel row
        InfoRow {
            Layout.fillWidth: true
            icon: "code"
            iconColor: Colours.tPalette.m3secondary
            primaryText: root._info.kernel || "—"
        }

        // Uptime row
        InfoRow {
            Layout.fillWidth: true
            icon: "schedule"
            iconColor: Colours.tPalette.m3secondary
            primaryText: root._info.uptime || "—"
        }

        Item { Layout.fillHeight: true }
    }
}
