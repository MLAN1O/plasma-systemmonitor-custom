/*
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_showValues: showValues.checked

    QQC2.CheckBox {
        id: showValues
        text: "Mostrar valores de usado/livre"
    }
}
