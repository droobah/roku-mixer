Sub Init()
    ? "[BrowseView] Init()"

    m.searchFilter = false
    m.audienceFilter = false
    m.languageFilter = false
    m.partnerFilter = false

    m.drawer = m.top.findNode("Drawer")
    m.browseGridList = m.top.findNode("BrowseGridList")

    m.browseGridListContent = CreateObject("roSGNode", "ContentNode")
    m.browseGridList.content = m.browseGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.browseGridList.observeField("itemSelected", "OnItemSelected")

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

    ? "ITEM SELECTED"; index

    if item <> invalid and item.model_id <> invalid
        ? item.model_id; type(item.model_id)
        PlayLiveStream(item.model_id)
    end if
End Sub

Sub OnPlayerDestroyed()
    m.browseGridList.setFocus(true)
End Sub

Sub FetchData()
    MakeGETRequest("https://mixer.com/api/v1/channels?limit=100&order=viewersCurrent:DESC", "ChannelsResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)
        m.browseGridListContent.appendChildren(responseItems)

        m.top.contentSet = true
    end if

    ? response.transformedResponse
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