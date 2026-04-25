pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property bool available: internal.token !== "" && internal.haUrl !== ""

    readonly property string weatherCondition: internal.weatherCondition
    readonly property string weatherTemperature: internal.weatherTemperature
    readonly property string dogWalkTime: internal.dogWalkTime
    readonly property int dogWalkMinutes: internal.dogWalkMinutes

    readonly property var conditionIcons: ({
        "clear-night": "󰖔",
        "cloudy": "󰅟",
        "fog": "󰖑",
        "hail": "󰖒",
        "lightning": "󰖓",
        "lightning-rainy": "⛈",
        "partlycloudy": "󰖕",
        "pouring": "󰖖",
        "rainy": "󰖗",
        "snowy": "󰖘",
        "snowy-rainy": "󰙿",
        "sunny": "󰖙",
        "windy": "󰖝",
        "windy-variant": "󰖚",
        "exceptional": "󰼯"
    })

    function fetchState(entityId, callback) {
        if (!available) {
            callback(null);
            return;
        }

        // Check cache
        let now = Date.now();
        let cached = internal.cache[entityId];
        if (cached && (now - cached.time) < cached.ttl) {
            callback(cached.data);
            return;
        }

        let xhr = new XMLHttpRequest();
        let url = internal.haUrl + "/api/states/" + entityId;
        xhr.open("GET", url);
        xhr.setRequestHeader("Authorization", "Bearer " + internal.token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            if (xhr.status === 200) {
                try {
                    let data = JSON.parse(xhr.responseText);
                    internal.cache[entityId] = { data: data, time: Date.now(), ttl: 55000 };
                    callback(data);
                } catch (e) {
                    callback(cached ? cached.data : null);
                }
            } else {
                callback(cached ? cached.data : null);
            }
        };
        xhr.send();
    }

    property var internal: QtObject {
        property string token: ""
        property string haUrl: ""
        property var cache: ({})

        property string weatherCondition: ""
        property string weatherTemperature: ""
        property string dogWalkTime: ""
        property int dogWalkMinutes: 0

        property var weatherTimer: Timer {
            interval: 1800000
            running: root.available
            repeat: true
            onTriggered: internal.refreshWeather()
        }

        property var dogTimer: Timer {
            interval: 60000
            running: root.available
            repeat: true
            onTriggered: internal.refreshDog()
        }

        // Detect suspend/resume by watching for time jumps
        property real lastWakeTick: 0
        property var wakeDetector: Timer {
            interval: 15000
            running: root.available
            repeat: true
            onTriggered: {
                let now = Date.now();
                // If >60s elapsed since a 15s tick, system likely resumed from suspend
                if (internal.lastWakeTick > 0 && (now - internal.lastWakeTick) > 60000) {
                    // Delay refresh to let network come up
                    internal.wakeRefresh.restart();
                }
                internal.lastWakeTick = now;
            }
        }
        property var wakeRefresh: Timer {
            interval: 5000
            running: false
            repeat: false
            onTriggered: {
                internal.refreshWeather();
                internal.refreshDog();
                // Reset the polling timers so they count from now
                internal.weatherTimer.restart();
                internal.dogTimer.restart();
            }
        }

        function refreshWeather() {
            root.fetchState("weather.forecast_home", function(data) {
                if (!data) return;
                internal.weatherCondition = data.state || "";
                let attrs = data.attributes || {};
                if (attrs.temperature !== undefined) {
                    internal.weatherTemperature = Math.round(attrs.temperature) + (attrs.temperature_unit || "°C");
                }
            });
        }

        function refreshDog() {
            root.fetchState("sensor.walking_dog_digital", function(data) {
                if (!data) return;
                let state = data.state || "";
                let match = state.match(/^(\d+):(\d{2})$/);
                if (!match) return;
                internal.dogWalkTime = state;
                internal.dogWalkMinutes = parseInt(match[1]) * 60 + parseInt(match[2]);
            });
        }

        property bool _initialRefreshDone: false

        function _tryInitialRefresh() {
            if (!root.available || _initialRefreshDone) return;
            _initialRefreshDone = true;
            refreshWeather();
            refreshDog();
        }

        property var tokenProc: Process {
            id: tokenProc
            command: ["sh", "-c", "cat \"$CREDENTIALS_DIRECTORY/ha_token\" 2>/dev/null || true"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    internal.token = this.text.trim();
                    internal._tryInitialRefresh();
                }
            }
        }

        property var urlProc: Process {
            id: urlProc
            command: ["sh", "-c", "echo \"$HA_URL\""]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    internal.haUrl = this.text.trim();
                    internal._tryInitialRefresh();
                }
            }
        }
    }
}
