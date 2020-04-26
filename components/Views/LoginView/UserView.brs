Sub Init()
    m.logoutButton = m.top.findNode("LogoutButton")

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.logoutButton.observeField("buttonSelected", "OnLogoutButtonClick")

    FetchMyProfile()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.logoutButton.setFocus(true)
    end if
End Sub

Sub OnLogoutButtonClick()
    Logout()
End Sub