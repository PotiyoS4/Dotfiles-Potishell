import Quickshell
import Quickshell.Io //iostream
import QtQuick

Scope{
  id: root
  
  property string command: ""
  property int interval: 3000 //3 secs
  property string value: ""

  Process{
    id: proc


    command: ["sh", "-c", root.command]
    running:true

    stdout: StdioCollector{
      onStreamFinished: root.value = this.text.trim();
      //gets text from the output of the given command, sends to value property.

    }
  }

  Timer {
    interval: root.interval
    running: true 
    repeat: true
    onTriggered: proc.running = true //rerun every [interval] secs

  }

}
