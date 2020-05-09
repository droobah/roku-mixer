Sub Init()
    m.top.contentSet = true
    m.currentView = invalid

    onTokenChange(m.global.auth.access_token)

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.global.auth.observeFieldScoped("access_token", "onTokenChange")
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus() and m.currentView <> invalid
        m.currentView.setFocus(true)
    end if
End Sub

Sub onTokenChange(event as Object)
    if type(event) = "roSGNodeEvent"
        access_token = event.getData()
    else
        access_token = event
    end if

    if access_token = ""
        RenderLinkView()
    else
        RenderAuthenticatedView()
    end if
End Sub

Sub RenderLinkView()
    if m.currentView = invalid or m.currentView.id <> "UserLinkView"
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.currentView = CreateObject("roSGNode", "UserLinkView")
        m.currentView.id = "UserLinkView"
        m.top.appendChild(m.currentView)
        m.currentView.setFocus(true)
    end if
End Sub

Sub RenderAuthenticatedView()
    if m.currentView = invalid or m.currentView.id <> "UserAuthenticatedView"
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.currentView = CreateObject("roSGNode", "UserAuthenticatedView")
        m.currentView.id = "UserAuthenticatedView"
        m.top.appendChild(m.currentView)
        m.currentView.setFocus(true)
    end if
End Sub