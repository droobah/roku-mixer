Sub Init()
    m.iconPoster = m.top.findNode("IconPoster")
    m.textLabel = m.top.findNode("TextLabel")

    m.isActiveCache = false
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    ' isActive field changed
    if content.isActive <> invalid and m.isActiveCache <> content.isActive
        if content.isActive
            m.iconPoster.blendColor = "0x00D1FF"
        else
            m.iconPoster.blendColor = "0xBDBDBD"
        end if
        m.isActiveCache = content.isActive
        return
    end if

    if content.itemIconUri <> invalid and content.itemText <> invalid and content.isActive <> invalid
        m.iconPoster.uri = content.itemIconUri
        m.textLabel.text = content.itemText
    end if

    m.isActiveCache = content.isActive
End Sub

Sub ListFocusChanged(event as Object)
    m.textLabel.visible = event.getData()
End Sub