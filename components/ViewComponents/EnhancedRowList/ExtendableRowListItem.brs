Sub Init()
    m.inactiveOpacity = 0.6

    m.top.opacity = m.inactiveOpacity

    m.top.observeField("rowHasFocus", "RowFocusChanged")
    m.top.observeField("itemHasFocus", "ItemFocusChanged")
    m.top.observeField("focusPercent", "ShowFocus")
End Sub

Sub RowFocusChanged(event as Object)
    if not m.top.rowHasFocus and m.top.focusPercent > 0.0
        m.top.opacity = m.inactiveOpacity
    end if

    _OnRowHasFocusChanged(event.getData())
End Sub

Sub _OnRowHasFocusChanged(data)
End Sub

Sub ItemFocusChanged(event as Object)
    hasFocus = event.getData()

    if hasFocus
        m.top.opacity = 1
    end if

    _OnItemHasFocusChanged(hasFocus)
End Sub

Sub _OnItemHasFocusChanged(data)
End Sub

Sub ShowFocus(event as Object)
    if not m.top.rowHasFocus then return

    percent = event.getData()
    m.top.opacity = percent / (1 / (1 - m.inactiveOpacity)) + m.inactiveOpacity
End Sub