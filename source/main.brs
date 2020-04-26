Sub RunUserInterface(args as Dynamic)
    ShowMainScreen(args)
End Sub

Sub ShowMainScreen(args as Dynamic)
    ? "[main] ShowMainScreen()"
    screen = CreateObject("roSGScreen")
    input = CreateObject("roInput")

    port = CreateObject("roMessagePort")

    scene = screen.CreateScene("MainScene")
    scene.token = GetTokenFromRegistry()
    screen.setMessagePort(port)
    input.setMessagePort(port)

    m.global = screen.getGlobalNode()
    ? "args= "; formatjson(args)      'pretty print AA'
    deeplink = getDeepLinks(args)
    ? "deeplink= "; deeplink
    m.global.addField("deeplink", "assocarray", true)
    m.global.deeplink = deeplink

    screen.show()

    while (true)
        msg = wait(0, port)
        msgType = type(msg)
        ? "------------------"
        ? "msg = "; msg

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roInputEvent" and msg.isInput()
            m.global.deeplink = getDeepLinks(msg.getInfo())
        end if
    end while
End Sub

Function getDeepLinks(args) as Object
    deeplink = invalid

    if args.contentid <> invalid and args.mediaType <> invalid
        deeplink = {
            mediaId: args.contentId
            mediaType: args.mediaType
        }
    end if

    return deeplink
end Function

Function GetTokenFromRegistry() As Object
    sec = CreateObject("roRegistrySection", "Authentication")
    'sec.Delete("access_token")
    'sec.Delete("refresh_token")
    access_token = ""
    refresh_token = ""
    user_id = ""
    if sec.Exists("access_token") and sec.Exists("refresh_token") then
        ? "main.brs "; sec.Read("access_token"); " "; sec.Read("refresh_token")
        access_token = sec.Read("access_token")
        refresh_token = sec.Read("refresh_token")
        if sec.Exists("user_id")
            user_id = sec.Read("user_id")
        end if
    end if
    return {
        access_token: access_token,
        refresh_token: refresh_token,
        user_id: user_id
    }
End Function