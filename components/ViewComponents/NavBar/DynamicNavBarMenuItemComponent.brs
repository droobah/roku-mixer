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
    itemData = itemContent.data

    dynamicComponentName = itemData.dynamicComponentName

    m.listItemComponent = invalid
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    m.listItemComponent = CreateObject("roSGNode", dynamicComponentName)
    m.listItemComponent.currRect = m.top.currRect
    m.listItemComponent.groupHasFocus = m.top.groupHasFocus
    m.listItemComponent.itemContent = itemContent
    m.listItemComponent.focusPercent = m.top.focusPercent
    m.listItemComponent.itemHasFocus = m.top.itemHasFocus
    m.top.appendChild(m.listItemComponent)
End Sub