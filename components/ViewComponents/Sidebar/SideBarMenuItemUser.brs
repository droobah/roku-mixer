Sub Init()
    m.global.auth.observeFieldScoped("userProfile", "OnProfileChange")
    m.global.auth.observeFieldScoped("access_token", "OnTokenChange")
End Sub

Sub OnProfileChange(event as Object)
    if type(event) = "roSGNodeEvent"
        profile = event.getData()
    else
        profile = event
    end if

    isLoggedIn = m.global.auth.access_token <> ""

    if isLoggedIn and profile.username <> ""
        m.textLabel.text = profile.username
        if profile.avatarUrl <> ""
            m.iconPoster.uri = profile.avatarUrl
        else
            m.iconPoster.uri = "pkg:/images/default_avatar_rounded_small.png"
        end if
    else
        if m.top.itemContent.itemIconUri <> invalid and m.top.itemContent.itemIconUri <> ""
            m.iconPoster.uri = m.top.itemContent.itemIconUri
        end if
        m.textLabel.text = m.top.itemContent.itemText
    end if
End Sub

Sub OnTokenChange(event as Object)
    if event.getData() = ""
        OnProfileChange(m.global.auth.userProfile)
    end if
End Sub