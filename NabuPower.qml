import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.DCommon.Widgets as DCommon
import qs.Modules.Plugins

// 控制中心里的电源档位切换。点一下循环 saver → balanced → performance。
// 实际动作交给 /usr/local/bin/nabu-power（三簇 governor 分开设）。
PluginComponent {
    id: root

    function tr(term) {
        return I18n.trFor("nabuPower", term);
    }

    readonly property var modes: ["saver", "balanced", "performance"]
    property string mode: "balanced"

    // 档位从 sysfs 反推（nabu-power current），不存状态文件，
    // 这样手动在命令行切过之后这里也能对上
    Process {
        id: queryProc
        command: ["nabu-power", "current"]
        stdout: SplitParser {
            onRead: line => {
                const v = line.trim();
                if (root.modes.indexOf(v) >= 0)
                    root.mode = v;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: queryProc.running = true
    }

    Process {
        id: applyProc
        command: []
        onExited: queryProc.running = true
    }

    function cycle() {
        const i = root.modes.indexOf(root.mode);
        const next = root.modes[(i + 1) % root.modes.length];
        root.mode = next;                       // 立刻反馈，不用等进程回来
        applyProc.command = ["nabu-power", next];
        applyProc.running = true;
    }

    Component.onCompleted: queryProc.running = true

    readonly property string modeLabel: {
        switch (mode) {
        case "saver":
            return tr("Saver");
        case "performance":
            return tr("Performance");
        default:
            return tr("Balanced");
        }
    }

    // ================= 控制中心 =================
    ccWidgetIcon: {
        switch (mode) {
        case "saver":
            return "battery_saver";
        case "performance":
            return "bolt";
        default:
            return "balance";
        }
    }
    ccWidgetPrimaryText: tr("Power mode")
    ccWidgetSecondaryText: modeLabel
    // 电源模式永远有一个生效值（不存在"关掉"这个状态），所以磁贴常亮；
    // 当前是哪一档看副标题和图标，不靠高亮与否区分
    ccWidgetIsActive: true

    onCcWidgetToggled: root.cycle()

    // ================= 栏内图标 =================
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS
            DCommon.DIcon {
                name: mode === "saver" ? "battery_saver" : (mode === "performance" ? "bolt" : "balance")
                size: Theme.iconSize
                color: mode === "performance" ? Theme.primary : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        DCommon.DIcon {
            name: mode === "saver" ? "battery_saver" : (mode === "performance" ? "bolt" : "balance")
            size: Theme.iconSize
            color: mode === "performance" ? Theme.primary : Theme.surfaceVariantText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
