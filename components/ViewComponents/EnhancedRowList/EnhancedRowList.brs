Sub Init()
    ? "[EnhancedRowList] Init()"
    m.top.observeField("rowItemFocusSize", "OnRowItemFocusSizeChange")
    m.top.observeField("rowItemSize", "OnRowItemSizeChange")
End Sub

Sub OnRowItemFocusSizeChange(event as Object)
    if type(event) = "roSGNodeEvent"
        rowItemFocusSize = event.getData()
    else
        rowItemFocusSize = event
    end if

    if rowItemFocusSize.Count() <> m.top.rowItemSize.Count()
        return
    end if

    m.top.unobserveField("rowItemSize")
    m.top.rowItemSize = rowItemFocusSize
    m.top.observeField("rowItemSize", "OnRowItemSizeChange")
End Sub

Sub OnRowItemSizeChange(event as Object)
    OnRowItemFocusSizeChange(m.top.rowItemFocusSize)
End Sub
