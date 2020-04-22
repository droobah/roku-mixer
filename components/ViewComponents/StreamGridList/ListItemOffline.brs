Sub Init()
    ' ? "[ListItemOffline] Init()"

    m.backgroundRectangle = m.top.findNode("BackgroundRectangle")
    m.avatarPoster = m.top.findNode("AvatarPoster")
    m.usernameLabel = m.top.findNode("UsernameLabel")
    m.roundedMaskGroup = m.top.findNode("RoundedMaskGroup")

    ' correctly set rounded maskgroup for 720p UI devices
    maskSize = doScale(160, m.global.scaleFactor)
    m.roundedMaskGroup.maskSize = [maskSize, maskSize]
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.backgroundRectangle.width = width
    m.backgroundRectangle.height = width / 16 * 9
    m.roundedMaskGroup.translation = [width / 2 - m.avatarPoster.width / 2, (width / 16 * 9) / 2 - m.avatarPoster.height / 2]
    m.usernameLabel.width = width
End Sub

Sub HeightChanged(event as Object)
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    m.usernameLabel.text = content.token
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