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
        RenderUserView()
    end if
End Sub

Sub RenderLinkView()
    if m.currentView = invalid or m.currentView.id <> "LinkView"
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.currentView = CreateObject("roSGNode", "LinkView")
        m.currentView.id = "LinkView"
        m.top.appendChild(m.currentView)
        m.currentView.setFocus(true)
    end if
End Sub

Sub RenderUserView()
    if m.currentView = invalid or m.currentView.id <> "UserView"
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.currentView = CreateObject("roSGNode", "UserView")
        m.currentView.id = "UserView"
        m.top.appendChild(m.currentView)
        m.currentView.setFocus(true)
    end if
End Sub