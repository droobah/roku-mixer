Sub Init()
    ? "[GridList] Init()"

    m.markupGrid = m.top.findNode("MarkupGrid")

    m.top.observeField("focusedChild", "OnFocusedChildChange")
End Sub

Sub OnFocusedChildChange()
  if m.top.isInFocusChain()
    m.markupGrid.setFocus(true)
  end if
End Sub

Sub ConfigSet(event as Object)
    m.top.unobserveField("config")

    config = event.getData()

    m.markupGrid.itemSize = [(config[0] - ((config[1] - 1) * 42)) / config[1], 462]
    m.markupGrid.numColumns = config[1]
    m.markupGrid.numRows = config[2]
End Sub