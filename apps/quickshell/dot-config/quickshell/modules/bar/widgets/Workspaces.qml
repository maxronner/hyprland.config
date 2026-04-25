// modules/bar/widgets/Workspaces.qml
// Hyprland workspace indicators with M3 pill/dot style.
// Active: primary pill. Inactive: surface-variant dot. Urgent: error tint.
// Uses ListView for add/remove/displaced transitions.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import config
import services
import "../../../components"

Item {
    id: root

    // Fill the layout width, height driven by list content
    Layout.fillWidth: true
    implicitHeight: workspaceList.contentHeight

    // Cached workspace list — only rebuilt when workspace IDs change, not on focus changes
    property var _filteredWorkspaces: []
    function _rebuildModel() {
        let ws = [];
        for (const w of Hyprland.workspaces.values) {
            if (w.id > 0) ws.push(w);
        }
        ws.sort((a, b) => a.id - b.id);
        _filteredWorkspaces = ws;
    }
    Component.onCompleted: _rebuildModel()

    ListView {
        id: workspaceList

        anchors.horizontalCenter: parent.horizontalCenter
        width: 20
        height: contentHeight

        // Filter to positive IDs only (scratchpads are negative).
        // Cache the filtered list to avoid rebuilding the array on focus-only changes.
        model: root._filteredWorkspaces

        readonly property string _wsIds: {
            let ids = [];
            for (const w of Hyprland.workspaces.values) {
                if (w.id > 0) ids.push(w.id);
            }
            return ids.sort((a,b) => a - b).join(",");
        }
        on_WsIdsChanged: root._rebuildModel()

        orientation: ListView.Vertical
        spacing: Appearance.spacing.xs
        interactive: false

        delegate: Item {
            id: wsItem

            required property var modelData

            width: workspaceList.width
            height: 20

            // Pill for active, dot for inactive, error tint for urgent workspaces.
            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: wsItem.modelData.focused ? 14 : 8
                height: wsItem.modelData.focused ? 14 : 8
                radius: height / 2
                color: wsItem.modelData.urgent
                    ? Colours.palette.m3error
                    : wsItem.modelData.focused
                    ? Colours.palette.m3primary
                    : Colours.tPalette.m3onSurfaceVariant

            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsItem.modelData.id)
            }
        }

    }
}
