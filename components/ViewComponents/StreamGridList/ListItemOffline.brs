Sub Init()
    ' ? "[ListItemOffline] Init()"
End Sub

Sub WidthChanged(event as Object)
End Sub

Sub HeightChanged(event as Object)
End Sub

Sub ContentChanged(event as Object)
    m.top.findNode("Username").text = "Offline " + event.getData().token
End Sub