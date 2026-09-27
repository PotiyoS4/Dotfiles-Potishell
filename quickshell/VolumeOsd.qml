import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Volume change OSD. Slides up from the bottom edge on volume/mute change,
// then slides back down and hides itself after a short delay.
//
// Usage: drop this file next to your shell.qml (same directory) and add
// `VolumeOsd {}` inside your ShellRoot:
//
//   ShellRoot {
//       VolumeOsd {}
//       // ...your bars/other panels
//   }

PanelWindow {
    id: osd

    screen: Quickshell.screens[0]
    anchors.bottom: true

    implicitWidth: 340
    implicitHeight: 72
    color: "transparent"
    exclusiveZone: 0
    focusable: false

    // Resting position: fully below the screen edge (plus a little extra
    // so the rounded corners/shadow don't peek in).
    readonly property int hiddenMargin: -implicitHeight - 8
    // Position when shown: how far up from the bottom edge.
    readonly property int shownMargin: 28
    // How long the popup stays up before it slides away again.
    readonly property int showDuration: 1400

    margins.bottom: hiddenMargin

    Behavior on margins.bottom {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null
        function onVolumeChanged() { osd.popup() }
        function onMutedChanged() { osd.popup() }
    }

    Timer {
        id: hideTimer
        interval: osd.showDuration
        onTriggered: osd.margins.bottom = osd.hiddenMargin
    }

    function popup() {
        osd.margins.bottom = osd.shownMargin
        hideTimer.restart()
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#184e77"
        border.color: "#313244"
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                color: "#cdd6f4"
                text: {
                    const sink = Pipewire.defaultAudioSink;
                    if (!sink?.audio) return "";
                    if (sink.audio.muted) return "󰖁";
                    return sink.audio.volume > 0.5 ? "" : "";
                }
            }

            Rectangle {
                id: track
                width: parent.width - 90
                height: 8
                radius: width/2
                color: "#3e5598"
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    height: parent.height
                    radius: height/2
                    color: "#34a0a4"
                    width: track.width * (Pipewire.defaultAudioSink?.audio?.muted
                        ? 0
                        : (Pipewire.defaultAudioSink?.audio?.volume ?? 0))

                    Behavior on width {
                        NumberAnimation { duration: 120 }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: "#cdd6f4"
                font.pixelSize: 14
                text: Math.round((Pipewire.defaultAudioSink?.audio?.volume ?? 0) * 100) + "%"
            }
        }
    }
}
