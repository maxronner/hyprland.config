// modules/wallpaperpicker/WallpaperFilmstrip.qml
// Horizontal thumbnail filmstrip for wallpaper selection.
// Scans the wallpaper directory, renders async thumbnails, and supports
// keyboard navigation with wrap-around.
pragma ComponentBehavior: Bound
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import config
import services
import "../../components"

Item {
    id: root

    // Emitted when the user commits a wallpaper (Enter or click)
    signal wallpaperCommitted(path: string)

    // Emitted when the user navigates to a new wallpaper (for preview)
    signal wallpaperPreviewed(path: string)

    readonly property string _wallpaperDir: {
        let p = StandardPaths.writableLocation(StandardPaths.GenericDataLocation).toString();
        if (p.startsWith("file://")) p = p.substring(7);
        return p + "/wallpapers";
    }

    property bool _ready: false

    implicitHeight: 200

    // ---- File scanning ----
    ListModel { id: wallpaperModel }

    Process {
        id: scanProc
        command: [
            "find", "-L", root._wallpaperDir,
            "-maxdepth", "1", "-type", "f",
            "(", "-iname", "*.jpg",
            "-o", "-iname", "*.jpeg",
            "-o", "-iname", "*.png",
            "-o", "-iname", "*.gif",
            "-o", "-iname", "*.bmp", ")"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0);
                lines.sort();
                for (const line of lines) {
                    wallpaperModel.append({ path: line });
                }

                // Find index matching current wallpaper
                let matchIndex = 0;
                const current = WallpaperService.current;
                for (let i = 0; i < wallpaperModel.count; i++) {
                    if (wallpaperModel.get(i).path === current) {
                        matchIndex = i;
                        break;
                    }
                }
                filmstripView.currentIndex = matchIndex;

                // Enable preview handler after initial index is set
                Qt.callLater(() => { root._ready = true; });
            }
        }
    }

    // ---- Empty state ----
    StyledText {
        anchors.centerIn: parent
        visible: wallpaperModel.count === 0 && !scanProc.running
        text: "No wallpapers found"
        color: Colours.tPalette.m3onSurfaceVariant
        font.pixelSize: Appearance.font.lg
    }

    // ---- Filmstrip ListView ----
    ListView {
        id: filmstripView

        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: Appearance.spacing.sm
        clip: true
        visible: wallpaperModel.count > 0

        model: wallpaperModel

        // Pad the edges so the first/last item can be centered
        leftMargin: Appearance.padding.xl
        rightMargin: Appearance.padding.xl

        highlightMoveDuration: Appearance.anim.duration.sm

        onCurrentIndexChanged: {
            if (!root._ready) return;
            positionViewAtIndex(currentIndex, ListView.Center);
            const item = wallpaperModel.get(currentIndex);
            if (item) root.wallpaperPreviewed(item.path);
        }

        delegate: Item {
            id: del

            required property int index
            required property string path

            width: thumbnailImg.implicitWidth > 0
                ? thumbnailImg.implicitWidth
                : Math.round(filmstripView.height * 16 / 9)
            height: filmstripView.height

            // ---- Highlight border ----
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: Appearance.rounding.sm + 3
                color: "transparent"
                border.width: filmstripView.currentIndex === del.index ? 3 : 0
                border.color: Colours.tPalette.m3primary
                visible: filmstripView.currentIndex === del.index

                Behavior on border.width {
                    NumberAnimation { duration: Appearance.anim.duration.xs }
                }
            }

            // ---- Thumbnail ----
            Rectangle {
                anchors.fill: parent
                radius: Appearance.rounding.sm
                color: Colours.tPalette.m3surfaceContainerHigh
                clip: true
                layer.enabled: true

                Image {
                    id: thumbnailImg
                    anchors.fill: parent
                    source: "file://" + del.path
                    sourceSize.height: 180
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                }
            }

            // ---- Click to commit ----
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    filmstripView.currentIndex = del.index;
                    root.wallpaperCommitted(del.path);
                }
            }
        }
    }

    // ---- Keyboard navigation ----
    Keys.onPressed: event => {
        if (wallpaperModel.count === 0) return;

        if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
            filmstripView.currentIndex =
                (filmstripView.currentIndex - 1 + wallpaperModel.count) % wallpaperModel.count;
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            filmstripView.currentIndex =
                (filmstripView.currentIndex + 1) % wallpaperModel.count;
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const item = wallpaperModel.get(filmstripView.currentIndex);
            if (item) root.wallpaperCommitted(item.path);
            event.accepted = true;
        }
    }
}
