Sub Init()
    ? "[GamesView] Init()"

    m.page = 0
    m.fetchingData = false

    m.drawer = m.top.findNode("Drawer")
    m.gamesGridList = m.top.findNode("GamesGridList")

    m.gamesGridListContent = CreateObject("roSGNode", "ContentNode")
    m.gamesGridList.content = m.gamesGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.gamesGridList.observeField("itemSelected", "OnItemSelected")
    m.gamesGridList.observeField("itemFocused", "OnItemFocused")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.gamesGridList.setFocus(true)
    end if
End Sub

Sub OnItemSelected(event as Object)
    index = event.getData()
    item = m.gamesGridListContent.getChild(index)

    ? "ITEM SELECTED"; index

    if item <> invalid and item.model_id <> invalid
        ? item.model_id; type(item.model_id)
        PlayLiveStream(item.model_id)
    end if
End Sub

Sub OnItemFocused(event as Object)
    index = event.getData()
    isItemInLastRow = m.gamesGridListContent.getChildCount() - index <= 6
    if isItemInLastRow
        FetchData()
    end if
End Sub

Sub OnPlayerDestroyed()
    m.gamesGridList.setFocus(true)
End Sub

Sub FetchData()
    if m.fetchingData then return

    m.fetchingData = true
    m.gamesGridList.setLoading = true
    MakeGETRequest("https://mixer.com/api/v1/types?limit=30&order=viewersCurrent:DESC&noCount=true&page=" + m.page.ToStr(), "GamesResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    m.gamesGridList.setLoading = false

    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)
        m.gamesGridListContent.appendChildren(responseItems)

        m.top.contentSet = true
    end if

    m.page += 1
    m.fetchingData = false
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> GamesView >> OnkeyEvent"

    if not press then return false

    if key = "left" and m.gamesGridList.isInFocusChain()
        m.drawer.toggle = true
        m.drawer.setFocus(true)
        return true
    else if (key = "right" or key = "back") and m.drawer.isInFocusChain()
        m.drawer.toggle = false
        m.gamesGridList.setFocus(true)
        return true
    end if

    return false
End Function