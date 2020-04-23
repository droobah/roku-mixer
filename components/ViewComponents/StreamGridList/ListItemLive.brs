Sub Init()
    ' ? "[ListItemLive] Init()"

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

    if content.user <> invalid and content.user.avatarUrl <> invalid
        m.avatarPoster.uri = content.user.avatarUrl
    else
        m.avatarPoster.uri = "pkg:/images/default_avatar.png"
    end if
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
  if scaleFactor = 0 or number = 0
    return number
  end if

  scaledValue = number - number / scaleFactor
  return scaledValue
End Function