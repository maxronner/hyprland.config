import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property list<string> command: []
    property int interval: 10000
    property bool runOnStart: true

    signal result(string text)

    property var _proc: Process {
        command: root.command
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.result(this.text.trim())
        }
    }

    property var _timer: Timer {
        interval: root.interval
        running: root.command.length > 0
        repeat: true
        onTriggered: root._proc.running = true
    }

    Component.onCompleted: {
        if (runOnStart && command.length > 0) _proc.running = true
    }

    function run() {
        _proc.running = true
    }
}
