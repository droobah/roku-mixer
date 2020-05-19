Sub PlayLiveStream(channelId as Integer)
    m._player = CreateObject("roSGNode", "LivePlayer")
    m._player.observeField("visible", "_OnPlayerVisibilityChange")
    m._player.translation = [0 - m.top.translation[0], 0 - m.top.translation[1]]
    m.top.appendChild(m._player)
    m._player.setFocus(true)
    m._player.channelId = channelId
End Sub

Sub PlayVod(uri as String)
    m._player = CreateObject("roSGNode", "VodPlayer")
    m._player.observeField("visible", "_OnPlayerVisibilityChange")
    m._player.translation = [0 - m.top.translation[0], 0 - m.top.translation[1]]
    m.top.appendChild(m._player)
    m._player.setFocus(true)
    m._player.uri = uri
End Sub

Sub _OnPlayerVisibilityChange(event as Object)
    isVisible = event.getData()

    if isVisible = false
        m.top.removeChild(m._player)
        m._player = invalid
        OnPlayerDestroyed()
    end if
End Sub

Sub OnPlayerDestroyed()
End Sub