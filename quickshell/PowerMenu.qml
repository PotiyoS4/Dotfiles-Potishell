import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

Scope {
    id: powerScope

    property bool isOpen: false

    // Process executor for shell commands
    Process {
        id: execProc
        running: false
    }

    PanelWindow {
        id: powerWindow
        visible: powerScope.isOpen

        // Request exclusive keyboard focus from Hyprland/Wayland layer-shell
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "#d0090d16" // Dark semi-transparent background

        readonly property var options: [
            { label: "SHUTDOWN", icon: "󰐥", command: "poweroff" },
            { label: "REBOOT",   icon: "󰜉", command: "reboot" },
            { label: "SLEEP",    icon: "󰤄", command: "systemctl suspend" },
            { label: "LOGOUT",   icon: "󰍃", command: "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'" },
            { label: "LOCK",     icon: "󰌾", command: "hyprlock" }
        ]

        property int currentIndex: 0
        property real targetRotation: 0

        function nextOption() {
            currentIndex = (currentIndex + 1) % options.length;
            targetRotation = -currentIndex * (360 / options.length);
        }

        function prevOption() {
            currentIndex = (currentIndex - 1 + options.length) % options.length;
            targetRotation = -currentIndex * (360 / options.length);
        }

        function executeSelected() {
            let cmd = options[currentIndex].command;
            powerScope.isOpen = false;
            execProc.command = ["sh", "-c", cmd];
            execProc.running = true;
        }

        // Fullscreen Mouse/Keyboard input layer
        FocusScope {
            anchors.fill: parent
            focus: powerScope.isOpen

            // Close on background click
            MouseArea {
                anchors.fill: parent
                onClicked: powerScope.isOpen = false
            }

            // Keyboard Navigation Listeners
            Keys.onLeftPressed: powerWindow.prevOption()
            Keys.onUpPressed: powerWindow.prevOption()
            Keys.onRightPressed: powerWindow.nextOption()
            Keys.onDownPressed: powerWindow.nextOption()
            Keys.onReturnPressed: powerWindow.executeSelected()
            Keys.onSpacePressed: powerWindow.executeSelected()
            Keys.onEscapePressed: powerScope.isOpen = false
        }

        // Center Wheel Container
        Item {
            id: wheelCenter
            anchors.centerIn: parent
            width: 420
            height: 420

            // Prevent background click-to-dismiss when clicking near the wheel
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => mouse.accepted = true
            }

            Item {
                id: cogContainer
                anchors.fill: parent
                rotation: powerWindow.targetRotation

                Behavior on rotation {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }

                // Decorative Outer Ring
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: "#00d4ff"
                    border.width: 3
                    opacity: 0.5
                }

                // Orbital Menu Items
                Repeater {
                    model: powerWindow.options.length

                    delegate: Item {
                        id: optionNode
                        readonly property real angle: (index * (360 / powerWindow.options.length)) * (Math.PI / 180)
                        readonly property real radius: 150

                        x: (wheelCenter.width / 2) + radius * Math.cos(angle) - (width / 2)
                        y: (wheelCenter.height / 2) + radius * Math.sin(angle) - (height / 2)
                        width: 70
                        height: 70

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: powerWindow.currentIndex === index ? "#00d4ff" : "#121826"
                            border.color: powerWindow.currentIndex === index ? "#ffffff" : "#00d4ff"
                            border.width: 2

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: powerWindow.currentIndex === index ? "#090d16" : "#ffffff"
                                font.pixelSize: 26
                                rotation: -cogContainer.rotation
                            }

                            // Direct click handler for mouse support
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (powerWindow.currentIndex === index) {
                                        powerWindow.executeSelected();
                                    } else {
                                        powerWindow.currentIndex = index;
                                        powerWindow.targetRotation = -index * (360 / powerWindow.options.length);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Central Hub Button
            Rectangle {
                anchors.centerIn: parent
                width: 140
                height: 140
                radius: width / 2
                color: "#090d16"
                border.color: "#00d4ff"
                border.width: 3

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: powerWindow.options[powerWindow.currentIndex].icon
                        color: "#00d4ff"
                        font.pixelSize: 36
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: powerWindow.options[powerWindow.currentIndex].label
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                    }
                }

                // Click center hub to execute active command
                MouseArea {
                    anchors.fill: parent
                    onClicked: powerWindow.executeSelected()
                }
            }
        }
    }
}
