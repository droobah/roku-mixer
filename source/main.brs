Sub RunUserInterface(args as Dynamic)
  ShowMainScreen(args)
End Sub

Sub ShowMainScreen(args as Dynamic)
  ? "[main] ShowMainScreen()"
  screen = CreateObject("roSGScreen")
  port = CreateObject("roMessagePort")

  scene = screen.CreateScene("MainScene")
  screen.setMessagePort(port)

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
