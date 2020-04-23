Sub Init()
    m.top.itemComponentName = "DynamicItemComponent"

    m.loaderReference = invalid
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