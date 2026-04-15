pragma Singleton
import QtQuick

QtObject {
    id: root

    property string hours: "00"
    property string minutes: "00"
    property string seconds: "00"
    property string dateShort: ""
    property string dateFull: ""
    property int dayOfWeek: 0
    property int dayOfMonth: 0

    property var _timer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date();

            root.hours = String(now.getHours()).padStart(2, "0");
            root.minutes = String(now.getMinutes()).padStart(2, "0");
            root.seconds = String(now.getSeconds()).padStart(2, "0");
            root.dayOfWeek = now.getDay();
            root.dayOfMonth = now.getDate();

            root.dateShort = now.toLocaleDateString(Qt.locale(), "MMMM d, yyyy");
            root.dateFull = now.toLocaleDateString(Qt.locale(), "dddd, MMMM d, yyyy");
        }
    }
}
