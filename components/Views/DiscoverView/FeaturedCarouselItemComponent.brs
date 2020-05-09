Sub Init()
    m.previewPoster = m.top.findNode("PreviewPoster")
    m.focusIndicatorPoster = m.top.findNode("FocusIndicatorPoster")

    m.top.observeField("itemContent", "OnContentChange")
    m.top.observeField("itemHasFocus", "OnItemFocusChange")
    m.top.observeField("currRect", "OnRectangleChange")
End Sub

Sub OnRectangleChange(event as Object)
    rect = event.getData()

    m.previewPoster.width = rect.width
    m.previewPoster.height = rect.height

    m.focusIndicatorPoster.width = rect.width + 24
    m.focusIndicatorPoster.height = rect.height + 24
    m.focusIndicatorPoster.translation = [-12, -12]
End Sub

Sub OnItemFocusChange(event as Object)
    if event.getData() = true
        m.focusIndicatorPoster.visible = true
    else
        m.focusIndicatorPoster.visible = false
    end if
    ' if m.top.itemContent <> invalid
    '     if event.getData() = true
    '         m.previewPoster.uri = m.top.itemContent.streamThumbnailLarge
    '     else
    '         m.previewPoster.uri = m.top.itemContent.streamThumbnailSmall
    '     end if
    ' end if
End Sub

Sub OnContentChange(event as Object)
    content = event.getData()

    m.previewPoster.uri = content.streamThumbnailSmall
End Sub