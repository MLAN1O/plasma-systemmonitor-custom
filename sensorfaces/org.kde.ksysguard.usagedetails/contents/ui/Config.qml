import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root

    property string cfg_mode: "memory"
    property int cfg_spacing: 12

    QQC2.ComboBox {
        Kirigami.FormData.label: "Tipo:"
        model: ["Memória", "Swap", "Memória e Swap"]
        currentIndex: root.cfg_mode === "swap" ? 1 : root.cfg_mode === "both" ? 2 : 0
        onActivated: root.cfg_mode = index === 1 ? "swap" : index === 2 ? "both" : "memory"
    }

    QQC2.SpinBox {
        Kirigami.FormData.label: "Espaçamento:"
        from: 0
        to: 24
        stepSize: 1
        value: root.cfg_spacing
        onValueModified: root.cfg_spacing = value
    }
}
