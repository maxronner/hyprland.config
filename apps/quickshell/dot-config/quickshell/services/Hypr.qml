pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

QtObject {
    id: root

    property string activeSubmap: ""

    property var _connections: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap") {
                root.activeSubmap = event.data;
            }
        }
    }
}
