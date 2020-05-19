Sub Init()
    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.titleLabel = m.top.findNode("TitleLabel")
    m.badgeLayoutGroup = m.top.findNode("BadgeLayoutGroup")
    m.viewerCountBadge = m.top.findNode("ViewerCountBadge")

    m.top.observeField("width", "WidthChanged")
    m.top.observeField("itemContent", "ContentChanged")
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    scaledWidth = doScale(width, m.global.scaleFactor)
    m.thumbnailRoundedMaskGroup.maskSize = [scaledWidth, scaledWidth]
    m.thumbnailPoster.width = width
    m.thumbnailPoster.height = width
    m.titleLabel.width = width - 20 - 20
    m.badgeLayoutGroup.translation = [width - 20, 20]
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    if content.coverUrl = invalid or content.coverUrl = ""
        m.thumbnailPoster.uri = "pkg:/images/default_game.png"
    else
        m.thumbnailPoster.uri = content.coverUrl
    end if

    if content.viewersCurrent <> invalid
        m.viewerCountBadge.text = content.viewersCurrent.ToStr()
    else
        m.viewerCountBadge.text = ""
    end if


    m.titleLabel.text = content.name
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
  if scaleFactor = 0 or number = 0
    return number
  end if

  scaledValue = number - number / scaleFactor
  return scaledValue
End Function