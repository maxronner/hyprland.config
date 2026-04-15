// modules/bar/widgets/PulseAudio.qml
// Volume control widget. Data from AudioService singleton.
// Scroll: adjust volume. Click: toggle mute. Muted: m3onSurfaceVariant color.
pragma ComponentBehavior: Bound
import QtQuick
import config
import services
import "../../../components"

WidgetContainer {
    id: root

    interactive: true

    tooltip: {
        if (AudioService.status === "unavailable") return "Audio: unavailable";
        if (AudioService.muted) return "Muted";
        return "Volume: " + Math.round(AudioService.volume * 100) + "%";
    }

    onClicked: AudioService.toggleMute()

    onWheel: event => {
        let delta = event.angleDelta.y > 0 ? 0.02 : -0.02;
        AudioService.incrementVolume(delta);
    }

    readonly property string _icon: {
        if (AudioService.status === "unavailable") return "volume_off";
        if (AudioService.muted) return "volume_off";
        let vol = AudioService.volume;
        if (vol > 0.66) return "volume_up";
        if (vol > 0.33) return "volume_down";
        return "volume_mute";
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root._icon
        size: Appearance.font.xl
        color: (AudioService.muted || AudioService.status === "unavailable")
            ? Colours.tPalette.m3onSurfaceVariant
            : Colours.tPalette.m3onSurface
    }
}
