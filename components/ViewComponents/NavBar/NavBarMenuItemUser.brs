Sub Init()
    m.global.auth.observeFieldScoped("userProfile", "OnProfileChange")
    m.global.auth.observeFieldScoped("access_token", "OnTokenChange")
    m.labelContainer = m.top.findNode("LabelContainer")
End Sub

Sub OnRectangleChange(event as Object)
    rect = event.getData()

    m.background.width = rect.width
    m.background.height = rect.height

    ' clip long username
    m.labelContainer.clippingRect = [m.top.translation[0], m.top.translation[1], rect.width - 9, rect.height]
End Sub

Sub OnProfileChange(event as Object)
    if type(event) = "roSGNodeEvent"
        profile = event.getData()
    else
        profile = event
    end if

    isLoggedIn = m.global.auth.access_token <> ""

    if isLoggedIn and profile.username <> ""
        m.label.text = profile.username
        if profile.avatarUrl <> ""
            m.icon.uri = profile.avatarUrl
        else
            m.icon.uri = "pkg:/images/default_avatar_rounded_small.png"
        end if
    else
        if m.top.itemContent.data.icon <> invalid and m.top.itemContent.data.icon <> ""
            m.icon.uri = m.top.itemContent.data.icon
        end if
        m.label.text = m.top.itemContent.data.title
    end if
End Sub

Sub OnTokenChange(event as Object)
    if event.getData() = ""
        OnProfileChange(m.global.auth.userProfile)
    end if
End Sub