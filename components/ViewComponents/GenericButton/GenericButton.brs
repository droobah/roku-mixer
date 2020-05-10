Sub Init()
    m.top.opacity = 0.5

    m.backgroundRectangle = m.top.findNode("BackgroundRectangle")
    m.textContainer = m.top.findNode("TextContainer")
    m.label = m.top.findNode("Label")
    m.loadingIndicator = m.top.findNode("LoadingIndicator")
    m.loadingIndicatorAnimation = m.top.findNode("LoadingIndicatorAnimation")

    m.iconPosterComponent = invalid

    m.top.observeField("data", "OnDataChange")
    m.top.observeField("processing", "OnProcessingChange")
    m.top.observeField("width", "OnWidthChange")
    m.top.observeField("height", "OnHeightChange")
    m.top.observeField("focusedChild", "OnFocusedChildChange")
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.top.opacity = 1.0
    else
        m.top.opacity = 0.5
    end if
End Sub

Sub OnWidthChange()
    AdjustWidth()
End Sub

Sub OnHeightChange(event as Object)
    height = event.getData()

    m.backgroundRectangle.height = height
    m.label.translation = [m.label.translation[0], height / 2 - m.label.boundingRect().height / 2]
    ' m.textContainer.translation = [m.textContainer.translation[0], height / 2]

    if m.iconPosterComponent <> invalid
        m.iconPosterComponent.translation = [0, height / 2 - m.iconPosterComponent.height / 2]
    end if
End Sub

Sub AdjustWidth()
    width = 0
    ' dynamic width
    if m.top.width = -1
        width = m.textContainer.boundingRect().width + 90
    else
        width = m.top.width
    end if

    m.backgroundRectangle.width = width
    m.loadingIndicator.translation = [(width - m.loadingIndicator.width) / 2, m.loadingIndicator.translation[1]]
End Sub

Sub OnDataChange(event as Object)
    data = event.getData()

    m.label.text = data.text

    icon = ""
    iconSize = 30
    if data.icon <> invalid
        icon = data.icon
    end if
    if data.iconSize <> invalid
        iconSize = data.iconSize
    end if
    UpdateIcon(icon, iconSize)

    translationX = 45
    alignment = m.top.alignment
    if data.alignment <> invalid
        alignment = data.alignment
    end if

    if alignment = "center"
        m.textContainer.horizAlignment = "center"
        translationX = m.top.width / 2
    else if alignment = "right"
        m.textContainer.horizAlignment = "center"
        translationX = m.top.width - 45
    end if
    m.textContainer.translation = [translationX, m.textContainer.translation[1]]

    AdjustWidth()
End Sub

Sub UpdateIcon(icon as String, iconSize as Float)
    if m.iconPosterComponent <> invalid
        ' icon exists. update or remove the icon
        if icon = ""
            m.textContainer.removeChild(m.iconPosterComponent)
            m.iconPosterComponent = invalid
        else
            m.iconPosterComponent.uri = icon
        end if
    else
        if icon <> ""
            m.iconPosterComponent = CreateObject("roSGNode", "Poster")
            m.iconPosterComponent.width = iconSize
            m.iconPosterComponent.height = iconSize
            m.iconPosterComponent.uri = icon
            m.iconPosterComponent.translation = [0, m.top.height / 2 - iconSize / 2]
            m.label.translation = [m.label.translation[0], m.label.translation[1] + 2]
            m.textContainer.insertChild(m.iconPosterComponent, 0)
        end if
    end if
End Sub

Sub OnProcessingChange(event as Object)
    if event.getData() = true
        m.textContainer.visible = false
        m.loadingIndicator.visible = true
        m.loadingIndicatorAnimation.control = "start"
    else
        m.textContainer.visible = true
        m.loadingIndicator.visible = false
        m.loadingIndicatorAnimation.control = "stop"
    end if
End Sub

Function onKeyEvent(key as String, press as Boolean) as Boolean
    if m.top.noClickHandler then return false

    ? ">>> Button >> OnkeyEvent"

    ' Handle only key up event
    if not press then return false

    if key = "OK" and m.top.hasFocus()
        m.top.isSelected = true
        return true
    end if

    return false

End Function