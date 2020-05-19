Sub Init()
    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.gradient = m.top.findNode("Gradient")
    m.usernameLabel = m.top.findNode("UsernameLabel")

    m.top.observeField("width", "WidthChanged")
    m.top.observeField("height", "HeightChanged")
    m.top.observeField("itemContent", "ContentChanged")
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.thumbnailRoundedMaskGroup.maskSize = [doScale(width, m.global.scaleFactor), m.thumbnailRoundedMaskGroup.maskSize[1]]
    m.thumbnailPoster.width = width
    m.gradient.width = width
    m.usernameLabel.width = width - 20 - 20
End Sub

Sub HeightChanged(event as Object)
    height = event.getData()

    m.thumbnailRoundedMaskGroup.maskSize = [m.thumbnailRoundedMaskGroup.maskSize[0], doScale(height, m.global.scaleFactor)]
    m.thumbnailPoster.height = height
    m.gradient.translation = [0, height - m.gradient.height]
    m.usernameLabel.translation = [m.usernameLabel.translation[0], height - m.usernameLabel.boundingRect().height - 20]
End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    if content.bannerUrl = invalid or content.bannerUrl = ""
        m.thumbnailPoster.uri = ""
    else
        m.thumbnailPoster.uri = content.bannerUrl
    end if

    m.usernameLabel.text = content.token
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
  if scaleFactor = 0 or number = 0
    return number
  end if

  scaledValue = number - number / scaleFactor
  return scaledValue
End Function