Sub Init()
    m.top.itemComponentName = "DynamicItemComponent"

    m.loaderReference = invalid

    m.originalItemSize = [0, 0]
    m.originalItemSpacing = [0, 0]

    m.top.observeField("itemSize", "OnItemSizeChange")
    m.top.observeField("itemSpacing", "OnItemSpacingChange")
    m.top.observeField("focusSize", "OnFocusSizeChange")
End Sub

Sub OnItemSizeChange(event as Object)
    itemSize = event.getData()
    m.originalItemSize = itemSize
End Sub

Sub OnItemSpacingChange(event as Object)
    itemSpacing = event.getData()
    m.originalItemSpacing = itemSpacing
End Sub

Sub OnFocusSizeChange(event as Object)
    focusSize = event.getData()
    m.top.unobserveField("itemSize")
    m.top.unobserveField("itemSpacing")

    m.top.itemSize = focusSize
    m.top.itemSpacing = [
        m.originalItemSpacing[0] + m.originalItemSize[0] - focusSize[0],
        m.originalItemSpacing[1] + m.originalItemSize[1] - focusSize[1]
    ]

    m.top.observeField("itemSize", "OnItemSizeChange")
    m.top.observeField("itemSpacing", "OnItemSpacingChange")
End Sub

Sub SetLoading(event as Object)
    if m.top.content = invalid then return

    loading = event.getData()

    if loading
        if m.loaderReference <> invalid then return

        m.loaderReference = CreateObject("roSGNode", "ContentNode")
        m.loaderReference.addFields({
            dynamicComponentName: m.top.loaderComponentName,
            isLoaderItem: true
        })
        m.top.content.appendChild(m.loaderReference)
    else
        if m.loaderReference <> invalid
            m.top.content.removeChild(m.loaderReference)
            m.loaderReference = invalid
        end if
    end if
End Sub