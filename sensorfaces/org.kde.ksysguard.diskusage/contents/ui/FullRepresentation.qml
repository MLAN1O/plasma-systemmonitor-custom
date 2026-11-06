/*
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

import "../../../../plasma-systemmonitor-custom/config.js" as LocalConfig

Faces.SensorFace {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22

    readonly property var diskMetadata: LocalConfig.disks

    function diskInfoFor(sensorId) {
        var deviceId = sensorId.replace(/^disk\//, "").replace(/\/used$/, "");
        var info = root.diskMetadata[deviceId];
        if (!info) {
            return {
                filesystem: "",
                mountPoint: "",
                icon: "drive.svg",
                color: Kirigami.Theme.highlightColor
            };
        }
        var result = {};
        for (var key in info) {
            result[key] = info[key];
        }
        if (result.color === "highlight") {
            result.color = Kirigami.Theme.highlightColor;
        }
        return result;
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
                    source: Qt.resolvedUrl("../../../../card-icons/disk.svg")
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
            }

            Repeater {
                model: root.controller.highPrioritySensorIds

                Rectangle {
                    id: diskCard

                    Layout.fillWidth: true
                    Layout.minimumHeight: rowLayout.implicitHeight + Kirigami.Units.smallSpacing * 6
                    Layout.preferredHeight: rowLayout.implicitHeight + Kirigami.Units.smallSpacing * 6
                    radius: Kirigami.Units.smallSpacing * 2
                    color: Kirigami.Theme.alternateBackgroundColor
                    border.width: 1
                    border.color: mouseArea.containsMouse
                        ? Kirigami.Theme.highlightColor
                        : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)

                    readonly property string usedId: modelData
                    readonly property string freeId: usedId.endsWith("/used") ? usedId.replace(/\/used$/, "/free") : ""
                    readonly property color usedColor: diskCard.info.color || root.colorSource.map[usedId] || Kirigami.Theme.highlightColor
                    readonly property real totalValue: usedSensor.value + freeSensor.value
                    readonly property real usedRatio: totalValue > 0 ? usedSensor.value / totalValue : 0
                    readonly property string diskLabel: root.controller.sensorLabels[usedId] || usedSensor.name
                    readonly property var info: root.diskInfoFor(usedId)

                    Sensors.Sensor {
                        id: usedSensor
                        sensorId: diskCard.usedId
                        updateRateLimit: root.controller.updateRateLimit
                    }

                    Sensors.Sensor {
                        id: freeSensor
                        sensorId: diskCard.freeId
                        updateRateLimit: root.controller.updateRateLimit
                    }

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing * 3
                        spacing: Kirigami.Units.smallSpacing * 2

                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.large - Kirigami.Units.smallSpacing
                            Layout.preferredHeight: Kirigami.Units.iconSizes.large - Kirigami.Units.smallSpacing
                            Layout.alignment: Qt.AlignVCenter
                            source: Qt.resolvedUrl("../../../../card-icons/" + diskCard.info.icon)
                            isMask: true
                            color: "#6E747A"
                        }

                        ColumnLayout {
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 10
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: diskCard.diskLabel
                                elide: Text.ElideRight
                                font.bold: true
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                            }

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: diskCard.info.filesystem + " · " + diskCard.info.mountPoint
                                elide: Text.ElideRight
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                opacity: 0.7
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Kirigami.Units.smallSpacing / 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.smallSpacing

                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 0.75)

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: height / 2
                                        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
                                    }

                                    Rectangle {
                                        width: parent.width * diskCard.usedRatio
                                        height: parent.height
                                        radius: height / 2
                                        color: diskCard.usedColor
                                    }
                                }

                                QQC2.Label {
                                    text: Math.round(diskCard.usedRatio * 100) + "%"
                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                    opacity: 0.8
                                }
                            }

                            QQC2.Label {
                                visible: root.controller.faceConfiguration.showValues !== false
                                Layout.fillWidth: true
                                text: usedSensor.formattedValue + " usados · " + freeSensor.formattedValue + " livres"
                                horizontalAlignment: Text.AlignRight
                                wrapMode: Text.Wrap
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                opacity: 0.75
                            }
                        }

                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            Layout.alignment: Qt.AlignVCenter
                            source: "go-next-symbolic"
                            color: Kirigami.Theme.textColor
                            opacity: 0.6
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        z: 1
                        hoverEnabled: true
                        cursorShape: diskCard.info.mountPoint.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (diskCard.info.mountPoint.length > 0) {
                                Qt.openUrlExternally("file://" + diskCard.info.mountPoint);
                            }
                        }
                    }
                }
            }
        }
    }
}
