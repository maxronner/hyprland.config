// modules/bar/widgets/Dog.qml
// Dog walk time widget. Severity colors based on elapsed time since last walk.
// Error (>6h), warning (>4h), success otherwise. Hidden when HA unavailable.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    visible: HomeAssistant.available && HomeAssistant.dogWalkTime !== ""

    tooltip: "Last walk: " + (HomeAssistant.dogWalkTime || "unknown")

    readonly property color _iconColor: {
        if (HomeAssistant.dogWalkMinutes > 360) return Colours.palette.m3error;
        if (HomeAssistant.dogWalkMinutes > 240) return Colours.palette.m3tertiary;
        return Colours.palette.m3onSurface;
    }

    Text {
        anchors.centerIn: parent
        text: "pets"
        color: root._iconColor
        font.family: Appearance.font.family.icons
        font.pixelSize: Appearance.font.xl

        Behavior on color { CAnim {} }
    }
}
