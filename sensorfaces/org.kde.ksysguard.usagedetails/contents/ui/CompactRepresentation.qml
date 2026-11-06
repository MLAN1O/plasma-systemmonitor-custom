import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.faces as Faces

Faces.SensorFace {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 6
    Layout.minimumHeight: Kirigami.Units.gridUnit * 2

    contentItem: QQC2.Label {
        text: root.controller.title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
