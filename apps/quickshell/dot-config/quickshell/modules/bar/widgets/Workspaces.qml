// modules/bar/widgets/Workspaces.qml
// Hyprland workspace indicators with M3 pill/dot style.
// Active: 20px pill (m3primary). Inactive: 6px dot (m3onSurfaceVariant).
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

            // Pill for active, dot for inactive
            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: wsItem.modelData.focused ? 14 : 8
                height: wsItem.modelData.focused ? 14 : 8
                radius: height / 2
                color: wsItem.modelData.focused
                    ? Colours.palette.m3primary
                    : Colours.tPalette.m3onSurfaceVariant

                Behavior on width {
                    NumberAnimation {
                        duration: Appearance.anim.duration.sm
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.emphasizedDecel
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: Appearance.anim.duration.sm
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.emphasizedDecel
                    }
                }
                Behavior on color { CAnim {} }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsItem.modelData.id)
            }
        }

        // Add transition: fade + slide in from above
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Appearance.anim.duration.sm }
            NumberAnimation { property: "y"; from: -10; duration: Appearance.anim.duration.sm; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasizedDecel }
        }

        // Remove transition: fade out
        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: Appearance.anim.duration.sm }
        }

        // Displaced: animate to new position
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: Appearance.anim.duration.sm; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.anim.emphasizedDecel }
        }

        // Populate: instant (no animation on first load)
        populate: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 0 }
        }
    }
}
