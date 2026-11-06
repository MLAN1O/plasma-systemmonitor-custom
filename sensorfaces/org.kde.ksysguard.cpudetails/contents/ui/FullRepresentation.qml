/*
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces
import org.kde.ksysguard.formatter as Formatter

import org.kde.plasma.plasma5support as P5Support

import org.kde.quickcharts as Charts
import org.kde.quickcharts.controls as ChartsControls

Faces.SensorFace {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20

    readonly property string historySensorId: root.controller.highPrioritySensorIds.length > 0 ? root.controller.highPrioritySensorIds[0] : ""
    readonly property int historySeconds: root.controller.faceConfiguration.historySeconds > 0 ? root.controller.faceConfiguration.historySeconds : 60
    readonly property bool showValues: root.controller.faceConfiguration.showValues !== false
    readonly property bool showYAxisLabels: root.controller.faceConfiguration.showYAxisLabels !== false
    readonly property bool showGridLines: root.controller.faceConfiguration.showGridLines !== false

    Sensors.Sensor {
        id: usageSensor
        sensorId: root.historySensorId
        updateRateLimit: root.controller.updateRateLimit
    }

    readonly property string temperatureSensorId: "cpu/all/averageTemperature"
    readonly property string temperatureCommand: 'for h in /sys/class/hwmon/hwmon*; do if [ "$(cat $h/name 2>/dev/null)" = coretemp ]; then cat $h/temp1_input; break; fi; done'
    readonly property string cpuTemperatureText: root.cpuTemperature >= 0 ? Math.round(root.cpuTemperature) + " °C" : "—"
    property real cpuTemperature: -1

    P5Support.DataSource {
        engine: "executable"
        interval: 2000
        connectedSources: [root.temperatureCommand]

        onNewData: (sourceName, data) => {
            var output = String(data["stdout"] || "").trim();
            var value = parseFloat(output.split("\n")[0]);
            root.cpuTemperature = isNaN(value) ? -1 : value / 1000;
        }
    }

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.minimumWidth: contentLayout.implicitWidth
        Layout.minimumHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: contentLayout.implicitWidth
        Layout.preferredHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
            anchors.rightMargin: Kirigami.Units.smallSpacing * 2
            anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
            clip: true
            spacing: Kirigami.Units.smallSpacing * 2

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing * 2
            spacing: Kirigami.Units.smallSpacing * 2

            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                Layout.alignment: Qt.AlignVCenter
                source: Qt.resolvedUrl("../../../../card-icons/cpu.svg")
                isMask: true
                color: Kirigami.Theme.highlightColor
            }

            Kirigami.Heading {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: root.controller.title
                visible: root.controller.showTitle && text.length > 0
                level: 2
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
            }

            QQC2.Label {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                text: usageSensor.formattedValue
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                opacity: 0.75
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 4
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            Layout.topMargin: root.showYAxisLabels ? axisMetrics.height / 2 : 0
            Layout.bottomMargin: root.showYAxisLabels ? axisMetrics.height / 2 : 0
            spacing: Kirigami.Units.smallSpacing

            ChartsControls.AxisLabels {
                id: axisLabels
                visible: root.showYAxisLabels
                Layout.fillHeight: true
                constrainToBounds: false
                direction: ChartsControls.AxisLabels.VerticalBottomTop

                delegate: QQC2.Label {
                    anchors.right: parent.right
                    font: Kirigami.Theme.smallFont
                    text: Formatter.Formatter.formatValueShowNull(ChartsControls.AxisLabels.label, sensorsModel.unit)
                    opacity: 0.75
                }

                source: Charts.ChartAxisSource {
                    chart: chart
                    axis: Charts.ChartAxisSource.YAxis
                    itemCount: 5
                }

                TextMetrics {
                    id: axisMetrics
                    font: Kirigami.Theme.smallFont
                    text: Formatter.Formatter.formatValueShowNull("0", sensorsModel.unit)
                }
            }

            Charts.LineChart {
                id: chart
                Layout.fillWidth: true
                Layout.fillHeight: true

                direction: Charts.XYChart.ZeroAtEnd
                fillOpacity: 0.15
                interpolate: true

                Sensors.SensorDataModel {
                    id: sensorsModel
                    sensors: root.historySensorId.length > 0 ? [root.historySensorId] : []
                    updateRateLimit: root.controller.updateRateLimit
                    sensorLabels: root.controller.sensorLabels

                    readonly property int unit: (sensorsModel.ready && sensorsModel.headerData(0, Qt.Horizontal, Sensors.SensorDataModel.Unit)) ?? Formatter.Units.UnitInvalid
                }

                Instantiator {
                    model: sensorsModel.sensors

                    delegate: Charts.HistoryProxySource {
                        id: history

                        source: Charts.ModelSource {
                            model: sensorsModel
                            column: index
                            roleName: "Value"
                        }

                        interval: {
                            if (root.controller.updateRateLimit > 0) {
                                return root.controller.updateRateLimit
                            }
                            if (sensorsModel.ready) {
                                return sensorsModel.headerData(index, Qt.Horizontal, Sensors.SensorDataModel.UpdateInterval) ?? 0
                            }
                            return 0
                        }
                        maximumHistory: interval > 0 ? (root.historySeconds * 1000) / interval : 0
                        fillMode: Charts.HistoryProxySource.FillFromEnd
                    }

                    onObjectAdded: (index, object) => chart.insertValueSource(index, object)
                    onObjectRemoved: (index, object) => chart.removeValueSource(object)
                }

                ChartsControls.GridLines {
                    id: horizontalLines
                    visible: root.showGridLines
                    opacity: 0.4
                    anchors.fill: parent
                    anchors.bottomMargin: -1
                    z: chart.z - 1
                    chart: chart
                    direction: ChartsControls.GridLines.Vertical

                    major.count: 3
                    major.lineWidth: 1
                    major.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.35)
                    minor.visible: false
                }

                Item {
                    anchors.fill: parent
                    anchors.bottomMargin: -1
                    z: chart.z - 1
                    visible: root.showGridLines

                    Rectangle {
                        width: 1
                        height: parent.height
                        opacity: 0.4
                        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.35)
                    }

                    Repeater {
                        model: 4

                        Rectangle {
                            x: Math.round(parent.width * (index + 1) / 5)
                            width: 1
                            height: parent.height
                            opacity: 0.4
                            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.35)
                        }
                    }
                }

                colorSource: root.colorSource
                nameSource: Charts.ModelSource {
                    roleName: "Name"
                    model: sensorsModel
                    indexColumns: true
                }
                shortNameSource: Charts.ModelSource {
                    roleName: "ShortName"
                    model: sensorsModel
                    indexColumns: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: root.controller.highPrioritySensorIds

                ChartsControls.LegendDelegate {
                    Layout.fillWidth: true

                    readonly property bool temperatureRow: modelData === root.temperatureSensorId

                    visible: root.showValues
                    name: root.controller.sensorLabels[modelData] || sensor.shortName || sensor.name
                    value: temperatureRow ? root.cpuTemperatureText : sensor.formattedValue
                    indicator: Item {}
                    maximumValueWidth: Kirigami.Units.gridUnit * 3

                    Sensors.Sensor {
                        id: sensor
                        sensorId: modelData
                        updateRateLimit: root.controller.updateRateLimit
                    }
                }
            }
        }
    }
    }
}
