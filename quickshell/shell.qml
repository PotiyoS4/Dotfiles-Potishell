import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

ShellRoot {
    id: shellRoot

    PanelWindow {
        id: bar

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 33
        color: "transparent"

        Poller {
            id: clock
            command: "date +%H:%M"
            interval: 1000
        }

        Poller {
            id: volume
            command: "/usr/bin/pamixer --get-volume-human"
            interval: 1000
        }

        Poller {
            id: bat
            command: "cat /sys/class/power_supply/BAT*/capacity"
            interval: 30000
        }

        Poller {
            id: net
            command: "nmcli -t -f NAME connection show --active | head -n1"
            interval: 5000
        }

        readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

        // Left Layout: MPRIS Media Player
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 14
            spacing: 8

            Pill {
                icon: ""
                maxLabelWidth: 200
                label: bar.player ? `${bar.player.trackArtist || "Unknown"} - ${bar.player.trackTitle || ""}` : "Nothing playing"
            }
        }

        // Center Layout: CAVA, Clock, Workspaces
        RowLayout {
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Cavapill {}
            Pill {
                icon: ""
                label: clock.value
            }
            Workspaces {}
        }

        // Right Layout: Battery, Network
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 14
            spacing: 8

            Pill {
                icon: "󱊣"
                label: bat.value !== "" ? bat.value + "%" : "--%"
            }
            Pill {
                icon: ""
                label: net.value !== "" ? net.value : "Disconnected"
            }
        }
    }

    // Persona 3 Cog Power Menu Instance
    PowerMenu {
        id: powerMenu
    }

    // Hyprland IPC Global Shortcut Handler
    GlobalShortcut {
        name: "power-menu"
        description: "Toggle Persona 3 Power Menu"
        onPressed: powerMenu.isOpen = !powerMenu.isOpen
    }
}
