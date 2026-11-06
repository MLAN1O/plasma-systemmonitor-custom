import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

Faces.CompactSensorFace {
    id: root

    contentItem: ColumnLayout {
        spacing: 1

        Repeater {
            model: root.controller.highPrioritySensorIds

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    Layout.fillWidth: true
                    text: root.controller.sensorLabels[modelData] || sensor.name
                    elide: Text.ElideRight
                    font: Kirigami.Theme.smallFont
                }

                QQC2.Label {
                    text: sensor.formattedValue
                    font: Kirigami.Theme.smallFont
                }

                Sensors.Sensor {
                    id: sensor
                    sensorId: modelData
                    updateRateLimit: root.controller.updateRateLimit
                }
            }
        }
    }
}
