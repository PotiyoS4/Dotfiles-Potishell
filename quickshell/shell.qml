import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io

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
            id: bat
            command: "cat /sys/class/power_supply/BAT*/capacity"
            interval: 30000
        }

        Poller {
            id: net
            command: "nmcli -t -f NAME connection show --active | head -n1"
            interval: 5000
          }

          Poller {
            id: mem
            command: "free | awk 'NR==2{printf \"%d\", $3/$2*100}'"
            interval: 1000
          }

          Poller {
            id: cpu
            command: "top -bn1 | awk '/^%Cpu/ {printf \"%d\", 100-$8}'"
            interval: 2000
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
            Pill {
              icon: "󰍛"
              label: mem.value + "%"
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
              icon: "󰻠"
              label: cpu.value + "%"
            }

            Pill {
                icon: "󱊣"
                label: bat.value !== "" ? bat.value + "%" : "--%"
            }
            Pill {
                icon: ""
                label: net.value !== "" ? net.value : "Disconnected"
                Process {
                  id: ronemaProc
                  command: ["ronema"]
                 }
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    ronemaProc.running = false 
                    ronemaProc.running = true
                }

                }
              }
            
        }
    }

    // Persona 3 Cog Power Menu Instance
    PowerMenu {
        id: powerMenu
      }
    VolumeOsd {}


    // Hyprland IPC Global Shortcut Handler
    GlobalShortcut {
        name: "power-menu"
        description: "Toggle Persona 3 Power Menu"
        onPressed: powerMenu.isOpen = !powerMenu.isOpen
    }
}
