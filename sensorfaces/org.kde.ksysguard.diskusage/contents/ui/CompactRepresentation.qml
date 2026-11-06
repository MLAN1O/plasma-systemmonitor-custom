/*
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

Faces.CompactSensorFace {
    id: root

    contentItem: ColumnLayout {
        spacing: 1

        Repeater {
            model: root.controller.highPrioritySensorIds

            Item {
                id: bar

                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.smallSpacing

                readonly property string usedId: modelData
                readonly property string freeId: usedId.endsWith("/used") ? usedId.replace(/\/used$/, "/free") : ""
                readonly property color usedColor: root.colorSource.map[usedId] || Kirigami.Theme.highlightColor
                readonly property real totalValue: usedSensor.value + freeSensor.value
                readonly property real usedRatio: totalValue > 0 ? usedSensor.value / totalValue : 0

                Sensors.Sensor {
                    id: usedSensor
                    sensorId: bar.usedId
                    updateRateLimit: root.controller.updateRateLimit
                }

                Sensors.Sensor {
                    id: freeSensor
                    sensorId: bar.freeId
                    updateRateLimit: root.controller.updateRateLimit
                }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
                }

                Rectangle {
                    width: parent.width * bar.usedRatio
                    height: parent.height
                    radius: height / 2
                    color: bar.usedColor
                }
            }
        }
    }
}
