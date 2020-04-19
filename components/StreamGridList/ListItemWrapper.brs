Sub Init()
    ' ? "[ListItemWrapper] Init()"

    ' Dynamically switch between online and offline list item components
    ' as the MarkupGrid recycles/reuses while scrolling

    m.listItemComponent = invalid
End Sub

Sub WidthChanged(event as Object)
    if m.listItemComponent <> invalid
        width = event.getData()
        m.listItemComponent.width = width
    end if
End Sub

Sub HeightChanged(event as Object)
    if m.listItemComponent <> invalid
        height = event.getData()
        m.listItemComponent.height = height
    end if
End Sub

Sub ContentChanged(event as Object)
    ? "[ListItemWrapper] ContentChanged()"
    itemContent = event.getData()

    online = itemContent.online
    if online = invalid
        online = false
    end if

    componentName = "ListItemLive"
    if online = false
        componentName = "ListItemOffline"
    end if

    m.listItemComponent = invalid
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)

    m.listItemComponent = CreateObject("roSGNode", componentName)
    m.listItemComponent.content = itemContent
    m.top.appendChild(m.listItemComponent)
End Sub

Sub ShowFocus(event as Object)
    if not m.top.gridHasFocus then return

    percent = event.getData()
    m.top.opacity = percent / 2 + 0.5
End Sub