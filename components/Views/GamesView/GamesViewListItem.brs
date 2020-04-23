Sub Init()
    m.top.opacity = 0.5

    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.titleLabel = m.top.findNode("TitleLabel")
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.thumbnailPoster.width = width
    m.thumbnailPoster.height = width
    m.titleLabel.width = width
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    if content.coverUrl = invalid or content.coverUrl = ""
        m.thumbnailPoster.uri = "pkg:/images/default_game.png"
    else
        m.thumbnailPoster.uri = content.coverUrl
    end if

    m.titleLabel.text = content.name
End Sub

Sub GridFocusChanged()
    if not m.top.gridHasFocus and m.top.focusPercent > 0.0
        m.top.opacity = 0.5
    end if
End Sub

Sub ItemFocusChanged(event as Object)
    hasFocus = event.getData()

    if hasFocus
        m.top.opacity = 1
    end if
End Sub

Sub ShowFocus(event as Object)
    if not m.top.gridHasFocus then return

    percent = event.getData()
    m.top.opacity = percent / 2 + 0.5
End Sub