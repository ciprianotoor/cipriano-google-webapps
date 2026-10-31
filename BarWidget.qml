import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "cipriano.google-webapps"
  implicitWidth: button.implicitWidth
  implicitHeight: barSize
  property bool menuOpen: false
  property var apps: []
  readonly property string helperPath: String(Qt.resolvedUrl("detect-webapps.py")).replace("file://", "")

  function refreshApps() { if (!detector.running) detector.running = true }
  function launch(app) {
    // Launch through UWSM so Chromium inherits the active Wayland session.
    Quickshell.execDetached(["uwsm-app", "--"].concat(app.command))
    menuOpen = false
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: "Webapps de Chromium"
    iconComponent: Component {
      Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("chrome-color.svg")
        fillMode: Image.PreserveAspectFit
        smooth: true
      }
    }
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) {
        root.menuOpen = !root.menuOpen
        if (root.menuOpen) root.refreshApps()
      }
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.menuOpen
    contentWidth: popup.fittedContentWidth(Style.space(260))
    contentHeight: popup.fittedContentHeight(content.implicitHeight)

    Column {
      id: content
      width: parent.width
      spacing: Style.space(4)

      Repeater {
        model: root.apps
        delegate: Rectangle {
          required property var modelData
          width: content.width
          height: Style.space(44)
          radius: Style.space(2)
          color: hover.containsMouse ? Qt.alpha(root.bar.foreground, 0.12) : "transparent"

          Image {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(28)
            height: width
            fillMode: Image.PreserveAspectFit
            source: Quickshell.iconPath(modelData.icon, true)
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(48)
            anchors.verticalCenter: parent.verticalCenter
            text: modelData.name
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
          }

          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.launch(modelData)
          }
        }
      }

      Text {
        visible: root.apps.length === 0
        text: "No hay webapps detectadas"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        padding: Style.space(8)
      }
    }
  }

  Process {
    id: detector
    command: ["python3", root.helperPath]
    stdout: StdioCollector { id: output; waitForEnd: true }
    onExited: function(code) {
      if (code !== 0) return
      try {
        var value = JSON.parse(output.text)
        if (Array.isArray(value)) root.apps = value
      } catch (error) {}
    }
  }

  Component.onCompleted: root.refreshApps()
}
