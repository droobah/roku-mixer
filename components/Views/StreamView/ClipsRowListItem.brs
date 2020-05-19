Sub Init()
    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.thumbnailPoster = m.top.findNode("ThumbnailPoster")
    m.descriptionLabel = m.top.findNode("DescriptionLabel")
    m.streamedDateLabel = m.top.findNode("StreamedDateLabel")
    m.badgeLayoutGroup = m.top.findNode("BadgeLayoutGroup")
    m.viewerCountBadge = m.top.findNode("ViewerCountBadge")
    m.runtimeBadge = m.top.findNode("RuntimeBadge")

    m.top.observeField("width", "WidthChanged")
    m.top.observeField("height", "HeightChanged")
    m.top.observeField("itemContent", "ContentChanged")
End Sub

Sub _OnItemHasFocusChanged(itemHasFocus)
    if itemHasFocus
        m.descriptionLabel.repeatCount = 2
    else
        m.descriptionLabel.repeatCount = 0
    end if
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.thumbnailPoster.width = width
    m.thumbnailPoster.height = width / 16 * 9

    m.thumbnailRoundedMaskGroup.maskSize = [doScale(width, m.global.scaleFactor), doScale(width / 16 * 9, m.global.scaleFactor)]
    m.descriptionLabel.maxWidth = width - 20 - 20
    m.badgeLayoutGroup.translation = [width - 20, 20]
End Sub

Sub HeightChanged(event as Object)

End Sub

Sub ContentChanged(event as Object)
    content = event.getData()

    m.descriptionLabel.text = content.title
    m.viewerCountBadge.text = content.viewCount
    m.runtimeBadge.text = FormatTime(content.durationInSeconds)
    m.streamedDateLabel.text = "Clipped on " + DatetimeFormatter(content.uploadDate)

    for each locator in content.contentLocators
        if locator.locatorType = "Thumbnail_Small"
            m.thumbnailPoster.uri = locator.uri
        end if
    end for
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
    if scaleFactor = 0 or number = 0
        return number
    end if

    scaledValue = number - number / scaleFactor
    return scaledValue
End Function

Function FormatTime(seconds as Integer) as String
    if seconds <= 0 then return "0h 0m 0s"

    h = Int(seconds / 3600)
    m = Int((seconds mod 3600) / 60)
    s = Int(seconds mod 3600 mod 60)

    return Substitute("{0}h {1}m {2}s", h.ToStr(), m.ToStr(), s.ToStr())
End Function

Function DatetimeFormatter(dts as String) as String
    if dts = "" then return dts

    dt = CreateObject("roDateTime")
    dt.FromISO8601String(dts)
    dt.ToLocalTime()

    hours = dt.GetHours().ToStr()
    if Len(hours) = 1 then hours = "0" + hours
    minutes = dt.GetMinutes().ToStr()
    if Len(minutes) = 1 then minutes = "0" + minutes

    return dt.AsDateString("short-date") + " " + hours + ":" + minutes
End Function
