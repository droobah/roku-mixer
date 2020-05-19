Sub Init()
    ' ? "[ChannelsMarkupGridItemOffline] Init()"

    m.backgroundPoster = m.top.findNode("BackgroundPoster")
    m.avatarPoster = m.top.findNode("AvatarPoster")
    m.usernameLabel = m.top.findNode("UsernameLabel")
    m.gameLabel = m.top.findNode("GameLabel")
    m.roundedMaskGroup = m.top.findNode("RoundedMaskGroup")
    m.statusBadge = m.top.findNode("StatusBadge")

    ' correctly set rounded maskgroup for 720p UI devices
    maskSize = doScale(160, m.global.scaleFactor)
    m.roundedMaskGroup.maskSize = [maskSize, maskSize]

    m.top.observeField("width", "WidthChanged")
    m.top.observeField("height", "HeightChanged")
    m.top.observeField("itemContent", "ContentChanged")
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.backgroundPoster.width = width
    m.backgroundPoster.height = width / 16 * 9
    m.roundedMaskGroup.translation = [width / 2 - m.avatarPoster.width / 2, (width / 16 * 9) / 2 - m.avatarPoster.height / 2]
    m.usernameLabel.width = width - 20 - 20
    m.gameLabel.width = width - 20 - 20
    m.statusBadge.translation = [width - m.statusBadge.boundingRect().width - 20, 20]
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

    if content.type <> invalid
        m.gameLabel.text = "Last online with: " + content.type.name
    else
        m.gameLabel.text = ""
    end if
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
  if scaleFactor = 0 or number = 0
    return number
  end if

  scaledValue = number - number / scaleFactor
  return scaledValue
End Function