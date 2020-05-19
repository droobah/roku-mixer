Sub Init()
    m.listItemComponent = invalid
End Sub

Sub ForwardEvent(event as Object)
    if m.listItemComponent <> invalid
        eventField = event.getField()
        eventData = event.getData()

        m.listItemComponent[eventField] = eventData
    end if
End Sub

Sub ItemContentChanged(event as Object)
    itemContent = event.getData()

    dynamicComponentName = itemContent.dynamicComponentName

    ' reuse component, not destroying if it's same type as before and only updating data
    reuseComponent = m.top.currentComponentName = dynamicComponentName

    if reuseComponent = false
        m.listItemComponent = invalid
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.listItemComponent = CreateObject("roSGNode", dynamicComponentName)
    end if

    m.listItemComponent.itemContent = itemContent
    m.listItemComponent.listHasFocus = m.top.listHasFocus

    if reuseComponent = false
        m.top.appendChild(m.listItemComponent)
    end if

    m.top.currentComponentName = dynamicComponentName
End Sub