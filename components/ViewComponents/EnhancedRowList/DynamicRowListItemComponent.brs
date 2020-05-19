Sub Init()
    ' ? "[DynamicRowListItemComponent] Init()"

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

    ' Update fields in correct order
    ' https://developer.roku.com/docs/references/scenegraph/list-and-grid-nodes/rowlist.md#rowlist-xml-component
    m.listItemComponent.width = m.top.width
    m.listItemComponent.height = m.top.height
    m.listItemComponent.index = m.top.index
    m.listItemComponent.index = m.top.rowIndex
    m.listItemComponent.rowHasFocus = m.top.rowHasFocus
    m.listItemComponent.rowListHasFocus = m.top.rowListHasFocus
    m.listItemComponent.itemContent = itemContent
    m.listItemComponent.focusPercent = m.top.focusPercent
    m.listItemComponent.rowFocusPercent = m.top.rowFocusPercent
    m.listItemComponent.itemHasFocus = m.top.itemHasFocus

    if reuseComponent = false
        m.top.appendChild(m.listItemComponent)
    end if

    m.top.currentComponentName = dynamicComponentName
End Sub