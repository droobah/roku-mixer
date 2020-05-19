Sub Init()
    ' ? "[ChannelsMarkupGridItemLive] Init()"

    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.avatarPoster = m.top.findNode("AvatarPoster")
    m.usernameLabel = m.top.findNode("UsernameLabel")
    m.gameLabel = m.top.findNode("GameLabel")
    m.badgeLayoutGroup = m.top.findNode("BadgeLayoutGroup")
    m.viewerCountBadge = m.top.findNode("ViewerCountBadge")
    m.avatarRoundedMaskGroup = m.top.findNode("AvatarRoundedMaskGroup")
    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.gradient = m.top.findNode("Gradient")

    ' correctly set rounded maskgroup for 720p UI devices
    maskSize = doScale(60, m.global.scaleFactor)
    m.avatarRoundedMaskGroup.maskSize = [maskSize, maskSize]
    
    m.top.observeField("width", "WidthChanged")
    m.top.observeField("height", "HeightChanged")
    m.top.observeField("itemContent", "ContentChanged")
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.thumbnailRoundedMaskGroup.maskSize = [doScale(width, m.global.scaleFactor), m.thumbnailRoundedMaskGroup.maskSize[1]]
    m.thumbnailPoster.width = width
    m.gradient.width = width
    m.badgeLayoutGroup.translation = [width - 20, 20]
    ' set width with padding
    m.usernameLabel.width = width - 70 - 20 - 20
    m.gameLabel.width = width - 70 - 20 - 20
End Sub

Sub HeightChanged(event as Object)
    height = event.getData()

    m.thumbnailPoster.height = height
    m.thumbnailRoundedMaskGroup.maskSize = [m.thumbnailRoundedMaskGroup.maskSize[0], doScale(height, m.global.scaleFactor)]
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    m.usernameLabel.text = content.token
    m.thumbnailPoster.uri = content.streamThumbnailSmall

    if content.viewersCurrent <> invalid
        m.viewerCountBadge.text = content.viewersCurrent.ToStr()
    else
        m.viewerCountBadge.text = ""
    end if

    if content.type <> invalid
        m.gameLabel.text = content.type.name
        m.gameLabel.scale = [1, 1]
    else
        m.gameLabel.text = ""
        m.gameLabel.scale = [0, 0]
    end if

    m.avatarPoster.uri = "https://mixer.com/api/v1/users/" + content.userId.ToStr() + "/avatar?w=60&h=60"
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
    if scaleFactor = 0 or number = 0
        return number
    end if

    scaledValue = number - number / scaleFactor
    return scaledValue
End Function