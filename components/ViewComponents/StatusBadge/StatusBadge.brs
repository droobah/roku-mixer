Sub Init()
    m.wrapperRectangle = m.top.findNode("WrapperRectangle")
    m.contentGroup = m.top.findNode("ContentGroup")
    m.textLabel = m.top.findNode("TextLabel")

    m.height = 44
    m.compactHeight = 32
    m.padding = 22
    m.compactPadding = 11
    m.iconSize = 22
    m.compactIconSize = 16
    m.iconTextPadding = 5
    m.compactIconTextPadding = 5
    m.textSize = 24
    m.compactTextSize = 20

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
        end if
    else
        if m.iconPoster = invalid
            m.iconPoster = CreateObject("roSGNode", "Poster")
            m.iconPoster.uri = icon
            m.contentGroup.insertChild(m.iconPoster, 0)
        else
            if m.iconPoster.uri <> icon
                m.iconPoster.uri = icon
            end if
        end if
    end if

    LayoutAdjust()
End Sub

Sub OnColorChange(event as Object)
    color = event.getData()

    m.textLabel.color = color
    if m.iconPoster <> invalid
        m.iconPoster.blendColor = color
    end if
End Sub

Sub OnCompactChange(event as Object)
    LayoutAdjust()
End Sub

Sub LayoutAdjust()
    if m.top.compact
        m.wrapperRectangle.height = m.compactHeight
        m.contentGroup.translation = [m.compactPadding, 0]
        m.textLabel.fontSize = m.compactTextSize
        m.textLabel.translation = [0, m.compactHeight / 2 + 2]

        if m.iconPoster <> invalid
            m.iconPoster.width = m.compactIconSize
            m.iconPoster.height = m.compactIconSize
            m.iconPoster.translation = [0, (m.compactHeight - m.compactIconSize) / 2]
            m.textLabel.translation = [m.compactIconSize + m.compactIconTextPadding, m.compactHeight / 2 + 2]
        end if

        m.wrapperRectangle.width = m.contentGroup.boundingRect().width + m.compactPadding * 2
    else
        m.wrapperRectangle.height = m.height
        m.contentGroup.translation = [m.padding, 0]
        m.textLabel.fontSize = m.textSize
        m.textLabel.translation = [0, m.height / 2 + 2]

        if m.iconPoster <> invalid
            m.iconPoster.width = m.iconSize
            m.iconPoster.height = m.iconSize
            m.iconPoster.translation = [0, (m.height - m.iconSize) / 2]
            m.textLabel.translation = [m.iconSize + m.iconTextPadding, m.height / 2 + 2]
        end if

        m.wrapperRectangle.width = m.contentGroup.boundingRect().width + m.padding * 2
    end if
End Sub