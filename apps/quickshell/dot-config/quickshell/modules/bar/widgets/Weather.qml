// modules/bar/widgets/Weather.qml
// Weather icon from HomeAssistant conditionIcons map.
// Hidden when HA is unavailable or no weather data.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    visible: HomeAssistant.available && HomeAssistant.weatherTemperature !== ""

    tooltip: {
        let t = HomeAssistant.weatherTemperature;
        let c = HomeAssistant.weatherCondition;
        if (t && c) return c.replace(/-/g, " ") + " · " + t;
        if (t) return t;
        return "Weather";
    }

    // Weather condition icon (from conditionIcons map, fallback to Material Symbols sunny)
    Text {
        anchors.centerIn: parent
        text: HomeAssistant.conditionIcons[HomeAssistant.weatherCondition] ?? "sunny"
        color: Colours.tPalette.m3onSurface
        font.family: Appearance.font.family.mono
        font.pixelSize: Appearance.font.xl

        Behavior on color { CAnim {} }
    }
}
