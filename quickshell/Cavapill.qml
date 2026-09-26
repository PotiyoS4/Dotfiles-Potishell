import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Pill {
    id: cavaPill

    icon: ""
    label: cavaPill.cavaStream
    iconColor: "#184e77"

    // Block character glyphs mapping from levels 0 to 7
    readonly property var barChars: [" ", " ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
    property string cavaStream: "  ▄▆█▆▄  "

    // Continuous streaming listener with unbuffered output
    Process {
        id: cavaProc
        command: ["stdbuf", "-oL", "cava", "-p", "/home/potiyo/.config/cava/quickshellconf.ini"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let cleanData = data.trim();
                if (cleanData.length === 0) return;

                let values = cleanData.split(";").filter(v => v !== "");
                let result = "";

                for (let i = 0; i < values.length; i++) {
                    let level = parseInt(values[i]) || 0;
                    result += cavaPill.barChars[Math.min(level, 8)];
                }

                if (result.length > 0) {
                    cavaPill.cavaStream = result;
                }
            }
        }
    }
}
