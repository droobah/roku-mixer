Sub Init()
    ' ? "[ChannelItemOffline] Init()"
    m.top.opacity = 0.5

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