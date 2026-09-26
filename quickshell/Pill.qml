import QtQuick
import QtQuick.Layouts

Rectangle {
  id:root

  property string icon: ""//var string icon
  property string label: "" //var string label
  property color iconColor: "#184e77"
  property int maxLabelWidth: 400
  implicitWidth: row.implicitWidth + 22
  implicitHeight: 28
  radius: height/2 //pill
  color: "#34A0A4"
  opacity: 0.8

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 7
   Text{
    text:root.icon
    color:root.iconColor
    font.family: "Jetbrains Mono Nerd Font"
    font.pixelSize:16
   }
   Text{
     text:root.label
     color: root.iconColor
     font.family: "Jetbrains Mono Nerd Font"
     font.pixelSize:16
     elide: Text.ElideRight
     Layout.maximumWidth: root.maxLabelWidth
     visible: root.label != "" 
    }
  }

}
