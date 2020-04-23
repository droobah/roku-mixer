Sub Init()
    ' ? "[ChannelItemLive] Init()"
    m.top.opacity = 0.5

    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.titleLabel = m.top.findNode("TitleLabel")
    m.avatarPoster = m.top.findNode("AvatarPoster")
    m.usernameLabel = m.top.findNode("UsernameLabel")
    m.gameLabel = m.top.findNode("GameLabel")
    m.viewerCountWrapperRectangle = m.top.findNode("ViewerCountWrapperRectangle")
    m.viewerCountLabel = m.top.findNode("ViewerCountLabel")
    m.roundedMaskGroup = m.top.findNode("RoundedMaskGroup")

    ' correctly set rounded maskgroup for 720p UI devices
    maskSize = doScale(60, m.global.scaleFactor)
    m.roundedMaskGroup.maskSize = [maskSize, maskSize]
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.thumbnailPoster.width = width
    m.thumbnailPoster.height = width / 16 * 9
    m.titleLabel.width = width
    m.usernameLabel.width = width - 60 - 12
    m.usernameLabel.width = width - 60 - 12
End Sub

Sub HeightChanged(event as Object)
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    m.usernameLabel.text = content.token
    m.titleLabel.text = content.name

    m.thumbnailPoster.uri = content.streamThumbnailSmall

    if content.viewersCurrent <> invalid
        m.viewerCountLabel.text = "• " + content.viewersCurrent.ToStr()
        m.viewerCountWrapperRectangle.width = m.viewerCountLabel.boundingRect().width + 12
    else
        m.viewerCountLabel.text = ""
    end if

    if content.type <> invalid
        m.gameLabel.text = content.type.name
    else
        m.gameLabel.text = ""
    end if

    if content.user = invalid or content.user.avatarUrl = invalid or content.user.avatarUrl = ""
        m.avatarPoster.uri = "pkg:/images/default_avatar.png"
    else
        m.avatarPoster.uri = content.user.avatarUrl
    end if
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

Function doScale(number as Integer, scaleFactor as Integer) as Integer
  if scaleFactor = 0 or number = 0
    return number
  end if

  scaledValue = number - number / scaleFactor
  return scaledValue
End Function