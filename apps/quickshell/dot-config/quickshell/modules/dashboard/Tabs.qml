// modules/dashboard/Tabs.qml
// 3-tab bar with an animated sliding indicator.
//
// Active tab: m3secondaryContainer bg, m3onSecondaryContainer text.
// Inactive tabs: transparent bg, m3onSurfaceVariant text.
// Indicator slides between tabs using States + Transitions anchored to delegate ids.
// Left/right arrow keys switch tabs; Tab key moves focus into tab content when applicable.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import config
import services
import "../../components"

Item {
    id: root

    property int currentIndex: 0

    // Whether each tab has focusable content (Tab key goes there when true)
    readonly property var tabHasFocusableContent: [true, false, false]

    signal tabChanged(int index)

    implicitHeight: tabRow.implicitHeight + Appearance.padding.sm * 2

    // ---- Background pill ----
    Rectangle {
        anchors.fill: parent
        color:  Colours.tPalette.m3surfaceContainerLow
        radius: Appearance.rounding.full
        Behavior on color { CAnim {} }
    }

    // ---- Animated indicator ----
    Rectangle {
        id: indicator
        color:  Colours.tPalette.m3secondaryContainer
        radius: Appearance.rounding.full
        Behavior on color { CAnim {} }

        // Positioned via states below.
        // tab*.x/y are relative to tabRow; offset by tabRow position in root.
        x: tabRow.x + tab0.x
        y: tabRow.y + tab0.y
        width:  tab0.width
        height: tab0.height

        states: [
            State {
                name: "tab0"
                when: root.currentIndex === 0
                PropertyChanges {
                    indicator.x:      tabRow.x + tab0.x
                    indicator.y:      tabRow.y + tab0.y
                    indicator.width:  tab0.width
                    indicator.height: tab0.height
                }
            },
            State {
                name: "tab1"
                when: root.currentIndex === 1
                PropertyChanges {
                    indicator.x:      tabRow.x + tab1.x
                    indicator.y:      tabRow.y + tab1.y
                    indicator.width:  tab1.width
                    indicator.height: tab1.height
                }
            },
            State {
                name: "tab2"
                when: root.currentIndex === 2
                PropertyChanges {
                    indicator.x:      tabRow.x + tab2.x
                    indicator.y:      tabRow.y + tab2.y
                    indicator.width:  tab2.width
                    indicator.height: tab2.height
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {
                    properties: "x,y,width,height"
                    duration: Appearance.anim.duration.md
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.standard
                }
            }
        ]
    }

    // ---- Tab buttons ----
    RowLayout {
        id: tabRow
        anchors {
            fill: parent
            margins: Appearance.padding.sm
        }
        spacing: Appearance.spacing.xs

        // Tab 0: Dashboard
        Item {
            id: tab0
            Layout.fillWidth:  true
            Layout.fillHeight: true
            implicitHeight: label0.implicitHeight + Appearance.padding.md * 2

            StyledText {
                id: label0
                anchors.centerIn: parent
                text: "Dashboard"
                color: root.currentIndex === 0
                       ? Colours.tPalette.m3onSecondaryContainer
                       : Colours.tPalette.m3onSurfaceVariant
            }

            StateLayer {
                radius: Appearance.rounding.full
                color:  Colours.palette.m3onSurface
                onTapped: (_) => { root.currentIndex = 0; root.tabChanged(0) }
            }
        }

        // Tab 1: Performance
        Item {
            id: tab1
            Layout.fillWidth:  true
            Layout.fillHeight: true
            implicitHeight: label1.implicitHeight + Appearance.padding.md * 2

            StyledText {
                id: label1
                anchors.centerIn: parent
                text: "Performance"
                color: root.currentIndex === 1
                       ? Colours.tPalette.m3onSecondaryContainer
                       : Colours.tPalette.m3onSurfaceVariant
            }

            StateLayer {
                radius: Appearance.rounding.full
                color:  Colours.palette.m3onSurface
                onTapped: (_) => { root.currentIndex = 1; root.tabChanged(1) }
            }
        }

        // Tab 2: Weather
        Item {
            id: tab2
            Layout.fillWidth:  true
            Layout.fillHeight: true
            implicitHeight: label2.implicitHeight + Appearance.padding.md * 2

            StyledText {
                id: label2
                anchors.centerIn: parent
                text: "Weather"
                color: root.currentIndex === 2
                       ? Colours.tPalette.m3onSecondaryContainer
                       : Colours.tPalette.m3onSurfaceVariant
            }

            StateLayer {
                radius: Appearance.rounding.full
                color:  Colours.palette.m3onSurface
                onTapped: (_) => { root.currentIndex = 2; root.tabChanged(2) }
            }
        }
    }

    // ---- Keyboard navigation ----
    Keys.onLeftPressed:  {
        if (root.currentIndex > 0) {
            root.currentIndex -= 1
            root.tabChanged(root.currentIndex)
        }
    }
    Keys.onRightPressed: {
        if (root.currentIndex < 2) {
            root.currentIndex += 1
            root.tabChanged(root.currentIndex)
        }
    }
    Keys.onTabPressed: {
        if (root.tabHasFocusableContent[root.currentIndex]) {
            nextItemInFocusChain().forceActiveFocus()
        }
    }

    focusPolicy: Qt.TabFocus
}
