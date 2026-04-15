// modules/notifications/NotificationPopup.qml
// Toast notification popups — top-right stacking with urgency-based auto-dismiss.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import config
import services
import "../../components"

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    implicitWidth: 380
    implicitHeight: toastColumn.implicitHeight

    margins {
        top: 10
        right: 10
    }

    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    focusable: false
    visible: toastModel.count > 0

    color: "transparent"

    // ---- Toast data model ----
    ListModel {
        id: toastModel
    }

    // ---- Listen for new notifications ----
    Connections {
        target: NotificationService
        function onToastRequested(notification) {
            // Evict oldest non-critical if at max
            while (toastModel.count >= 4) {
                let evicted = false;
                for (let i = 0; i < toastModel.count; i++) {
                    if (toastModel.get(i).urgency !== NotificationUrgency.Critical) {
                        toastModel.remove(i);
                        evicted = true;
                        break;
                    }
                }
                if (!evicted) break; // all critical, allow overflow
            }

            toastModel.append({
                notifId: notification.id,
                appName: notification.appName || "",
                appIcon: notification.appIcon || "",
                summary: notification.summary || "",
                body: notification.body || "",
                image: notification.image || "",
                urgency: notification.urgency,
                dismissTime: notification.urgency === NotificationUrgency.Critical
                    ? 0  // never auto-dismiss
                    : (notification.urgency === NotificationUrgency.Low ? 3000 : 5000)
            });
        }
    }

    // ---- Toast column ----
    ColumnLayout {
        id: toastColumn

        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }

        spacing: Appearance.spacing.sm

        Repeater {
            model: toastModel

            delegate: Item {
                id: toast

                required property int index
                required property string appName
                required property string appIcon
                required property string summary
                required property string body
                required property string image
                required property int urgency
                required property int dismissTime

                Layout.fillWidth: true
                implicitHeight: card.implicitHeight
                opacity: 0.0

                property real slideOffset: 80
                transform: Translate { x: toast.slideOffset }

                Component.onCompleted: {
                    opacity = 1.0;
                    slideOffset = 0;
                    if (dismissTime > 0)
                        dismissTimer.start();
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.anim.duration.sm
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.standardDecel
                    }
                }

                Behavior on slideOffset {
                    NumberAnimation {
                        duration: Appearance.anim.duration.md
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.emphasizedDecel
                    }
                }

                Timer {
                    id: dismissTimer
                    interval: toast.dismissTime
                    repeat: false
                    onTriggered: toast._dismiss()
                }

                function _dismiss() {
                    if (toast.index >= 0 && toast.index < toastModel.count)
                        toastModel.remove(toast.index);
                }

                NotificationCard {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    appName: toast.appName
                    appIcon: toast.appIcon
                    summary: toast.summary
                    body: toast.body
                    image: toast.image
                    urgency: toast.urgency
                    onDismissed: toast._dismiss()
                }
            }
        }
    }
}
