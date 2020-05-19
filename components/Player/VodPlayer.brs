Sub Init()
    ? "[VodPlayer] Init()"

    m.videoNode = m.top.findNode("VideoNode")
    m.videoNode.enableTrickPlay = true

    m.videoContent = CreateObject("roSGNode", "ContentNode")
    m.videoContent.forwardQueryStringParams = false
    m.videoContent.streamFormat = "hls"
    m.videoContent.live = false

    m.top.observeField("uri", "UriSet")
    m.videoNode.observeField("state", "OnVideoStateChange")
End Sub

Sub UriSet(event as Object)
    m.top.unobserveField("uri")
    uri = event.getData()

    m.videoContent.url = uri
    m.videoNode.content = m.videoContent
    m.videoNode.setFocus(true)
    m.videoNode.control = "play"
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
    ? ">>> VodPlayer >> OnkeyEvent"

    if not press then return true

    if key = "back"
        DestroyPlayer()
    end if

    return true
End Function