Sub Init()
    m.inactiveOpacity = 0.6

    m.top.opacity = m.inactiveOpacity

    m.top.observeField("gridHasFocus", "GridFocusChanged")
    m.top.observeField("itemHasFocus", "ItemFocusChanged")
    m.top.observeField("focusPercent", "ShowFocus")
End Sub

Sub GridFocusChanged()
    if not m.top.gridHasFocus and m.top.focusPercent > 0.0
        m.top.opacity = m.inactiveOpacity
    end if
End Sub

Sub ItemFocusChanged(event as Object)
    hasFocus = event.getData()

    if hasFocus
        m.top.opacity = 1
    end if
End Sub

Sub ShowFocus(event as Object)
    if not m.top.gridHasFocus then return

    percent = event.getData()
    m.top.opacity = percent / (1 / (1 - m.inactiveOpacity)) + m.inactiveOpacity
End Sub