Sub Init()
    m.backgroundPoster = m.top.findNode("BackgroundPoster")
    m.titleLabel = m.top.findNode("TitleLabel")

    m.top.observeField("width", "OnWidthSet")
    m.top.observeField("height", "OnHeightSet")
End Sub

Sub OnWidthSet(event as Object)
    width = event.getData()

    m.backgroundPoster.width = width
    m.titleLabel.translation = [width / 2, m.titleLabel.translation[1]]
End Sub

Sub OnHeightSet(event as Object)
    height = event.getData()

    m.backgroundPoster.height = height
    m.titleLabel.translation = [m.titleLabel.translation[0], height / 2]
End Sub