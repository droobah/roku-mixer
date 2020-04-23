Sub Init()
    ' ? "[DynamicItemComponent] Init()"

    m.listItemComponent = invalid
End Sub

Sub ForwardEvent(event as Object)
    if m.listItemComponent <> invalid and (m.top.itemContent.isLoaderItem = invalid or m.top.itemContent.isLoaderItem = false)
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

    isLoaderItem = itemContent.isLoaderItem <> invalid and itemContent.isLoaderItem = true

    ' Update fields in correct order
    ' https://developer.roku.com/en-gb/docs/references/scenegraph/list-and-grid-nodes/markupgrid.md#markupgrid-xml-component
    m.listItemComponent.width = m.top.width
    m.listItemComponent.height = m.top.height
    if isLoaderItem = false
        m.listItemComponent.index = m.top.index
        m.listItemComponent.gridHasFocus = m.top.gridHasFocus
    end if
    m.listItemComponent.itemContent = itemContent
    if isLoaderItem = false
        m.listItemComponent.focusPercent = m.top.focusPercent
        m.listItemComponent.itemHasFocus = m.top.itemHasFocus
    end if

    if reuseComponent = false
        m.top.appendChild(m.listItemComponent)
    end if

    m.top.currentComponentName = dynamicComponentName
End Sub