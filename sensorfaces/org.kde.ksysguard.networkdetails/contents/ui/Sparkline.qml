import QtQuick

import org.kde.quickcharts as Charts
import org.kde.ksysguard.sensors as Sensors

Item {
    id: root

    property string sensorId
    property color lineColor
    property int historySeconds: 60
    property int updateRateLimit: 0
    property real maximumValue: 0
    property var samples: []

    readonly property real maxLogValue: Math.log10(Math.max(maximumValue, 1024) + 1)

    function appendSample() {
        const value = Math.max(0, Number(sensor.value) || 0);
        samples.push(Math.min(maxLogValue, Math.log10(value + 1)));
        if (samples.length > historySeconds) {
            samples.shift();
        }
        valuesSource.array = samples.slice();
    }

    Sensors.Sensor {
        id: sensor
        sensorId: root.sensorId
        updateRateLimit: root.updateRateLimit
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.appendSample()
    }

    Component.onCompleted: Qt.callLater(root.appendSample)

    Charts.LineChart {
        id: chart
        anchors.fill: parent
        clip: true

        direction: Charts.XYChart.ZeroAtEnd
        yRange.automatic: false
        yRange.from: 0
        yRange.to: root.maxLogValue
        lineWidth: 1.5
        fillOpacity: 0.15
        interpolate: true

        colorSource: Charts.ColorGradientSource {
            baseColor: root.lineColor
            itemCount: 1
        }

        Charts.ArraySource {
            id: valuesSource
            array: []
        }

        Component.onCompleted: chart.insertValueSource(0, valuesSource)
    }
}
