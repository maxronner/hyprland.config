pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

QtObject {
    id: root

    property string status: "available"
    property int count: 0
    property bool dndEnabled: false

    // Expose the tracked notifications ObjectModel directly for UI binding
    readonly property var notifications: server.trackedNotifications

    // Toast popup data — ListModel for the toast UI to bind to
    property var toasts: ListModel {}
    readonly property int maxToasts: 4
    // Cap tracked history to avoid unbounded RAM growth in the notification pane.
    readonly property int maxTrackedNotifications: 150

    signal toastRequested(var notification)

    // Notification sound with cooldown
    property bool _soundCooldown: false
    property var _soundProc: Process {
        command: ["paplay", "/usr/share/sounds/freedesktop/stereo/message.oga"]
        running: false
    }
    property var _cooldownTimer: Timer {
        interval: 1000
        repeat: false
        onTriggered: root._soundCooldown = false
    }

    function _playSound() {
        if (_soundCooldown) return;
        _soundCooldown = true;
        _cooldownTimer.start();
        _soundProc.running = true;
    }

    function toggleDnd() {
        root.dndEnabled = !root.dndEnabled;
    }

    function dismiss(notification) {
        notification.dismiss();
    }

    function dismissAll() {
        // Copy to array first — dismissing modifies the model
        const items = [...server.trackedNotifications.values];
        for (const item of items) {
            item.dismiss();
        }
    }

    function enforceTrackedNotificationLimit() {
        const tracked = [...server.trackedNotifications.values];
        let excess = tracked.length - root.maxTrackedNotifications;
        if (excess <= 0) {
            return;
        }

        // Prefer dropping non-critical notifications first to preserve critical alerts.
        for (const notification of tracked) {
            if (excess <= 0) {
                break;
            }
            if (notification.urgency === NotificationUrgency.Critical) {
                continue;
            }
            notification.dismiss();
            excess--;
        }

        // If everything is critical and we still overflow, trim oldest notifications.
        for (const notification of tracked) {
            if (excess <= 0) {
                break;
            }
            notification.dismiss();
            excess--;
        }
    }

    property var server: NotificationServer {
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            // In DND mode, expire silently — except critical
            if (root.dndEnabled && notification.urgency !== NotificationUrgency.Critical) {
                notification.expire();
                return;
            }
            notification.tracked = true;
            root._playSound();
            // Bar badge only counts Normal and Critical
            if (notification.urgency !== NotificationUrgency.Low) {
                root.count++;
                notification.closed.connect(() => { root.count = Math.max(0, root.count - 1); });
            }
            root.toastRequested(notification);
            enforceTrackedNotificationLimit();
        }
    }
}
