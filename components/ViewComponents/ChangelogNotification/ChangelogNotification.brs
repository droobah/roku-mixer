Sub Init()
    ? "[ChangelogNotification] Init()"

    m.width = 400
    m.margin = 30
    m.padding = 18

    m.backgroundRectangle = m.top.findNode("BackgroundRectangle")
    m.hideCountdownBarRectangle = m.top.findNode("HideCountdownBarRectangle")
    m.countdownBarAnimation = m.top.findNode("CountdownBarAnimation")
    m.countdownBarAnimationInterpolator = m.top.findNode("CountdownBarAnimationInterpolator")
    m.notificationHideTimer = m.top.findNode("NotificationHideTimer")
    m.contentContainer = m.top.findNode("ContentContainer")
    m.titleLabel = m.top.findNode("TitleLabel")
    m.linesLabel = m.top.findNode("LinesLabel")

    m.backgroundRectangle.width = m.width
    m.linesLabel.width = m.width - m.padding - m.padding
    m.hideCountdownBarRectangle.width = m.width
    m.countdownBarAnimationInterpolator.keyValue = [m.width, 0.0]
    m.notificationHideTimer.observeField("fire", "HideNotification")
End Sub

Sub OnContentSet(event as Object)
    m.top.unobserveField("content")
    content = event.getData()

    m.titleLabel.text = "New in version " + content.version
    linesText = ""
    for each line in content.lines
        linesText += line + chr(10)
    end for
    m.linesLabel.text = linesText

    m.backgroundRectangle.height = m.padding + m.contentContainer.boundingRect().height + m.hideCountdownBarRectangle.height + m.padding

    m.contentContainer.translation = [m.padding, m.padding]

    location = m.top.location
    if location = "top_left"
        m.backgroundRectangle.translation = [m.margin, m.margin]
    else if location = "top_right"
        m.backgroundRectangle.translation = [1920 - m.margin - m.width, m.margin]
    else if location = "bottom_left"
        m.backgroundRectangle.translation = [m.margin, 1080 - m.margin - m.backgroundRectangle.height]
    else if location = "bottom_right"
        m.backgroundRectangle.translation = [1920 - m.margin - m.width, 1080 - m.margin - m.backgroundRectangle.height]
    end if

    m.hideCountdownBarRectangle.translation = [0, m.backgroundRectangle.height - m.hideCountdownBarRectangle.height]

    m.countdownBarAnimation.control = "start"
    m.notificationHideTimer.control = "start"
End Sub

Sub HideNotification()
    m.top.visible = false
End Sub