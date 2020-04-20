Sub Init()
    ? "[LivePlayer] Init()"

    m.videoNode = m.top.findNode("VideoNode")

    m.videoContent = CreateObject("roSGNode", "ContentNode")
    m.videoContent.forwardQueryStringParams = false
    m.videoContent.streamFormat = "hls"

    m.top.observeField("channelId", "ChannelIdSet")
    m.videoNode.observeField("state", "OnVideoStateChange")
End Sub

Sub ChannelIdSet(event as Object)
    m.top.unobserveField("channelId")
    channelId = event.getData()

    m.videoContent.url = "https://mixer.com/api/v1/channels/" + channelId.ToStr() + "/manifest.m3u8"
    m.videoNode.content = m.videoContent
    m.videoNode.setFocus(true)
    m.videoNode.control = "play"

    ? m.videoContent.url
End Sub

Sub OnVideoStateChange(event as Object)
    state = event.getData()

    if state = "stopped" or state = "finished" or state = "error"
        DestroyPlayer()
    end if
End Sub

Sub DestroyPlayer()
  ? "Destroying player!"
  m.top.visible = false
End Sub

Function onKeyEvent(key as String, press as Boolean) as Boolean
    ? ">>> LivePlayer >> OnkeyEvent"

    if not press then return true

    if key = "back"
        DestroyPlayer()
    end if

    return true
End Function