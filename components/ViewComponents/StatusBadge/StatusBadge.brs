Sub Init()
    m.wrapperRectangle = m.top.findNode("WrapperRectangle")
    m.contentGroup = m.top.findNode("ContentGroup")
    m.textLabel = m.top.findNode("TextLabel")

    m.iconPoster = invalid
End Sub

Sub OnTextChange(event as Object)
    text = event.getData()

    if text <> "" and m.textLabel.text <> text
        m.textLabel.text = text
        LayoutAdjust()
    end if
End Sub

Sub OnIconChange(event as Object)
    icon = event.getData()

    if icon = ""
        if m.iconPoster <> invalid
            m.contentGroup.removeChild(m.iconPoster)
            m.iconPoster = invalid
            m.textLabel.translation = [0, m.textLabel.translation[1]]
            LayoutAdjust()
        end if
    else
        if m.iconPoster = invalid
            m.iconPoster = CreateObject("roSGNode", "Poster")
            m.iconPoster.uri = icon
            m.iconPoster.width = 22
            m.iconPoster.height = 22
            m.iconPoster.translation = [0, 11]
            m.contentGroup.insertChild(m.iconPoster, 0)
            m.textLabel.translation = [22 + 5, m.textLabel.translation[1]]
            LayoutAdjust()
        else
            if m.iconPoster.uri <> icon
                m.iconPoster.uri = icon
            end if
        end if
    end if
End Sub

Sub OnColorChange(event as Object)
    color = event.getData()

    m.textLabel.color = color
    if m.iconPoster <> invalid
        m.iconPoster.blendColor = color
    end if
End Sub

Sub LayoutAdjust()
    m.wrapperRectangle.width = m.contentGroup.boundingRect().width + 44
End Sub