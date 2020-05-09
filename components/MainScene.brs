Sub Init()
    ? "[MainScene] Init()"

    m.top.backgroundColor = "0x212C3D"
    m.top.backgroundURI = ""

    ' #START TRACKER#
    m.tracker = m.top.createChild("TrackerTask")
    ' #END TRACKER#

    m.global.addField("uriFetcher", "node", false)
    m.global.addField("auth", "node", false)
    m.global.addField("route", "string", true)
    m.global.addField("routeWithExtra", "assocarray", true)
    m.global.addField("routeBack", "boolean", true)
    m.global.addField("currentRoute", "assocarray", true)
    m.global.addField("stopPlayer", "boolean", true)
    m.global.addFields({
        "scaleFactor": 0,
        "videoPlaying": false,
        "defaultPage": "",
        "client_id": "981b6ea733bf504e9916ffe74e24a9e242f68f0e57a138bf"
    })
    ReInitialize()
End Sub

Sub OnTokenReadFromMain(event as Object)
    token = event.getData()
    m.global.auth.user_id = token.user_id
    m.global.auth.access_token = token.access_token
    m.global.auth.refresh_token = token.refresh_token

    m.router = CreateObject("roSGNode", "Router")
    m.top.appendChild(m.router)
    m.sideBar = CreateObject("roSGNode", "SideBar")
    m.top.appendChild(m.sideBar)

    m.changeLog = {
        version: "1.0.4",
        lines: [
            "- Mixer account linking added (Login)",
            "- Following section now works"
        ]
    }
    ShowChangelog()

    if token.access_token <> ""
        FetchMyProfile()
    end if

    m.top.signalBeacon("AppLaunchComplete")
End Sub

Sub ReInitialize()
    m.auth = CreateObject("roSGNode", "Node")
    m.auth.addField("userProfile", "node", false)
    m.auth.addFields({
        "access_token": "",
        "refresh_token": "",
        "user_id": ""
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
        "routeWithExtra": {},
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
            m.sideBar.setFocus(true)
            return true
        end if
    else if key = "left"
        if m.router.isInFocusChain()
            m.sideBar.setFocus(true)
            return true
        end if
    else if key = "right"
        if m.sideBar.isInFocusChain()
            m.router.setFocus(true)
            return true
        end if
    end if
  
    return false
End Function