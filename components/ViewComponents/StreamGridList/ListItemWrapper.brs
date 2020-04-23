Sub Init()
    ' ? "[ListItemWrapper] Init()"

    ' Dynamically switch between online and offline list item components
    ' as the MarkupGrid recycles/reuses while scrolling

    m.top.opacity = 0.5
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
    itemContent = event.getData()
    componentName = "ListItemLive"

    if itemContent.isLoaderItem <> invalid
        componentName = "ListItemLoading"
    else
        online = itemContent.online
        if online = invalid
            online = false
        end if

        if online = false
            componentName = "ListItemOffline"
        end if
    end if

    ' reuse component, not destroying if it's same type as before and only updating data
    reuseComponent = m.top.currentComponentName = componentName

    if reuseComponent = false
        m.listItemComponent = invalid
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.listItemComponent = CreateObject("roSGNode", componentName)
    end if

    m.listItemComponent.width = m.top.width
    m.listItemComponent.height = m.top.height
    if componentName <> "ListItemLoading"
        m.listItemComponent.content = itemContent
    end if

    if reuseComponent = false
        m.top.appendChild(m.listItemComponent)
    end if

    m.top.currentComponentName = componentName
End Sub

Sub GridFocusChanged()
  if not m.top.gridHasFocus and m.top.focusPercent > 0.0
    m.top.opacity = 0.5
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
    m.top.opacity = percent / 2 + 0.5
End Sub