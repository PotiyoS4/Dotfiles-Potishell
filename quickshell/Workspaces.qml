import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle{
  implicitWidth: row.implicitWidth + 22
  implicitHeight: 28
  radius: height/2
  color: "#34A0A4"

  RowLayout{
    id: row
    anchors.centerIn: parent
    spacing: 8

    Repeater{
      model: Hyprland.workspaces
      Rectangle{
        implicitWidth: modelData.active ? 11 : 6
        implicitHeight: implicitWidth
        radius: width / 2
        color: modelData.active ? "transparent" : "#184e77"
        border.width: modelData.active ? 2 : 0
        border.color: "#184e77"

        Behavior on implicitWidth{
          NumberAnimation {duration: 160; easing.type: Easing.OutCubic}
        }

      }
    }
  }
}
