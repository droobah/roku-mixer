Sub Init()
    m.roundedMaskGroup = m.top.findNode("RoundedMaskGroup")
    m.avatarPoster = m.top.findNode("AvatarPoster")
    m.usernameLabel = m.top.findNode("UsernameLabel")
    m.buttonGroup = m.top.findNode("ButtonGroup")

    maskSize = doScale(160, m.global.scaleFactor)
    m.roundedMaskGroup.maskSize = [maskSize, maskSize]

    m.buttonGroup.buttons = [{
        icon: "pkg:/images/icons/user-circle.svg.png",
        iconSize: 24,
        text: "View my profile",
    }, {
        text: "Logout"
    }]

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.buttonGroup.observeField("buttonSelected", "OnGroupButtonSelected")
    m.global.auth.observeFieldScoped("userProfile", "OnProfileChange")

    FetchMyProfile()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.buttonGroup.setFocus(true)
    end if
End Sub

Sub OnProfileChange(event as Object)
    if type(event) = "roSGNodeEvent"
        profile = event.getData()
    else
        profile = event
    end if

    isLoggedIn = m.global.auth.access_token <> ""

    if isLoggedIn and profile.username <> ""
        m.usernameLabel.text = profile.username
        if profile.avatarUrl <> ""
            m.avatarPoster.uri = profile.avatarUrl
        else
            m.avatarPoster.uri = "pkg:/images/default_avatar.png"
        end if
    end if
End Sub

Sub OnGroupButtonSelected(event as Object)
    buttonIndex = event.getData()

    if buttonIndex = 0
        ? "VIEW MY PROFILE"
    else if buttonIndex = 1
        Logout()
    end if
End Sub
