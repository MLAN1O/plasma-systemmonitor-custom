/*
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_historySeconds: historySeconds.value
    property alias cfg_showValues: showValues.checked
    property alias cfg_showYAxisLabels: showYAxisLabels.checked
    property alias cfg_showGridLines: showGridLines.checked

    QQC2.SpinBox {
        id: historySeconds
        Kirigami.FormData.label: "Histórico (segundos):"
        from: 10
        to: 600
        stepSize: 10
    }

    QQC2.CheckBox {
        id: showValues
        text: "Mostrar valores abaixo do gráfico"
    }

    QQC2.CheckBox {
        id: showYAxisLabels
        text: "Mostrar eixo Y"
    }

    QQC2.CheckBox {
        id: showGridLines
        text: "Mostrar linhas de grade"
    }
}
