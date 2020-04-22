Sub Init()
  ? "[MainScene] Init()"
  ' #START TRACKER#
  m.tracker = m.top.createChild("TrackerTask")
  ' #END TRACKER#

  m.top.backgroundURI = ""

  m.global.addField("uriFetcher", "node", false)
  m.global.addField("auth", "node", false)
  m.global.addField("route", "string", true)
  m.global.addField("routeBack", "boolean", true)
  m.global.addField("currentRoute", "assocarray", true)
  m.global.addField("stopPlayer", "boolean", true)
  m.global.addFields({
    "scaleFactor": 0,
    "videoPlaying": false,
    "defaultPage": ""
  })
  ReInitialize()

  m.router = CreateObject("roSGNode", "Router")
  m.top.appendChild(m.router)
  m.navBar = CreateObject("roSGNode", "NavBar")
  m.top.insertChild(m.navBar, 0)

  m.changeLog = {
    version: "",
    lines: []
  }
  ShowChangelog()

  m.top.signalBeacon("AppLaunchComplete")
End Sub

Sub ReInitialize()
  m.auth = CreateObject("roSGNode", "Node")
  m.auth.addFields({
    "user": invalid,
    "token": invalid,
    "refresh_token": invalid
  })

  di = CreateObject("roDeviceInfo")
  displaySize = di.GetDisplaySize()

  scaleFactor = 0
  if displaySize.w <> 1920
    scaleFactor = 1920 / (1920 - displaySize.w)
    scaleFactor = Abs(scaleFactor)
  end if

  m.uriFetcher = CreateObject("roSGNode", "UriFetcher")
  m.global.setFields({
    "uriFetcher": m.uriFetcher,
    "auth": m.auth,
    "route": "",
    "routeBack": false,
    "currentRoute": {},
    "scaleFactor": scaleFactor,
    "stopPlayer": false,
    "videoPlaying": false,
    "defaultPage": ""
  })
End Sub

Sub ShowChangelog()
  if m.changeLog = invalid then return

  actions = [
    {
      name: "getmanifestversion"
    },
    {
      name: "readregistry",
      data: {
        registry: "AppData",
        key: "lastshownchangelogversion"
      }
    }
  ]
  StartMultiPurposeTask(actions, "OnChangelogMultiPurposeTaskResponse")
End Sub

Sub OnChangelogMultiPurposeTaskResponse(event as Object)
  response = event.getData()

  version = response[0]
  lastShownChangelogVersion = response[1]

  ' only show changelog once for a version
  if lastShownChangelogVersion = invalid or lastShownChangelogVersion <> version
    m.changelogNotification = CreateObject("roSGNode", "ChangelogNotification")
    m.changelogNotification.content = m.changeLog
    m.top.appendChild(m.changelogNotification)
    StartMultiPurposeTask([{
      name: "writeregistry",
      data: {
        registry: "AppData",
        key: "lastshownchangelogversion",
        value: version
      }
    }])
  end if
End Sub

Function onKeyEvent(key, press) as Boolean
  ? ">>> MainScene >> OnkeyEvent"

  if not press then return false

  if key = "back"
    if m.router.isInFocusChain()
      m.navBar.setFocus(true)
      return true
    end if
  else if key = "up"
    if m.router.isInFocusChain()
      m.navBar.setFocus(true)
      return true
    end if
  else if key = "down"
    if m.navBar.isInFocusChain()
      m.router.setFocus(true)
      return true
    end if
  end if
  
  return false
End Function