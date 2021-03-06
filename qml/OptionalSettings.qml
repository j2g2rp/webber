import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UUITK

Item {
    property var appModel
    property bool showing: false
    property alias themeColor: colorField.text
    property alias enableAddressBar: radioTitleBar.checked
    property alias enableBackForward: radioTitleBarBackForward.checked
    property alias enableFullscreen: checkFullscreen.checked
    property alias enableDesktopUserAgent: checkDesktopUserAgent.checked

    function loadDefaults() {
        colorField.text = "#ffffff";
        radioNoTitleBar.checked = true;
        checkFullscreen.checked = false;
        checkDesktopUserAgent.checked = false;
    }

    function isValidColor(color) {
        return colorField.validator.regExp.test(color);
    }

    implicitHeight: visible ? column.childrenRect.height : 0
    visible: showing

    ColumnLayout {
        id: column

        width: parent.width
        height: childrenRect.height

        spacing: Suru.units.gu(1)

        Label {
            text: i18n.tr("Visuals & Behavior")
            font.bold: true
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 2
            columnSpacing: Suru.units.gu(1)
            rowSpacing: Suru.units.gu(1)

            Label {
                text: i18n.tr("Splash screen color (hex)")
            }

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    implicitHeight: Suru.units.gu(4)
                    implicitWidth: Suru.units.gu(4)
                    radius: Suru.units.dp(4)
                    border.width: Suru.units.dp(1)
                    border.color: Suru.neutralColor
                    color: colorField.text
                }

                UUITK.TextField {
                    id: colorField
                    Layout.fillWidth: true
                    text: "#ffffff"
                    validator: RegExpValidator {
                        regExp: /^#(?:[0-9a-fA-F]{3}){1,2}$/
                    }
                }
            }
        }

        CheckBox {
            id: checkFullscreen
            text: i18n.tr("Fullscreen")
        }

        CheckBox {
            id: checkDesktopUserAgent
            text: i18n.tr("Enable desktop mode (via user agent)")
        }

        Label {
            text: i18n.tr("Controls")
            font.bold: true
        }

        Column {
            Layout.fillWidth: true
            spacing: Suru.units.gu(1)

            RadioButton {
                id: radioNoTitleBar
                text: i18n.tr("Don't show a title bar")
                checked: true
            }

            RadioButton {
                id: radioTitleBar
                text: i18n.tr("Show title bar")
            }

            RadioButton {
                id: radioTitleBarBackForward
                text: i18n.tr("Show title bar with back/forward buttons")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: units.gu(1)

            Label {
                text: i18n.tr("Url patterns")
                font.bold: true
            }

            IconButton {
                iconName: "help"
                onClicked: Qt.openUrlExternally("http://docs.ubports.com/en/latest/appdev/webapp/guide.html#url-patterns")
            }

            Item { Layout.fillWidth: true }

            Button {
                text: i18n.tr("Add")
                onClicked: appModel.urlPatterns.add("")
            }
        }

        ListView {
            id: urlPatternsView

            Layout.fillWidth: true
            implicitHeight: contentHeight
            interactive: false

            model: appModel.urlPatterns.model
            clip: true

            delegate: Item {
                width: parent.width
                height: Suru.units.gu(5)

                RowLayout {
                    anchors.fill: parent

                    UUITK.TextField {
                        Layout.fillWidth: true

                        signal editingFinished()

                        text: model.url
                        placeholderText: "http://*.example.com/*"
                        inputMethodHints: Qt.ImhUrlCharactersOnly

                        onAccepted: editingFinished()
                        onActiveFocusChanged: if (!activeFocus) editingFinished()
                        onEditingFinished: {
                            if (text === "") {
                                appModel.urlPatterns.remove(index);
                            }
                            if (text !== "") {
                                appModel.urlPatterns.setUrl(index, text);
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: units.gu(1)

            Label {
                text: i18n.tr("Permissions")
                font.bold: true
            }

            IconButton {
                iconName: "help"
                onClicked: Qt.openUrlExternally("http://docs.ubports.com/en/latest/appdev/platform/apparmor.html")
            }
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: contentHeight
            interactive: false

            model: appModel.permissions.model
            clip: true

            delegate: ItemDelegate {
                width: parent.width
                height: Suru.units.gu(5)

                onClicked: {
                    checkbox.toggle();
                    appModel.permissions.setEnabled(index, checkbox.checked);
                }

                RowLayout {
                    anchors.fill: parent

                    CheckBox {
                        id: checkbox
                        checked: model.enabled
                        onToggled: {
                            appModel.permissions.setEnabled(index, checked);
                        }

                        Connections {
                            target: model
                            onEnabledChanged: {
                                checkbox.checked = model.enabled;
                            }
                        }
                    }

                    Label {
                        text: model.description
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
