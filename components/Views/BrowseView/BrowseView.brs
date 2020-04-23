Sub Init()
    ? "[BrowseView] Init()"

    m.searchFilter = false
    m.audienceFilter = false
    m.languageFilter = false
    m.partnerFilter = false

    m.page = 0
    m.perPage = 30
    m.canFetchData = true


    m.fetchingData = false

    m.drawer = m.top.findNode("Drawer")
    m.browseGridList = m.top.findNode("BrowseGridList")

    m.browseGridListContent = CreateObject("roSGNode", "ContentNode")
    m.browseGridList.content = m.browseGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.browseGridList.observeField("itemSelected", "OnItemSelected")
    m.browseGridList.observeField("itemFocused", "OnItemFocused")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.browseGridList.setFocus(true)
    end if
End Sub

Sub OnItemSelected(event as Object)
    index = event.getData()
    item = m.browseGridListContent.getChild(index)

    if item <> invalid and item.model_id <> invalid
        PlayLiveStream(item.model_id)
    end if
End Sub

Sub OnItemFocused(event as Object)
    index = event.getData()
    isItemInLastRow = m.browseGridListContent.getChildCount() - index <= 3
    if isItemInLastRow
        FetchData()
    end if
End Sub

Sub OnPlayerDestroyed()
    m.browseGridList.setFocus(true)
End Sub

Sub FetchData()
    if m.canFetchData = false or m.fetchingData then return

    m.fetchingData = true
    m.browseGridList.setLoading = true
    MakeGETRequest("https://mixer.com/api/v1/channels?limit=" + m.perPage.ToStr() + "&order=viewersCurrent:DESC&page=" + m.page.ToStr(), "ChannelsResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    m.browseGridList.setLoading = false
    hasNextPage = true
    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)
        if responseItems.Count() < m.perPage then hasNextPage = false
        m.browseGridListContent.appendChildren(responseItems)

        m.top.contentSet = true
    end if

    m.page += 1
    m.fetchingData = false
    m.canFetchData = hasNextPage
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> BrowseView >> OnkeyEvent"

    if not press then return false

    if key = "left" and m.browseGridList.isInFocusChain()
        m.drawer.toggle = true
        m.drawer.setFocus(true)
        return true
    else if (key = "right" or key = "back") and m.drawer.isInFocusChain()
        m.drawer.toggle = false
        m.browseGridList.setFocus(true)
        return true
    end if

    return false
End Function