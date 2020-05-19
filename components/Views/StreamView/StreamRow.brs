Sub Init()
    m.top.opacity = 0.6

    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.descriptionLabel = m.top.findNode("DescriptionLabel")
    m.badgeLayoutGroup = m.top.findNode("BadgeLayoutGroup")
    m.viewerCountBadge = m.top.findNode("ViewerCountBadge")
    m.statusBadge = m.top.findNode("StatusBadge")
    m.focusPoster = m.top.findNode("FocusPoster")

    WidthChanged(630)
    m.top.observeField("content", "ContentChanged")
    m.top.observeField("focusedChild", "OnFocusedChildChange")
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.top.opacity = 1
        m.focusPoster.visible = true
        m.descriptionLabel.repeatCount = -1
    else
        m.top.opacity = 0.6
        m.focusPoster.visible = false
        m.descriptionLabel.repeatCount = 0
    end if
End SUb

Sub WidthChanged(width)
    m.thumbnailPoster.width = width
    m.thumbnailPoster.height = width / 16 * 9
    m.focusPoster.width = width + 24
    m.focusPoster.height = width / 16 * 9 + 24

    m.thumbnailRoundedMaskGroup.maskSize = [doScale(width, m.global.scaleFactor), doScale(width / 16 * 9, m.global.scaleFactor)]
    m.descriptionLabel.maxWidth = width - 20 - 20
    m.badgeLayoutGroup.translation = [width - 20, 20]
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    if content.online = true
        m.descriptionLabel.text = content.name
        m.viewerCountBadge.text = content.viewersCurrent
        m.viewerCountBadge.visible = true
        m.thumbnailPoster.uri = content.streamThumbnailSmall
        m.statusBadge.text = "• LIVE"
        m.statusBadge.color = "0xF82727"
    else
        m.descriptionLabel.text = ""
        m.viewerCountBadge.text = "0"
        m.viewerCountBadge.visible = false
        m.thumbnailPoster.uri = "pkg:/images/default_stream.png"
        m.statusBadge.text = "OFFLINE"
        m.statusBadge.color = "0xEBEBEB"
    end if
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
    if scaleFactor = 0 or number = 0
        return number
    end if

    scaledValue = number - number / scaleFactor
    return scaledValue
End Function

Function onKeyEvent(key, press) as Boolean
    ? ">>> StreamRow >> OnkeyEvent"

    if not press then return false

    if key = "OK"
        m.top.selected = true
        return true
    end if

    return false
End Function
