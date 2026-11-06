/*
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

Faces.CompactSensorFace {
    id: root

    contentItem: ColumnLayout {
        spacing: 0

        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
            text: sensor.formattedValue
        }

        QQC2.Label {
            visible: root.formFactor == Faces.SensorFace.Planar && root.controller.showTitle && text.length > 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            opacity: 0.75
            text: root.controller.title
        }

        Sensors.Sensor {
            id: sensor
            sensorId: root.controller.highPrioritySensorIds.length > 0 ? root.controller.highPrioritySensorIds[0] : ""
            updateRateLimit: root.controller.updateRateLimit
        }
    }
}
